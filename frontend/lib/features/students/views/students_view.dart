import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/page_container.dart';
import '../controllers/students_controller.dart';
import '../models/student.dart';
import '../widgets/student_details.dart';
import '../widgets/student_dialogs.dart';
import '../widgets/student_styles.dart';
import '../widgets/students_table.dart';

class StudentsView extends StatelessWidget {
  const StudentsView({super.key});
  static const title = 'Students';
  @override
  Widget build(BuildContext context) => PageContainer(
    child: LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (constraints.maxWidth < DesignTokens.compactPageHeaderWidth) ...[
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            Text(
              context.watch<StudentsController>().subtitle,
              style: const TextStyle(color: DesignTokens.mutedText),
            ),
            const SizedBox(height: 16),
          ],
          const _StudentControls(),
          const SizedBox(height: 18),
          if (constraints.maxWidth >= 1050)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 62, child: StudentsTable()),
                SizedBox(width: 16),
                Expanded(flex: 38, child: StudentDetails()),
              ],
            )
          else ...[
            const StudentsTable(),
            const SizedBox(height: 16),
            const StudentDetails(),
          ],
        ],
      ),
    ),
  );
}

class StudentsHeaderActions extends StatelessWidget {
  const StudentsHeaderActions({super.key});
  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: studentButtonStyle(),
    onPressed: () =>
        showStudentExport(context, context.read<StudentsController>()),
    child: const Text('Export list'),
  );
}

class _StudentControls extends StatefulWidget {
  const _StudentControls();
  @override
  State<_StudentControls> createState() => _StudentControlsState();
}

class _StudentControlsState extends State<_StudentControls> {
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StudentsController>();
    if (_search.text != controller.query) {
      _search.value = TextEditingValue(
        text: controller.query,
        selection: TextSelection.collapsed(offset: controller.query.length),
      );
    }
    final search = TextField(
      key: const ValueKey('students-search'),
      controller: _search,
      onChanged: controller.search,
      decoration: InputDecoration(
        hintText: 'Search student, parent or plate',
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF8A9E9B)),
        prefixIcon: const Icon(Icons.search, size: 19),
        suffixIcon: controller.query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () => controller.search(''),
                icon: const Icon(Icons.close, size: 18),
              ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DesignTokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DesignTokens.border),
        ),
      ),
    );
    final school = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('School', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: DesignTokens.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: const ValueKey('students-school'),
              value: controller.school ?? '',
              style: const TextStyle(
                color: DesignTokens.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('All schools')),
                ...controller.schools.map(
                  (s) => DropdownMenuItem(value: s, child: Text(s)),
                ),
              ],
              onChanged: (value) =>
                  controller.setSchool(value == '' ? null : value),
            ),
          ),
        ),
      ],
    );
    final filters = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFECF1F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 2,
        children: [
          for (final entry in [
            (StudentFilter.all, 'All'),
            (StudentFilter.feesDue, 'Fees due'),
            (StudentFilter.noVehicle, 'No vehicle'),
          ])
            Semantics(
              selected: controller.filter == entry.$1,
              child: TextButton(
                key: ValueKey('students-filter-${entry.$1.name}'),
                style: TextButton.styleFrom(
                  backgroundColor: controller.filter == entry.$1
                      ? Colors.white
                      : Colors.transparent,
                  foregroundColor: controller.filter == entry.$1
                      ? DesignTokens.text
                      : DesignTokens.mutedText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                onPressed: () => controller.setFilter(entry.$1),
                child: Text(
                  entry.$2,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= 1050
          ? Row(
              children: [
                Expanded(child: search),
                const SizedBox(width: 10),
                school,
                const SizedBox(width: 10),
                filters,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [school, filters],
                ),
              ],
            ),
    );
  }
}
