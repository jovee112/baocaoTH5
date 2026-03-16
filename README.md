# quan_ly_sinh_vien

A new Flutter project.
# 🎓 Student Manager App - Bài thực hành 5

Ứng dụng quản lý sinh viên được xây dựng bằng **Flutter**, tập trung vào trải nghiệm người dùng hiện đại, quản lý dữ liệu linh hoạt và khả năng đồng bộ hóa.

---

## 👥 Thông tin Nhóm
* **Môn học:** Phát triển ứng dụng Mobile.
* **Số nhóm:** 4
* **Thành viên:**
    1.  Hà Tuấn Phong - Trưởng nhóm (Quản lý dự án, Database, Integration)
    2.  Trần Ngọc Lương - Logic & State Management
    3.  Nguyễn Thành Dương - UI & Form Validation
    4.  Nông Lan Anh - Dashboard & Statistics
    5.  Hồ Đức Mạnh - Static UI & Components

---

## 🛠 Công nghệ Sử dụng
* **Framework:** Flutter (Material 3)
* **Language:** Dart
* **State Management:** `Provider`
* **Local Storage:** `SharedPreferences`
* **Backend:** `Firebase` (đã lên kế hoạch)
* **Libraries:** `google_fonts`, `uuid`, `fl_chart`

---

## 🏗 Cấu trúc Thư mục (Folder Structure)
Dự án tuân thủ mô hình **MVC / Service-Oriented**:
* `lib/models/`: Định nghĩa kiểu dữ liệu (Student).
* `lib/views/`: Giao diện màn hình chính, chi tiết, thêm mới.
* `lib/widgets/`: Các thành phần giao diện dùng chung (Card, Button).
* `lib/providers/`: Quản lý trạng thái và luồng dữ liệu toàn app.
* `lib/services/`: Xử lý kết nối API / Firebase.

---

## 📝 Quy tắc cho Thành viên (Team Guidelines)
Để dự án chạy mượt mà, mọi thành viên vui lòng tuân thủ:

1.  **Sử dụng Agent (AI):** Luôn cung cấp file `student.dart` và `student_provider.dart` cho AI trước khi yêu cầu gen code để đảm bảo đồng bộ tên biến.
2.  **Git Workflow:**
    * KHÔNG push trực tiếp lên `main`.
    * Tạo nhánh riêng: `feature/ten-tinh-nang` để làm việc.
    * Gửi Pull Request để trưởng nhóm review trước khi gộp code.
3.  **UI/UX:** Sử dụng bảng màu `ThemeData` đã định nghĩa trong `main.dart`.

---

## 🚀 Hướng dẫn Chạy ứng dụng
1.  Clone repo: `git clone [URL_Repo]`
2.  Cài đặt thư viện: `flutter pub get`
3.  Chạy app: `flutter run`