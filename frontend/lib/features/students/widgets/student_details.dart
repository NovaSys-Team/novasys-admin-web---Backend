import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/students_controller.dart';
import 'student_dialogs.dart';
import 'student_styles.dart';

class StudentDetails extends StatelessWidget {
  const StudentDetails({super.key});
  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentsController>().selected;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DesignTokens.primary, width: 1.5),
      ),
      child: student == null
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Select a student to view their details.'),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    StudentAvatar(student, large: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Grade ${student.grade} · ${student.school}',
                            style: studentMuted.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignTokens.sidebar,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: DesignTokens.primary,
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.directions_bus_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ASSIGNED VEHICLE',
                              style: TextStyle(
                                color: Color(0xFF9FD8CF),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              student.hasVehicle
                                  ? '${student.plate} · ${student.vehicle}'
                                  : 'No vehicle',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              student.hasVehicle
                                  ? '${student.driver} · both trips'
                                  : 'Request pending · ${student.driver}',
                              style: const TextStyle(
                                color: DesignTokens.sidebarText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: DesignTokens.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      for (final pair in [
                        ('Parent', student.parent),
                        ('Phone', student.phone),
                        ('Pickup point', student.pickup),
                        ('Attendance (Oct)', student.attendance),
                        ('Health note', student.health),
                        ('Pickup people', student.pickupPeople),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  pair.$1,
                                  style: const TextStyle(
                                    color: DesignTokens.mutedText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  pair.$2,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        pair.$1 == 'Health note' &&
                                            student.health != 'None reported'
                                        ? const Color(0xFFE00018)
                                        : DesignTokens.text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      style: studentButtonStyle(primary: true),
                      onPressed: () => showVehicleChange(context, student),
                      child: const Text('Change vehicle'),
                    ),
                    OutlinedButton(
                      style: studentButtonStyle(),
                      onPressed: () => showParentMessage(context, student),
                      child: const Text('Message parent'),
                    ),
                    Tooltip(
                      message: student.hasVehicle
                          ? 'View mock trip snapshot'
                          : 'No assigned vehicle to track',
                      child: OutlinedButton(
                        style: studentButtonStyle(),
                        onPressed: student.hasVehicle
                            ? () => showStudentTracking(context, student)
                            : null,
                        child: const Text('Track'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Changing a vehicle is an exception. Both drivers and the parent are notified, with the date it starts.',
                  style: studentMuted,
                ),
              ],
            ),
    );
  }
}
