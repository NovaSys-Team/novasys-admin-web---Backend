import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../models/report_document.dart';

bool downloadReportDocument(ReportDocument document) {
  final blob = web.Blob(
    [document.bytes.toJS].toJS,
    web.BlobPropertyBag(type: document.mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = document.filename;
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  // Allow the browser to consume the object URL before releasing it.
  Future<void>.delayed(
    const Duration(seconds: 1),
    () => web.URL.revokeObjectURL(url),
  );
  return true;
}
