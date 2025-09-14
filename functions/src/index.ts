
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

admin.initializeApp();

// Danh sách các thông báo ngẫu nhiên
const randomNotifications = [
  {
    title: "Chào buổi sáng!",
    body: "Đừng quên ghi lại bữa ăn của bạn hôm nay để đi đúng hướng nhé!",
  },
  {
    title: "Nhắc nhở nhanh!",
    body: "Mỗi bữa ăn được ghi lại là một bước tiến tới mục tiêu của bạn. " +
          "Cố lên!",
  },
  {
    title: "Bạn đã sẵn sàng chưa?",
    body: "Năng lượng cho ngày hôm nay đến từ đâu? Hãy cho chúng tôi biết " +
          "bạn đã ăn gì!",
  },
  {
    title: "Kiểm tra nhanh!",
    body: "Bạn đang làm rất tốt! Hãy dành một chút thời gian để cập nhật " +
          "nhật ký thực phẩm của bạn.",
  },
  {
    title: "Mục tiêu trong tầm tay!",
    body: "Hãy nhớ rằng, mỗi lựa chọn nhỏ đều tạo nên sự khác biệt lớn. " +
          "Cố gắng lên nhé!",
  },
];

export const dailyNotification = onSchedule("every 1 minutes", async () => {
  logger.info("Running daily notification with random messages");

  const usersSnapshot = await admin.firestore().collection("users").get();

  const tokens: string[] = [];
  usersSnapshot.forEach((userDoc) => {
    const fcmToken = userDoc.data().fcmToken;
    if (fcmToken) {
      tokens.push(fcmToken);
    }
  });

  if (tokens.length > 0) {
    const randomIndex = Math.floor(
      Math.random() * randomNotifications.length
    );
    const randomMessage = randomNotifications[randomIndex];

    const payload = {
      notification: randomMessage,
    };

    try {
      await admin.messaging().sendToDevice(tokens, payload);
      logger.info("Sent notification:", randomMessage.title);
    } catch (error) {
      logger.error("Error sending notifications:", error);
    }
  }
});
