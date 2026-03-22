// Dữ liệu các khoa, ngành và viết tắt
class FacultyData {
  static const List<String> faculties = [
    'Công nghệ thông tin',
    'Cơ khí',
    'Điện – Điện tử',
    'Công trình',
    'Kỹ thuật tài nguyên nước',
    'Hóa và môi trường',
    'Kinh tế và quản lý',
    'Kế toán và kinh doanh',
    'Luật và Lý luận chính trị',
    'Trung tâm Đào tạo quốc tế',
  ];

  static const Map<String, List<MajorData>> majorsByFaculty = {
    'Công nghệ thông tin': [
      MajorData('Công nghệ thông tin', 'CNTT'),
      MajorData('Hệ thống thông tin', 'HTTT'),
      MajorData('Kỹ thuật phần mềm', 'KTPM'),
      MajorData('An ninh mạng', 'ANM'),
      MajorData('Trí tuệ nhân tạo và khoa học dữ liệu', 'TTNT'),
    ],
    'Cơ khí': [
      MajorData('Công nghệ chế tạo máy', 'CNCTM'),
      MajorData('Kỹ thuật cơ khí', 'KTCK'),
      MajorData('Kỹ thuật cơ điện tử', 'KTCDT'),
      MajorData('Kỹ thuật ô tô', 'KTOT'),
    ],
    'Điện – Điện tử': [
      MajorData('Kỹ thuật điện', 'KTD'),
      MajorData('Kỹ thuật điện tử – viễn thông', 'KTVT'),
      MajorData('Kỹ thuật điều khiển và tự động hóa', 'KTKTVT'),
      MajorData('Kỹ thuật Robot và điều khiển thông minh', 'KTRDK'),
    ],
    'Công trình': [
      MajorData('Kỹ thuật xây dựng công trình thủy', 'KYXDCT'),
      MajorData('Kỹ thuật xây dựng', 'KYXD'),
      MajorData('Kỹ thuật xây dựng công trình giao thông', 'KYXDCGT'),
      MajorData('Công nghệ kỹ thuật xây dựng', 'CNKYXD'),
      MajorData('Quản lý xây dựng', 'QLXD'),
    ],
    'Kỹ thuật tài nguyên nước': [
      MajorData('Kỹ thuật cấp thoát nước', 'KTCTN'),
      MajorData('Kỹ thuật cơ sở hạ tầng', 'KTCS'),
      MajorData('Kỹ thuật tài nguyên nước', 'KTTNN'),
      MajorData('Thuỷ văn học', 'TVH'),
    ],
    'Hóa và môi trường': [
      MajorData('Kỹ thuật môi trường', 'KTMT'),
      MajorData('Kỹ thuật hóa học', 'KTHH'),
      MajorData('Công nghệ sinh học', 'CNSH'),
    ],
    'Kinh tế và quản lý': [
      MajorData('Kinh tế xây dựng', 'KTXD'),
      MajorData('Kinh tế', 'KT'),
      MajorData('Kinh tế số', 'KTS'),
      MajorData('Logistics và quản lý chuỗi cung ứng', 'LGC'),
      MajorData('Quản trị dịch vụ du lịch và lữ hành', 'QTDV'),
      MajorData('Thương mại điện tử', 'TMDT'),
    ],
    'Kế toán và kinh doanh': [
      MajorData('Quản trị kinh doanh', 'QTKD'),
      MajorData('Kế toán', 'KT'),
      MajorData('Kiểm toán', 'KTA'),
      MajorData('Tài chính – ngân hàng', 'TCNH'),
    ],
    'Luật và Lý luận chính trị': [
      MajorData('Luật', 'L'),
      MajorData('Luật kinh tế', 'LKT'),
    ],
    'Trung tâm Đào tạo quốc tế': [
      MajorData('Ngôn ngữ Anh', 'NNA'),
      MajorData('Ngôn ngữ Trung Quốc', 'NNTQ'),
      MajorData('Kỹ thuật xây dựng (Chương trình tiên tiến)', 'KYXDCT'),
      MajorData('Kỹ thuật tài nguyên nước (Chương trình tiên tiến)', 'KTTNN'),
    ],
  };

  static List<String> getMajorsByFaculty(String faculty) {
    return majorsByFaculty[faculty]?.map((m) => m.name).toList() ?? [];
  }

  static String? getMajorAbbreviation(String faculty, String majorName) {
    final majors = majorsByFaculty[faculty];
    if (majors == null) return null;
    
    final major = majors.firstWhere(
      (m) => m.name == majorName,
      orElse: () => const MajorData('', ''),
    );
    
    return major.abbreviation.isNotEmpty ? major.abbreviation : null;
  }
}

class MajorData {
  final String name;
  final String abbreviation;

  const MajorData(this.name, this.abbreviation);
}
