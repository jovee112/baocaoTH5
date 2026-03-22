import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../providers/student_provider.dart';
import '../widgets/student_card.dart';
import '../constants/faculties_and_majors.dart';
import 'add_student_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFaculty;
  String? _selectedClass;
  String? _selectedMajor;
  String? _selectedPerformance; // Xuất sắc, Giỏi, Khá, Trung bình

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Student> _applyFilters(List<Student> students) {
    return students.where((student) {
      // Lọc theo khoa
      if (_selectedFaculty != null && student.faculty != _selectedFaculty) {
        return false;
      }

      // Lọc theo lớp
      if (_selectedClass != null && student.className != _selectedClass) {
        return false;
      }

      // Lọc theo ngành
      if (_selectedMajor != null && student.major != _selectedMajor) {
        return false;
      }

      // Lọc theo loại học lực
      if (_selectedPerformance != null) {
        switch (_selectedPerformance) {
          case 'Xuất sắc':
            if (student.gpa < 3.6) return false;
            break;
          case 'Giỏi':
            if (student.gpa < 3.2 || student.gpa >= 3.6) return false;
            break;
          case 'Khá':
            if (student.gpa < 2.5 || student.gpa >= 3.2) return false;
            break;
          case 'Trung bình':
            if (student.gpa >= 2.5) return false;
            break;
        }
      }

      return true;
    }).toList();
  }

  Set<String> _getAvailableClasses(List<Student> students) {
    return students.map((s) => s.className).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final allStudents = studentProvider.students;
    final filteredStudents = _applyFilters(allStudents);
    final stats = _GpaStats.from(filteredStudents);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddStudentScreen(),
            ),
          );
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Thêm sinh viên'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            floating: false,
            centerTitle: true,
            title: const Text('Dashboard Sinh viên'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 90, 20, 16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Tổng hợp & Thống kê học lực',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Tìm theo tên hoặc MSSV...',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _searchController.clear();
                        context.read<StudentProvider>().searchStudent('');
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    ),
                ],
                onChanged: (value) {
                  context.read<StudentProvider>().searchStudent(value);
                  setState(() {});
                },
              ),
            ),
          ),
          // Filters Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Filter by Faculty
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Khoa'),
                        avatar: _selectedFaculty != null
                            ? const Icon(Icons.school)
                            : null,
                        onSelected: (selected) {
                          if (!selected) {
                            setState(() => _selectedFaculty = null);
                          } else {
                            _showFacultyFilter();
                          }
                        },
                        selected: _selectedFaculty != null,
                      ),
                    ),
                    // Filter by Class
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Lớp'),
                        avatar: _selectedClass != null
                            ? const Icon(Icons.class_)
                            : null,
                        onSelected: (selected) {
                          if (!selected) {
                            setState(() => _selectedClass = null);
                          } else {
                            _showClassFilter(_getAvailableClasses(allStudents));
                          }
                        },
                        selected: _selectedClass != null,
                      ),
                    ),
                    // Filter by Major
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Ngành'),
                        avatar: _selectedMajor != null
                            ? const Icon(Icons.business_center)
                            : null,
                        onSelected: (selected) {
                          if (!selected) {
                            setState(() => _selectedMajor = null);
                          } else {
                            _showMajorFilter();
                          }
                        },
                        selected: _selectedMajor != null,
                      ),
                    ),
                    // Filter by Performance
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Học lực'),
                        avatar: _selectedPerformance != null
                            ? const Icon(Icons.grade)
                            : null,
                        onSelected: (selected) {
                          if (!selected) {
                            setState(() => _selectedPerformance = null);
                          } else {
                            _showPerformanceFilter();
                          }
                        },
                        selected: _selectedPerformance != null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Display selected filters
          if (_selectedFaculty != null ||
              _selectedClass != null ||
              _selectedMajor != null ||
              _selectedPerformance != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (_selectedFaculty != null)
                      Chip(
                        label: Text('Khoa: $_selectedFaculty'),
                        onDeleted: () =>
                            setState(() => _selectedFaculty = null),
                      ),
                    if (_selectedClass != null)
                      Chip(
                        label: Text('Lớp: $_selectedClass'),
                        onDeleted: () =>
                            setState(() => _selectedClass = null),
                      ),
                    if (_selectedMajor != null)
                      Chip(
                        label: Text('Ngành: $_selectedMajor'),
                        onDeleted: () =>
                            setState(() => _selectedMajor = null),
                      ),
                    if (_selectedPerformance != null)
                      Chip(
                        label: Text('Học lực: $_selectedPerformance'),
                        onDeleted: () =>
                            setState(() => _selectedPerformance = null),
                      ),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _StatsSection(stats: stats),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Danh sách sinh viên (${filteredStudents.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          if (studentProvider.isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (studentProvider.errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(studentProvider.errorMessage!),
              ),
            )
          else if (filteredStudents.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('Không có sinh viên phù hợp'),
              ),
            )
          else
            SliverList.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                return StudentCard(student: filteredStudents[index]);
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showFacultyFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn khoa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: FacultyData.faculties.map((faculty) {
              return ListTile(
                title: Text(faculty),
                trailing: _selectedFaculty == faculty
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() => _selectedFaculty = faculty);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showClassFilter(Set<String> availableClasses) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn lớp'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableClasses.map((className) {
              return ListTile(
                title: Text(className),
                trailing: _selectedClass == className
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() => _selectedClass = className);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showMajorFilter() {
    final allMajors = <String>[];
    for (var majors in FacultyData.majorsByFaculty.values) {
      allMajors.addAll(majors.map((m) => m.name));
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngành'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: allMajors.map((major) {
              return ListTile(
                title: Text(major),
                trailing: _selectedMajor == major
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() => _selectedMajor = major);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showPerformanceFilter() {
    const performances = ['Xuất sắc', 'Giỏi', 'Khá', 'Trung bình'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn loại học lực'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: performances.map((performance) {
              return ListTile(
                title: Text(performance),
                trailing: _selectedPerformance == performance
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() => _selectedPerformance = performance);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.stats});

  final _GpaStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biểu đồ học lực',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 56,
                        startDegreeOffset: -90,
                        sections: _buildSections(theme, stats),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${stats.total}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sinh viên',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _LegendChip(
                  color: Colors.green,
                  label: 'Xuất sắc (>=3.6): ${stats.excellent}',
                ),
                _LegendChip(
                  color: Colors.blue,
                  label: 'Giỏi (3.2-3.5): ${stats.good}',
                ),
                _LegendChip(
                  color: Colors.orange,
                  label: 'Khá (2.5-3.1): ${stats.fair}',
                ),
                _LegendChip(
                  color: Colors.red,
                  label: 'Trung bình (<2.5): ${stats.average}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(ThemeData theme, _GpaStats stats) {
    final data = <({int count, Color color})>[
      (count: stats.excellent, color: Colors.green),
      (count: stats.good, color: Colors.blue),
      (count: stats.fair, color: Colors.orange),
      (count: stats.average, color: Colors.red),
    ];

    if (stats.total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: theme.colorScheme.outlineVariant,
          title: '',
          radius: 36,
        ),
      ];
    }

    return data
        .where((item) => item.count > 0)
        .map(
          (item) => PieChartSectionData(
            value: item.count.toDouble(),
            color: item.color,
            title: '${(item.count / stats.total * 100).toStringAsFixed(0)}%',
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            radius: 44,
          ),
        )
        .toList();
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(backgroundColor: color, radius: 7),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _GpaStats {
  const _GpaStats({
    required this.excellent,
    required this.good,
    required this.fair,
    required this.average,
  });

  final int excellent;
  final int good;
  final int fair;
  final int average;

  int get total => excellent + good + fair + average;

  factory _GpaStats.from(List<Student> students) {
    int excellent = 0;
    int good = 0;
    int fair = 0;
    int average = 0;

    for (final student in students) {
      final gpa = student.gpa;
      if (gpa >= 3.6) {
        excellent++;
      } else if (gpa >= 3.2) {
        good++;
      } else if (gpa >= 2.5) {
        fair++;
      } else {
        average++;
      }
    }

    return _GpaStats(
      excellent: excellent,
      good: good,
      fair: fair,
      average: average,
    );
  }
}
