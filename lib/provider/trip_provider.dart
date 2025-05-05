import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lesson_7/models/trip_model.dart';

class TripNotifier extends StateNotifier<List<Trip>> {
  TripNotifier() : super([]);

  final DatabaseReference _database = FirebaseDatabase.instance.refFromURL(
      'https://lesson-7-a161f-default-rtdb.asia-southeast1.firebasedatabase.app/users');

  // Add a new trip to Firebase for the logged-in user
  Future<void> addTrip(Trip trip) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is logged in!');
    }

    final userId = user.uid;
    final userTripsRef =
        _database.child(userId).push(); // Generate a unique key

    await userTripsRef.set({
      'tripName': trip.tripName,
      'destination': trip.destination,
      'startDate': trip.startDate.toIso8601String(),
      'endDate': trip.endDate.toIso8601String(),
      'description': trip.description,
    });

    // Add the firebaseKey to the trip and update the local state
    final tripWithKey = Trip(
      tripName: trip.tripName,
      destination: trip.destination,
      startDate: trip.startDate,
      endDate: trip.endDate,
      description: trip.description,
      firebaseKey: userTripsRef.key, // Assign the Firebase key
    );

    state = [...state, tripWithKey];
  }

  // Fetch trips from Firebase for the logged-in user
  Future<void> fetchTrips() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is logged in!');
    }

    final userId = user.uid;
    final snapshot = await _database.child(userId).get();

    if (snapshot.exists && snapshot.value != null) {
      final tripsData = snapshot.value as Map<dynamic, dynamic>;
      final trips = tripsData.entries.map((entry) {
        final key = entry.key; // Firebase-generated key
        final data = entry.value;

        return Trip(
          tripName: data['tripName'],
          destination: data['destination'],
          startDate: DateTime.parse(data['startDate']),
          endDate: DateTime.parse(data['endDate']),
          description: data['description'],
          firebaseKey: key, // Assign the Firebase key
        );
      }).toList();

      state = trips;
    } else {
      state = [];
    }
  }

  Future<void> deleteTrip(String tripKey) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is logged in!');
    }

    final userId = user.uid;

    print('Deleting trip with firebaseKey: $tripKey'); // Debug log
    print('User ID: $userId'); // Debug log

    // Delete the trip from Firebase
    await _database.child(userId).child(tripKey).remove();

    print('Trip deleted from Firebase'); // Debug log

    // Also remove it from local state
    state = [
      for (final trip in state)
        if (trip.firebaseKey != tripKey) trip,
    ];

    print('Local state updated'); // Debug log
  }

  Future<void> updateTrip(Trip updatedTrip) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is logged in!');
    }

    final userId = user.uid;

    if (updatedTrip.firebaseKey == null) {
      throw Exception('Trip does not have a Firebase key!');
    }

    final tripRef = _database.child(userId).child(updatedTrip.firebaseKey!);

    // Update the trip in Firebase
    await tripRef.update({
      'tripName': updatedTrip.tripName,
      'destination': updatedTrip.destination,
      'startDate': updatedTrip.startDate.toIso8601String(),
      'endDate': updatedTrip.endDate.toIso8601String(),
      'description': updatedTrip.description,
    });

    state = [
      for (final trip in state)
        if (trip.firebaseKey == updatedTrip.firebaseKey) updatedTrip else trip,
    ];
  }
}

final tripProvider = StateNotifierProvider<TripNotifier, List<Trip>>((ref) {
  return TripNotifier();
});
