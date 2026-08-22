/// Tracks the progress of a service job through the technician flow.
class ServiceProgress {

  ServiceProgress({
    required this.requestId,
    required this.acceptedAt,
    this.drivingAt,
    this.arrivedAt,
    this.workingAt,
    this.finishedAt,
    this.completedAt,
    this.notes,
    this.totalAmount,
  });
  final String requestId;
  final DateTime acceptedAt;
  DateTime? drivingAt;
  DateTime? arrivedAt;
  DateTime? workingAt;
  DateTime? finishedAt;
  DateTime? completedAt;
  String? notes;
  double? totalAmount;
}
