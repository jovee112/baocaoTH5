import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../providers/student_provider.dart';
import '../widgets/student_card.dart';
import 'add_student_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final students = studentProvider.students;
    final stats = _GpaStats.from(students);

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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: _StatsSection(stats: stats),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Danh sách sinh viên',
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
          else if (students.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('Không có sinh viên phù hợp'),
              ),
            )
          else
            SliverList.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                return StudentCard(student: students[index]);
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
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
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
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
