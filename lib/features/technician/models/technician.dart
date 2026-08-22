/// Represents a technician profile used locally for the technician flow.
class Technician {

  Technician({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.rating = 4.5,
    this.completedJobs = 0,
    this.isOnline = true,
  });
  final String id;
  final String name;
  final String email;
  final String phone;
  final double rating;
  int completedJobs;
  bool isOnline;
}
