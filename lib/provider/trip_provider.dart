import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lesson_7/models/trip_model.dart';

class TripNotifier extends StateNotifier<List<Trip>> {
  TripNotifier() : super([]);

  final DatabaseReference _database = FirebaseDatabase.instance.refFromURL(
      'https://lesson-7-a161f-default-rtdb.asia-southeast1.firebasedatabase.app/users');

  Future<void> addTrip(Trip trip) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is logged in!');
    }

    final userId = user.uid;
    final userTripsRef = _database.child(userId).push();

    await userTripsRef.set({
      'tripName': trip.tripName,
      'destination': trip.destination,
      'startDate': trip.startDate.toIso8601String(),
      'endDate': trip.endDate.toIso8601String(),
      'description': trip.description,
    });

    final tripWithKey = Trip(
      tripName: trip.tripName,
      destination: trip.destination,
      startDate: trip.startDate,
      endDate: trip.endDate,
      description: trip.description,
      firebaseKey: userTripsRef.key,
    );

    state = [...state, tripWithKey];
  }

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
        final key = entry.key;
        final data = entry.value;

        return Trip(
          tripName: data['tripName'],
          destination: data['destination'],
          startDate: DateTime.parse(data['startDate']),
          endDate: DateTime.parse(data['endDate']),
          description: data['description'],
          firebaseKey: key,
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

    print('Deleting trip with firebaseKey: $tripKey');
    print('User ID: $userId');

    await _database.child(userId).child(tripKey).remove();

    print('Trip deleted from Firebase');

    state = [
      for (final trip in state)
        if (trip.firebaseKey != tripKey) trip,
    ];

    print('Local state updated');
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
