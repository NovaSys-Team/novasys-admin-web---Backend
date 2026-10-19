enum ApplicationStatus { pending, reuploadRequested, verified, rejected }

enum DocumentStatus { valid, unreadable, expiring }

enum ApplicationFilter {
  all,
  pending,
  ready,
  issues,
  verified,
  rejected,
  reuploadRequested,
}

enum VerificationDecision { approve, reject, requestReupload }

class DriverDocument {
  const DriverDocument({
    required this.id,
    required this.name,
    required this.scanLabel,
    required this.status,
    required this.statusText,
  });
  final String id;
  final String name;
  final String scanLabel;
  final DocumentStatus status;
  final String statusText;
  bool get passes => status == DocumentStatus.valid;
}

class DriverApplication {
  const DriverApplication({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarIndex,
    required this.subtitle,
    required this.phone,
    required this.nic,
    required this.vehicle,
    required this.serviceArea,
    required this.applied,
    required this.documents,
    this.status = ApplicationStatus.pending,
    this.note = '',
    this.decisionNote,
  });
  final String id;
  final String name;
  final String initials;
  final int avatarIndex;
  final String subtitle;
  final String phone;
  final String nic;
  final String vehicle;
  final String serviceArea;
  final String applied;
  final List<DriverDocument> documents;
  final ApplicationStatus status;
  final String note;
  final String? decisionNote;
  bool get isFinal =>
      status == ApplicationStatus.verified ||
      status == ApplicationStatus.rejected;
  bool get documentsPass =>
      documents.isNotEmpty && documents.every((doc) => doc.passes);
  bool get canApprove => status == ApplicationStatus.pending && documentsPass;
  String get listStatus => switch (status) {
    ApplicationStatus.verified => 'VERIFIED',
    ApplicationStatus.rejected => 'Rejected',
    ApplicationStatus.reuploadRequested => 'Re-upload requested',
    ApplicationStatus.pending => documentsPass ? 'Ready' : 'Issues',
  };
  String get detailStatus => switch (status) {
    ApplicationStatus.verified => 'VERIFIED',
    ApplicationStatus.rejected => 'REJECTED',
    ApplicationStatus.reuploadRequested => 'RE-UPLOAD REQUESTED',
    ApplicationStatus.pending => 'PENDING REVIEW',
  };
  DriverApplication copyWith({
    ApplicationStatus? status,
    String? note,
    String? decisionNote,
  }) => DriverApplication(
    id: id,
    name: name,
    initials: initials,
    avatarIndex: avatarIndex,
    subtitle: subtitle,
    phone: phone,
    nic: nic,
    vehicle: vehicle,
    serviceArea: serviceArea,
    applied: applied,
    documents: documents,
    status: status ?? this.status,
    note: note ?? this.note,
    decisionNote: decisionNote ?? this.decisionNote,
  );
}

extension ApplicationFilterLabel on ApplicationFilter {
  String get label => switch (this) {
    ApplicationFilter.all => 'All applications',
    ApplicationFilter.pending => 'Pending review',
    ApplicationFilter.ready => 'Ready to approve',
    ApplicationFilter.issues => 'Document issues',
    ApplicationFilter.verified => 'Verified',
    ApplicationFilter.rejected => 'Rejected',
    ApplicationFilter.reuploadRequested => 'Re-upload requested',
  };
}

extension VerificationDecisionLabel on VerificationDecision {
  String get label => switch (this) {
    VerificationDecision.approve => 'Approve driver',
    VerificationDecision.reject => 'Reject',
    VerificationDecision.requestReupload => 'Request re-upload',
  };
  String get pastTense => switch (this) {
    VerificationDecision.approve => 'approved',
    VerificationDecision.reject => 'rejected',
    VerificationDecision.requestReupload => 'marked for re-upload',
  };
}
