# Bản kế hoạch chi tiết: Calorie Counter AI

## Tổng quan

**Mục đích:** Tạo một ứng dụng Flutter có tên "Calorie Counter AI" hoạt động như một huấn luyện viên dinh dưỡng và sức khỏe ảo. Ứng dụng sẽ cung cấp các kế hoạch bữa ăn được cá nhân hóa, phân tích chế độ ăn uống, dự đoán cân nặng trong tương lai và đưa ra lời khuyên thông qua giao diện chatbot.

## Cấu trúc dự án

*   `lib/`: Mã nguồn ứng dụng Flutter.
*   `functions/`: Logic phía máy chủ cho Cloud Functions.

## Tính năng & Phong cách

### Các tính năng cốt lõi:
1.  **Hồ sơ người dùng:**
    *   Các trường nhập cho tuổi, giới tính, chiều cao (cm), cân nặng (kg).
    *   Lựa chọn mục tiêu của người dùng (giảm cân, tăng cân, duy trì).
    *   Nhập mục tiêu lượng calo hàng ngày.

2.  **Kế hoạch bữa ăn cá nhân hóa:**
    *   Tạo kế hoạch bữa ăn cho một số ngày do người dùng chỉ định.
    *   Kế hoạch bao gồm bữa sáng, bữa trưa, bữa tối và đồ ăn nhẹ.
    *   Mỗi món ăn hiển thị calo, carb, protein và chất béo.
    *   Tổng lượng calo hàng ngày sẽ phù hợp với mục tiêu của người dùng.

3.  **Phân tích chế độ ăn uống hàng ngày:**
    *   Người dùng có thể ghi lại bữa ăn của mình ở định dạng JSON.
    *   Ứng dụng tính toán tổng lượng calo và tỷ lệ macronutrient (Carb/Protein/Fat).
    *   Cung cấp phản hồi về việc người dùng có đạt, vượt quá hay thiếu hụt so với mục tiêu calo của họ.
    *   Đưa ra các đề xuất cải thiện hữu ích.

4.  **Dự đoán cân nặng:**
    *   Phân tích dữ liệu lịch sử (cân nặng, lượng calo nạp vào/tiêu thụ).
    *   Dự đoán cân nặng của người dùng sau 30 ngày dựa trên thói quen hiện tại.
    *   Trình bày dự đoán dưới dạng một con số cụ thể (kg) kèm theo giải thích rõ ràng.

5.  **AI Chatbot:**
    *   Giao diện trò chuyện thân thiện, để người dùng đặt câu hỏi.
    *   Cung cấp các câu trả lời ngắn gọn, dễ hiểu liên quan đến dinh dưỡng, thể dục và lối sống lành mạnh.

6.  **Thông báo đẩy (Push Notifications):**
    *   Sử dụng Firebase Cloud Messaging (FCM) để gửi thông báo.
    *   Logic phía máy chủ (Cloud Functions) gửi lời nhắc hàng ngày.

### Thiết kế & Phong cách:
*   **Thẩm mỹ:** Giao diện người dùng hiện đại, sạch sẽ và trực quan. Bố cục cân đối, có khoảng trắng rõ ràng.
*   **Bảng màu:** Một giao diện sống động và tràn đầy năng lượng, có thể kết hợp các sắc thái của màu xanh lá cây, xanh dương và cam để gợi lên cảm giác về sức khỏe và sức sống.
*   **Kiểu chữ:** Sử dụng phông chữ Poppins từ Google Fonts với hệ thống phân cấp rõ ràng.
*   **Biểu tượng:** Sử dụng các biểu tượng trực quan để tăng cường điều hướng và sự dễ hiểu.
*   **Tương tác:** Các yếu tố tương tác như nút và thanh trượt sẽ có hiệu ứng đổ bóng tinh tế để tạo cảm giác phản hồi nhanh.
*   **Trợ năng:** Tuân thủ các tiêu chuẩn trợ năng (a11y) để đảm bảo ứng dụng có thể sử dụng được cho nhiều đối tượng người dùng.

## Kế hoạch hiện tại

**Mục tiêu:** Thiết lập logic phía máy chủ cho thông báo đẩy.

**Các bước:**
*   Khởi tạo Firebase Functions.
*   Viết một Cloud Function được lên lịch để gửi lời nhắc hàng ngày.
*   Triển khai function.
