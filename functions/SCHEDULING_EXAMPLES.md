# Ví dụ về Lập lịch Cloud Function

Tệp này chứa các ví dụ về cú pháp và các lệnh hữu ích để quản lý Cloud Functions.

---

## Cú pháp Lập lịch

Đây là các chuỗi bạn truyền vào hàm `onSchedule`.

### Cú pháp Đơn giản (Dễ đọc)

| Ví dụ | Mô tả |
| :--- | :--- |
| `"every 1 minutes"` | Chạy mỗi 1 phút (tuyệt vời để kiểm thử). |
| `"every 5 minutes"` | Chạy mỗi 5 phút. |
| `"every 1 hours"` | Chạy mỗi giờ. |
| `"every day 09:00"` | Chạy mỗi ngày vào lúc 9 giờ sáng. |
| `"every monday 09:00"` | Chạy mỗi thứ Hai vào lúc 9 giờ sáng. |
| `"15 of jan,may,sep 09:00"`| Chạy vào lúc 9 giờ sáng ngày 15 của tháng 1, tháng 5 và tháng 9. |

**Lưu ý:** Thời gian được chỉ định theo múi giờ UTC.

### Cú pháp Cron (Linh hoạt nhất)

Cú pháp này sử dụng một chuỗi gồm 5 trường được phân tách bằng dấu cách: `phút giờ ngày tháng ngày_trong_tuần`

| Ví dụ | Mô tả |
| :--- | :--- |
| `* * * * *` | Chạy mỗi phút. |
| `0 9 * * *` | Chạy vào lúc 9:00 sáng, mỗi ngày. |
| `0 20 * * *` | Chạy vào lúc 8:00 tối, mỗi ngày. |
| `0 9 */3 * *` | Chạy vào lúc 9:00 sáng, mỗi 3 ngày. |
| `0 10 * * 1-5`| Chạy vào lúc 10:00 sáng, mỗi ngày từ thứ Hai đến thứ Sáu. |

---

## Các Lệnh Hữu Ích

Các lệnh này phải được chạy từ thư mục gốc của dự án (`/home/user/myapp/`).

| Lệnh | Mô tả |
| :--- | :--- |
| `firebase deploy --only functions` | **Quan trọng nhất.** Dùng lệnh này sau bất kỳ thay đổi nào đối với các tệp trong thư mục `functions/` để áp dụng các thay đổi đó. |
| `firebase functions:log` | Xem nhật ký (logs) thời gian thực từ các function của bạn. Cực kỳ hữu ích để gỡ lỗi và xem liệu function có đang chạy hay không. |
| `cd functions && npm install` | Nếu bạn thêm một thư viện mới (npm package) vào function của mình, bạn cần chạy lệnh này từ bên trong thư mục `functions`. |
| `cd functions && npm run lint` | Chạy kiểm tra chất lượng mã để tìm các lỗi định dạng hoặc lỗi tiềm ẩn trước khi triển khai. |

