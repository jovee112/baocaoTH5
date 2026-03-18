/// Capitalize tên: viết hoa chữ cái đầu của TỪNG chữ, loại bỏ multiple spaces
/// Ví dụ: 
/// - "nguyen van a" -> "Nguyen Van A"
/// - "trần thị  b" (2 spaces) -> "Trần Thị B"
/// - "  pham chi linh  " -> "Pham Chi Linh"
String capitalizeName(String name) {
  if (name.isEmpty) return name;
  
  // Trim khoảng trắng ở đầu và cuối
  var trimmedName = name.trim();
  
  // Split theo space và filter các chuỗi rỗng (từ multiple spaces)
  final words = trimmedName.split(' ').where((word) => word.isNotEmpty).toList();
  
  // Capitalize từng từ
  final capitalizedWords = words.map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).toList();
  
  // Join với 1 space
  return capitalizedWords.join(' ');
}

/// Generate Student ID (MSV) tự động dựa trên thời gian hiện tại
/// Format: MMDDHHmmss (10 số)
/// Ví dụ: "0318211002" = 03(tháng) + 18(ngày) + 21(giờ) + 10(phút) + 02(giây)
String generateStudentId() {
  final now = DateTime.now();
  
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  final hour = now.hour.toString().padLeft(2, '0');
  final minute = now.minute.toString().padLeft(2, '0');
  final second = now.second.toString().padLeft(2, '0');
  
  return '$month$day$hour$minute$second';
}
