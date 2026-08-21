import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {
  BatchResponse,
  getMessaging,
  MulticastMessage,
} from "firebase-admin/messaging";
import {logger, setGlobalOptions} from "firebase-functions/v2";
import {onDocumentCreated} from "firebase-functions/v2/firestore";

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

setGlobalOptions({
  maxInstances: 10,
  region: "europe-west1",
});

type NotificationAudience = "all" | "expert" | "admin";

interface NotificationData {
  notificationId?: string;
  audience?: NotificationAudience;
  recipientUid?: string;
  title?: string;
  message?: string;
  type?: string;
  status?: string;
  targetScreen?: string;
  targetId?: string | null;
}

interface DeviceTokenRecord {
  token?: string;
  userUid?: string | null;
  isActive?: boolean;
}

const TOKEN_BATCH_SIZE = 500;

export const sendNotificationPush = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      logger.warn("Notification snapshot bulunamadı.");
      return;
    }

    const notificationId =
      event.params.notificationId as string;
    const data = snapshot.data() as NotificationData;

    const title = data.title?.trim() ?? "";
    const body = data.message?.trim() ?? "";
    const audience = data.audience;

    if (!title || !body) {
      logger.warn(
        "Push atlandı: title veya message boş.",
        {notificationId},
      );
      return;
    }

    if (
      audience !== "all" &&
      audience !== "expert" &&
      audience !== "admin"
    ) {
      // Eski userId tabanlı legacy bildirimleri push motoruna
      // dahil etmiyoruz.
      logger.info(
        "Push atlandı: desteklenmeyen/legacy audience.",
        {notificationId, audience},
      );
      return;
    }

    const tokens = await resolveTargetTokens(
      audience,
      data.recipientUid,
    );

    if (tokens.length === 0) {
      logger.info(
        "Push hedefi bulunamadı.",
        {notificationId, audience},
      );
      return;
    }

    const payloadData: Record<string, string> = {
      notificationId,
      audience,
      type: data.type ?? "",
      targetScreen: data.targetScreen ?? "none",
      targetId: data.targetId ?? "",
    };

    let successCount = 0;
    let failureCount = 0;
    const invalidTokens: string[] = [];

    for (
      let start = 0;
      start < tokens.length;
      start += TOKEN_BATCH_SIZE
    ) {
      const batchTokens = tokens.slice(
        start,
        start + TOKEN_BATCH_SIZE,
      );

      const message: MulticastMessage = {
        tokens: batchTokens,
        notification: {
          title,
          body,
        },
        data: payloadData,
        android: {
          priority: "high",
          notification: {
            channelId: "tasarruf_planim_notifications",
            sound: "default",
          },
        },
        apns: {
          headers: {
            "apns-priority": "10",
          },
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      const response =
        await messaging.sendEachForMulticast(message);

      successCount += response.successCount;
      failureCount += response.failureCount;

      collectInvalidTokens(
        response,
        batchTokens,
        invalidTokens,
      );
    }

    if (invalidTokens.length > 0) {
      await deactivateInvalidTokens(invalidTokens);
    }

    logger.info(
      "Push gönderimi tamamlandı.",
      {
        notificationId,
        audience,
        targetCount: tokens.length,
        successCount,
        failureCount,
        invalidTokenCount: invalidTokens.length,
      },
    );
  },
);

/**
 * Resolves active FCM tokens for the requested notification audience.
 * @param {NotificationAudience} audience Notification audience.
 * @param {string} recipientUid Optional expert recipient uid.
 * @return {Promise<string[]>} Unique active FCM tokens.
 */
async function resolveTargetTokens(
  audience: NotificationAudience,
  recipientUid?: string,
): Promise<string[]> {
  if (audience === "all") {
    const snapshot = await db
      .collection("deviceTokens")
      .where("isActive", "==", true)
      .get();

    return uniqueTokens(
      snapshot.docs.map(
        (doc) =>
          (doc.data() as DeviceTokenRecord).token ?? "",
      ),
    );
  }

  if (audience === "expert") {
    const uid = recipientUid?.trim() ?? "";

    if (!uid) {
      logger.warn(
        "Expert push atlandı: recipientUid yok.",
      );
      return [];
    }

    const snapshot = await db
      .collection("deviceTokens")
      .where("userUid", "==", uid)
      .where("isActive", "==", true)
      .get();

    return uniqueTokens(
      snapshot.docs.map(
        (doc) =>
          (doc.data() as DeviceTokenRecord).token ?? "",
      ),
    );
  }

  // Admin hedefini users/{uid}.role == "admin" kaynağından
  // çözüyoruz. Böylece istemci token kaydına admin rolü yazamaz.
  const adminUsers = await db
    .collection("users")
    .where("role", "==", "admin")
    .get();

  if (adminUsers.empty) {
    return [];
  }

  const adminUids = adminUsers.docs.map(
    (doc) => doc.id,
  );

  const tokens: string[] = [];

  // Firestore "in" sorgusunu güvenli küçük gruplar halinde yapıyoruz.
  for (let start = 0; start < adminUids.length; start += 10) {
    const uidBatch = adminUids.slice(start, start + 10);

    const snapshot = await db
      .collection("deviceTokens")
      .where("userUid", "in", uidBatch)
      .where("isActive", "==", true)
      .get();

    for (const doc of snapshot.docs) {
      const token =
        (doc.data() as DeviceTokenRecord).token ?? "";
      tokens.push(token);
    }
  }

  return uniqueTokens(tokens);
}

/**
 * Normalizes and de-duplicates FCM tokens.
 * @param {string[]} tokens Raw token values.
 * @return {string[]} Unique non-empty tokens.
 */
function uniqueTokens(tokens: string[]): string[] {
  return [
    ...new Set(
      tokens
        .map((token) => token.trim())
        .filter((token) => token.length > 0),
    ),
  ];
}

/**
 * Collects tokens rejected by FCM as invalid or unregistered.
 * @param {BatchResponse} response FCM multicast response.
 * @param {string[]} tokens Tokens corresponding to response entries.
 * @param {string[]} invalidTokens Mutable invalid-token collection.
 * @return {void}
 */
function collectInvalidTokens(
  response: BatchResponse,
  tokens: string[],
  invalidTokens: string[],
): void {
  response.responses.forEach((result, index) => {
    if (result.success) return;

    const code = result.error?.code ?? "";

    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    ) {
      invalidTokens.push(tokens[index]);
    }
  });
}

/**
 * Deactivates invalid FCM token records in Firestore.
 * @param {string[]} invalidTokens Invalid or unregistered FCM tokens.
 * @return {Promise<void>} Resolves when token records are updated.
 */
async function deactivateInvalidTokens(
  invalidTokens: string[],
): Promise<void> {
  const uniqueInvalid = uniqueTokens(invalidTokens);

  for (
    let start = 0;
    start < uniqueInvalid.length;
    start += 10
  ) {
    const tokenBatch = uniqueInvalid.slice(
      start,
      start + 10,
    );

    const snapshot = await db
      .collection("deviceTokens")
      .where("token", "in", tokenBatch)
      .get();

    if (snapshot.empty) continue;

    const batch = db.batch();

    for (const doc of snapshot.docs) {
      batch.update(doc.ref, {
        isActive: false,
        userUid: null,
      });
    }

    await batch.commit();
  }
}
