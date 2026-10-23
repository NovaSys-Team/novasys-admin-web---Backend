import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/students_controller.dart';
import 'student_styles.dart';

class StudentsTable extends StatelessWidget {
  const StudentsTable({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StudentsController>();
    Widget cell(Widget child, int flex) => Expanded(flex: flex, child: child);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: DesignTokens.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: constraints.maxWidth < 650 ? 650 : constraints.maxWidth,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: SizedBox(
                      height: 27,
                      child: Row(
                        children: [
                          for (final column in [
                            ('Student', 32),
                            ('School', 16),
                            ('Assigned vehicle', 28),
                            ('Fee', 13),
                            ('Today', 13),
                          ])
                            cell(
                              Text(
                                column.$1,
                                style: studentMuted.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              column.$2,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (controller.visibleStudents.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.person_search_outlined,
                            color: DesignTokens.mutedText,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text('No students found'),
                          const Text(
                            'Try another search or clear the filters.',
                            style: studentMuted,
                          ),
                          TextButton(
                            onPressed: controller.reset,
                            child: const Text('Clear filters'),
                          ),
                        ],
                      ),
                    ),
                  for (final student in controller.visibleStudents)
                    Semantics(
                      selected: controller.selected?.id == student.id,
                      button: true,
                      child: Material(
                        color: controller.selected?.id == student.id
                            ? const Color(0xFFE5F4F2)
                            : Colors.white,
                        child: InkWell(
                          key: ValueKey('student-${student.id}'),
                          onTap: () => controller.select(student.id),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 61),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFF0F4F3)),
                              ),
                            ),
                            child: Row(
                              children: [
                                cell(
                                  Row(
                                    children: [
                                      StudentAvatar(student),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                height: 1.1,
                                                fontWeight: FontWeight.w600,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                            Text(
                                              'Grade ${student.grade}',
                                              style: studentMuted,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  32,
                                ),
                                cell(
                                  Text(
                                    student.school,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  16,
                                ),
                                cell(
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.plate ?? 'No vehicle',
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.2,
                                          fontWeight: FontWeight.w600,
                                          color: student.hasVehicle
                                              ? DesignTokens.text
                                              : const Color(0xFFC73813),
                                        ),
                                      ),
                                      Text(
                                        student.hasVehicle
                                            ? student.driver
                                            : 'Request pending · ${student.driver}',
                                        style: studentMuted,
                                      ),
                                    ],
                                  ),
                                  28,
                                ),
                                cell(StudentFeeBadge(student.fee), 13),
                                cell(
                                  Text(
                                    student.today,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: switch (student.today) {
                                        'At school' => const Color(0xFF008639),
                                        'Absent PM' => const Color(0xFFC73813),
                                        'On the bus' => DesignTokens.primary,
                                        _ => DesignTokens.mutedText,
                                      },
                                    ),
                                  ),
                                  13,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
