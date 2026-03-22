# 🎓 Student Manager App - Bài thực hành 5

Ứng dụng quản lý sinh viên được xây dựng bằng **Flutter** (Material 3), dùng `Provider` để quản lý trạng thái, lưu trữ dữ liệu sinh viên trên Firebase/Firestore và (tùy chọn) Supabase để lưu avatar.

---

**Ngôn ngữ:** Dart

---

**Mục tiêu README này:** mô tả cấu trúc thư mục chính và hướng dẫn nhanh các bước cấu hình + chạy dự án trên Windows (cũng áp dụng cho macOS/Linux với các lệnh tương ứng).

---

**Yêu cầu trước khi chạy**
- Cài đặt Flutter SDK và thiết lập Android SDK/Emulator: kiểm tra bằng `flutter doctor`.
- Thiết lập biến môi trường cho Android (`ANDROID_HOME`/`ANDROID_SDK_ROOT`) nếu cần.
- Đặt `google-services.json` vào `android/app/` nếu bạn dùng Firebase Android.
- (Tùy chọn) Thêm `GoogleService-Info.plist` cho iOS theo hướng dẫn nếu chạy trên iOS.
- Nếu dùng Supabase cho avatar, tạo file cấu hình `lib/supabase_config.dart` và đặt `supabaseUrl`, `supabaseAnonKey`, `supabaseAvatarBucket` (KHÔNG commit khóa bí mật).

---

**Cấu trúc thư mục chính**
- `lib/`
    - `main.dart`: Entry của app, cấu hình Theme và route khởi tạo (Welcome/Dashboard).
    - `firebase_options.dart`: (auto-generated) cấu hình Firebase (nếu có).
    - `models/`: các model Dart (ví dụ `student.dart`).
    - `providers/`: lớp `ChangeNotifier` quản lý trạng thái (ví dụ `student_provider.dart`).
    - `services/`: mã tương tác với backend (ví dụ `firebase_service.dart`, `supabase_service.dart`).
    - `views/`: các màn hình UI (ví dụ `add_student_screen.dart`, `dashboard_screen.dart`, `welcome_screen.dart`).
    - `widgets/`: component UI tái sử dụng (ví dụ `student_card.dart`).
    - `utils/`: hàm tiện ích và validator.

- `android/`, `ios/`, `windows/`, `linux/`, `macos/`, `web/`: các thư mục nền tảng do Flutter tạo.
- `build/`: output build (không commit).

---

**Hướng dẫn cài đặt & chạy (Windows)**

1. Lấy mã nguồn và cài phụ thuộc:

```powershell
git clone <URL_REPO>
cd quan_ly_sinh_vien
flutter pub get
```

2. Kiểm tra môi trường Flutter:

```powershell
flutter doctor
```

3. Chạy trên thiết bị Android (đã bật emulator hoặc kết nối thiết bị):

```powershell
flutter devices
flutter run -d emulator-5554
```

Hoặc chạy trên web (mặc định Chrome/Edge):

```powershell
flutter run -d edge
```

4. Build APK (Android release):

```powershell
flutter build apk --release
```

5. Chạy trên Windows Desktop (nếu hỗ trợ):

```powershell
flutter config --enable-windows-desktop
flutter run -d windows
```

---

**Cấu hình Firebase & Supabase (tóm tắt)**
- Firebase: thêm `google-services.json` vào `android/app/` và (nếu cần) `GoogleService-Info.plist` cho iOS. Chạy `flutter pub get` và khởi động lại IDE nếu cần.
- Supabase: tạo bucket (ví dụ `avatars`) và thêm cài đặt môi trường vào `lib/supabase_config.dart` (GIỮ bí mật ra khỏi repo). Ví dụ nội dung file (không commit keys):

```dart
// lib/supabase_config.dart (local copy, đừng commit keys)
const supabaseUrl = 'https://your-project.supabase.co';
const supabaseAnonKey = '<ANON_KEY_PLACEHOLDER>';
const supabaseAvatarBucket = 'avatars';
```

Lưu ý bảo mật: nếu cần upload an toàn từ client, cấu hình Row-Level Security hoặc sử dụng backend service role.

---

**Tips phát triển**
- Dùng nhánh feature: `feature/<ten>` rồi tạo PR lên `main` để review.
- Chạy `flutter analyze` để kiểm tra lint và `flutter format` để format code.
- Ghi chú: có các validator và kiểm tra trùng email/MSSV trong `lib/views/add_student_screen.dart`.

---

Nếu bạn muốn, tôi có thể: thêm script chạy nhanh (PowerShell) hoặc tạo template `lib/supabase_config.example.dart` để dễ cấu hình mà không commit key thật.
