import 'job_status.dart';

/// Represents a service request shown to the technician.
class TechnicianRequest {

  TechnicianRequest({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.serviceType,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.description,
    required this.distanceKm,
    required this.requestTime,
    required this.latitude,
    required this.longitude,
    this.status = JobStatus.pending,
  });
  final String id;
  final String customerName;
  final String customerPhone;
  final String serviceType;
  final String vehicleName;
  final String vehiclePlate;
  final String description;
  final double distanceKm;
  final DateTime requestTime;
  final double latitude;
  final double longitude;
  JobStatus status;
}
