import { onRequest } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2/options";
import { getAuth } from "firebase-admin/auth";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { createHash, randomBytes } from "node:crypto";
import { initializeApp, cert } from "firebase-admin/app";
import key from "../key.json";

setGlobalOptions({ maxInstances: 10 });

initializeApp({
    credential: cert(key as any),
});

const auth = getAuth();
const db = getFirestore();

const COLLECTION = "bioRefreshTokens";
const TTL_DAYS = 30;
const TTL_MS = TTL_DAYS * 24 * 60 * 60 * 1000;

function hashToken(token: string): string {
    return createHash("sha256").update(token).digest("hex");
}

function generateOpaqueToken(): string {
    return randomBytes(48).toString("base64url");
}

function getBearerToken(header?: string): string {
    if (!header || !header.startsWith("Bearer ")) {
        throw new Error("Missing bearer token");
    }
    return header.slice("Bearer ".length).trim();
}

async function issueBioRefreshToken(uid: string): Promise<string> {
    const rawToken = generateOpaqueToken();
    const tokenHash = hashToken(rawToken);

    await db.collection(COLLECTION).doc(tokenHash).set({
        uid,
        revoked: false,
        createdAt: FieldValue.serverTimestamp(),
        expiresAt: Timestamp.fromDate(new Date(Date.now() + TTL_MS)),
    });

    return rawToken;
}

export const mintBioRefreshToken = onRequest({ cors: true }, async (req, res) => {
    console.log("[mint] request received", {
        method: req.method,
        hasAuthHeader: !!req.headers.authorization,
    });

    try {
        if (req.method !== "POST") {
            console.log("[mint] wrong method:", req.method);
            res.status(405).json({ error: "Method not allowed" });
            return;
        }

        const idToken = getBearerToken(req.headers.authorization);
        console.log("[mint] bearer token parsed");

        const decoded = await auth.verifyIdToken(idToken);
        console.log("[mint] idToken verified for uid:", decoded.uid);

        const refreshToken = await issueBioRefreshToken(decoded.uid);
        console.log("[mint] refresh token issued");

        res.status(200).json({ refreshToken });
    } catch (error) {
        console.error("[mint] failed", error);
        res.status(401).json({ error: "Unauthorized" });
    }
});

// - сервак получает refresh token от клиента. хеширует его. ищет документ в Firestore.
// - если док есть и не истек, то удаляем старый токен, создаем новый и выдает customToken для Firebase
// - если токена нет, то возвращается 401 ошибка
export const exchangeBioRefreshToken = onRequest({ cors: true }, async (req, res) => {
    try {
        if (req.method !== "POST") {
            res.status(405).json({ error: "Method not allowed" });
            return;
        }

        const refreshToken = req.body?.refreshToken;
        if (typeof refreshToken !== "string" || !refreshToken.trim()) {
            res.status(400).json({ error: "refreshToken is required" });
            return;
        }

        const oldHash = hashToken(refreshToken);
        const oldRef = db.collection(COLLECTION).doc(oldHash);
        const oldSnap = await oldRef.get();

        if (!oldSnap.exists) {
            res.status(401).json({ error: "Invalid token" });
            return;
        }

        const oldData = oldSnap.data();
        if (!oldData) {
            res.status(401).json({ error: "Invalid token" });
            return;
        }

        const expiresAt = oldData.expiresAt as Timestamp | undefined;
        if (oldData.revoked || !expiresAt || expiresAt.toMillis() < Date.now()) {
            await oldRef.delete();
            res.status(401).json({ error: "Token expired or revoked" });
            return;
        }

        const uid = oldData.uid as string;

        const newRefreshToken = generateOpaqueToken();
        const newHash = hashToken(newRefreshToken);
        const newRef = db.collection(COLLECTION).doc(newHash);

        await db.runTransaction(async (tx) => {
            const snap = await tx.get(oldRef);
            if (!snap.exists) {
                throw new Error("Token already consumed");
            }

            tx.delete(oldRef);
            tx.set(newRef, {
                uid,
                revoked: false,
                createdAt: FieldValue.serverTimestamp(),
                expiresAt: Timestamp.fromDate(new Date(Date.now() + TTL_MS)),
                rotatedFrom: oldHash,
            });
        });

        const customToken = await auth.createCustomToken(uid);

        res.status(200).json({
            customToken,
            refreshToken: newRefreshToken,
        });
    } catch (error) {
        console.error("exchangeBioRefreshToken failed", error);
        res.status(401).json({ error: "Unauthorized" });
    }
});
