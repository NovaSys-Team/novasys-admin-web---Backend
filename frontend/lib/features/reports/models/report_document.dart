import 'dart:convert';
import 'dart:typed_data';

import 'report.dart';

/// Small, self-contained local exports. Excel uses the XML Spreadsheet format.
class ReportDocument {
  const ReportDocument(this.bytes, this.filename, this.mimeType);
  final Uint8List bytes;
  final String filename, mimeType;

  factory ReportDocument.fromReport(GeneratedReport report) {
    final table = [report.headers, ...report.rows];
    final title = 'MOCK DATA - NovaSys ${report.type.label}';
    final scope = '${report.period} | ${report.school ?? 'All schools'}';
    final bytes = switch (report.format) {
      ReportFormat.csv => Uint8List.fromList(
        utf8.encode(
          [
                [title],
                [scope],
                ...table,
              ]
              .map(
                (row) => row
                    .map((cell) => '"${cell.replaceAll('"', '""')}"')
                    .join(','),
              )
              .join('\r\n'),
        ),
      ),
      ReportFormat.excel => Uint8List.fromList(
        utf8.encode(
          _spreadsheet([
            [title],
            [scope],
            ...table,
          ]),
        ),
      ),
      ReportFormat.pdf => _pdf([
        title,
        scope,
        '',
        ...table.map((row) => row.join(' | ')),
      ]),
    };
    return ReportDocument(bytes, report.filename, report.format.mimeType);
  }
}

String _spreadsheet(List<List<String>> rows) {
  String escape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
  return '<?xml version="1.0" encoding="UTF-8"?>'
      '<?mso-application progid="Excel.Sheet"?>'
      '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">'
      '<Worksheet ss:Name="Mock report"><Table>'
      '${rows.map((row) => '<Row>${row.map((cell) => '<Cell><Data ss:Type="String">${escape(cell)}</Data></Cell>').join()}</Row>').join()}'
      '</Table></Worksheet></Workbook>';
}

Uint8List _pdf(List<String> lines) {
  // ASCII built-in Helvetica keeps the PDF portable without font dependencies.
  String escape(String s) => s
      .replaceAll('–', '-')
      .replaceAll('·', '-')
      .replaceAll('’', "'")
      .replaceAll(RegExp(r'[^\x20-\x7e]'), '?')
      .replaceAll(r'\', r'\\')
      .replaceAll('(', r'\(')
      .replaceAll(')', r'\)');
  final wrapped = <String>[];
  for (final line in lines) {
    if (line.isEmpty) wrapped.add('');
    for (var i = 0; i < line.length; i += 145) {
      wrapped.add(
        line.substring(i, i + 145 > line.length ? line.length : i + 145),
      );
    }
  }
  final pages = <List<String>>[];
  for (var i = 0; i < wrapped.length; i += 43) {
    pages.add(
      wrapped.sublist(i, i + 43 > wrapped.length ? wrapped.length : i + 43),
    );
  }
  final objects = <String>[
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Count ${pages.length} /Kids [${List.generate(pages.length, (i) => '${4 + i * 2} 0 R').join(' ')}] >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
  ];
  for (var i = 0; i < pages.length; i++) {
    final stream =
        'BT /F1 8 Tf 12 TL 30 560 Td\n${pages[i].map((line) => '(${escape(line)}) Tj T*').join('\n')}\nET';
    objects.add(
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 842 595] /Resources << /Font << /F1 3 0 R >> >> /Contents ${5 + i * 2} 0 R >>',
    );
    objects.add('<< /Length ${stream.length} >>\nstream\n$stream\nendstream');
  }
  final output = StringBuffer('%PDF-1.4\n');
  final offsets = <int>[0];
  for (var i = 0; i < objects.length; i++) {
    offsets.add(output.length);
    output.write('${i + 1} 0 obj\n${objects[i]}\nendobj\n');
  }
  final xref = output.length;
  output.write('xref\n0 ${objects.length + 1}\n0000000000 65535 f \n');
  for (final offset in offsets.skip(1)) {
    output.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
  }
  output.write(
    'trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\nstartxref\n$xref\n%%EOF\n',
  );
  return Uint8List.fromList(ascii.encode(output.toString()));
}
