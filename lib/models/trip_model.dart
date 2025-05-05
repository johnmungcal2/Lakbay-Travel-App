class Trip {
  final String tripName;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String? firebaseKey;

  Trip({
    required this.tripName,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.description,
    this.firebaseKey,
  });
}
