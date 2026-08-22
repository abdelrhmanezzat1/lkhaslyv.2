/// Represents the status of a service request/job.
enum JobStatus {
  pending,
  accepted,
  driving,
  arrived,
  working,
  finished,
  completed,
  rejected,
}

/// Extension providing display labels and ordering for [JobStatus].
extension JobStatusExtension on JobStatus {
  String get label {
    switch (this) {
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.accepted:
        return 'Accepted';
      case JobStatus.driving:
        return 'On The Way';
      case JobStatus.arrived:
        return 'Arrived';
      case JobStatus.working:
        return 'In Progress';
      case JobStatus.finished:
        return 'Finished';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.rejected:
        return 'Rejected';
    }
  }

  String get dbValue {
    switch (this) {
      case JobStatus.pending:
        return 'pending';
      case JobStatus.accepted:
        return 'accepted';
      case JobStatus.driving:
        return 'on_the_way';
      case JobStatus.arrived:
        return 'arrived';
      case JobStatus.working:
        return 'working';
      case JobStatus.finished:
        return 'finished';
      case JobStatus.completed:
        return 'completed';
      case JobStatus.rejected:
        return 'rejected';
    }
  }

  int get order {
    switch (this) {
      case JobStatus.pending:
        return 0;
      case JobStatus.accepted:
        return 1;
      case JobStatus.driving:
        return 2;
      case JobStatus.arrived:
        return 3;
      case JobStatus.working:
        return 4;
      case JobStatus.finished:
        return 5;
      case JobStatus.completed:
        return 6;
      case JobStatus.rejected:
        return -1;
    }
  }

  bool get isActive =>
      this != JobStatus.completed && this != JobStatus.rejected;

  static JobStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return JobStatus.pending;
      case 'accepted':
        return JobStatus.accepted;
      case 'driving':
      case 'on_the_way':
      case 'technician_on_the_way':
      case 'technician on the way':
        return JobStatus.driving;
      case 'arrived':
        return JobStatus.arrived;
      case 'working':
      case 'in_progress':
      case 'in progress':
        return JobStatus.working;
      case 'finished':
        return JobStatus.finished;
      case 'completed':
        return JobStatus.completed;
      case 'cancelled':
      case 'rejected':
        return JobStatus.rejected;
      default:
        return JobStatus.pending;
    }
  }
}
