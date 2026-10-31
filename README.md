# FitHabit – Smart Habit & Wellness Tracker (Nhóm 12 - 23DTHD5)

**Đồ án Môn học: Lập trình Thiết bị Di động (Flutter - Mã học phần: `CMP177`)**  
**Trường Đại học Công nghệ TP. Hồ Chí Minh (HUTECH) – Khoa Công nghệ Thông tin**

---

## Thành viên Nhóm 12 (Lớp 23DTHD5)

| STT | Họ và tên sinh viên | MSSV | Lớp | Vai trò & Phụ trách chính |
| :-: | :--- | :-: | :-: | :--- |
| 07 | **Huỳnh Nguyễn Trung Hiếu** *(Nhóm trưởng)* | `2380612739` | 23DTHD5 | Kiến trúc hệ thống, Bento Wellness UI, Quản lý Thói quen (CRUD) & Tìm kiếm/Lọc (CN 02, CN 06) |
| 34 | **Trần Đình Trí** | `2380602321` | 23DTHD5 | Tích hợp AI Gemini 2.5 Flash quét calo món ăn Việt, Tính năng BMI & Theo dõi Nước uống (CN 03, CN 08) |
| 37 | **Nguyễn Hữu Tài** | `2380601952` | 23DTHD5 | Lưu trữ Offline-first SQLite, Đồng bộ đám mây Firebase Firestore & Xác thực người dùng (CN 01, CN 07) |
| 41 | **Lê Ngọc Quang Vinh** | `2380602555` | 23DTHD5 | Thống kê Biểu đồ & Heatmap 12 tuần, Nhắc nhở thông minh & Khóa bảo mật Sinh trắc học/PIN (CN 04, CN 05) |

---

## 8 Chức năng Cốt lõi (Bento Wellness Minimalist UI)

1. **CN 01 – Tài khoản & Bảo mật PIN/Sinh trắc học:** Đăng nhập/Đăng ký, khóa ứng dụng bằng **4 ô nhập PIN độc lập** và mở khóa nhanh bằng FaceID/Vân tay.
2. **CN 02 – Quản lý Thói quen (CRUD & Slidable):** Thêm, sửa, xóa thói quen qua thao tác vuốt ngang (*Slidable Card*), nút Check-in tròn có animation và Vòng tròn tiến độ kép (*Daily Progress Ring*).
3. **CN 03 – Thể trạng BMI & Theo dõi Nước uống:** Biểu đồ **Cốc sóng nước (`1500/2000ml`)** kèm nút cộng nhanh 1 chạm (`+200ml`, `+350ml`, `+500ml`) và thước đo BMI Dark Mode với con trỏ tam giác.
4. **CN 04 – Thống kê Biểu đồ & Heatmap 12 Tuần:** Lưới 3 cột KPI đồng nhất, bản đồ nhiệt **GitHub Contributions Heatmap 12 tuần** (4 cấp độ màu Emerald) và biểu đồ cột 7 ngày.
5. **CN 05 – Nhắc nhở Thông minh:** Cài đặt giờ nhắc từng thói quen và công tắc `Switch.adaptive` nhắc uống nước định kỳ mỗi 2 tiếng.
6. **CN 06 – Tìm kiếm & Lọc Đa tiêu chí:** Thanh tìm kiếm thời gian thực kết hợp dải Filter Chips chuyển màu mượt mà.
7. **CN 07 – Lưu trữ Offline-first (SQLite & Firebase):** Lưu trữ tức thời trên SQLite cục bộ và đồng bộ đám mây Firebase kèm trạng thái Cloud Sync trực quan.
8. **CN 08 – AI Calo Scanner & Gợi ý Tập luyện:** Khung ngắm Camera Viewfinder, nhận diện món ăn Việt Nam bằng **Google Gemini 2.5 Flash**, chuẩn hóa calo theo công thức **Atwater (`4P + 4C + 9F`)** và gợi ý bài tập đốt calo (**Smart Workout Roadmap**).

---

## Tài liệu Báo cáo trong Repository

- [`baocaonhom12.pdf`](./baocaonhom12.pdf) – Báo cáo đồ án môn học bản PDF chính thức (14 trang).
- [`baocaonhom12.docx`](./baocaonhom12.docx) – Báo cáo đồ án môn học bản Microsoft Word.

## Hướng dẫn Chạy Dự án

```bash
flutter pub get
flutter run
```
