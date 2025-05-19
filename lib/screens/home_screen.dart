import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lesson_7/provider/trip_provider.dart';
import 'package:lesson_7/reusable_widgets/app_text.dart';
import 'package:lesson_7/screens/add_trip_screen.dart';
import 'package:lesson_7/screens/profile_screen.dart';
import 'package:lesson_7/screens/discover_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripProvider);
    final currentIndex = useState(0);

    useEffect(() {
      ref.read(tripProvider.notifier).fetchTrips();
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Image.asset(
          'lib/assets/images/lakbay-logo.png',
          width: 120,
          height: 32,
          fit: BoxFit.contain,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: switch (currentIndex.value) {
        0 => const DiscoverScreen(),
        1 => trips.isEmpty
            ? const Center(
                child: Text(
                  'No trips yet. Tap + to add your first trip!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF808080),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Your Upcoming Trips',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16.0)),
                                ),
                                builder: (context) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          trip.tripName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          trip.destination,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF808080),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${DateFormat.yMMMd().format(trip.startDate)} - ${DateFormat.yMMMd().format(trip.endDate)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF4644db),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Description:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          trip.description.isNotEmpty
                                              ? trip.description
                                              : 'No description provided.',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF808080),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Slidable(
                              key: Key(trip.firebaseKey ?? ''),
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) async {
                                      final tripKey = trip.firebaseKey;
                                      if (tripKey != null) {
                                        await ref
                                            .read(tripProvider.notifier)
                                            .deleteTrip(tripKey);
                                      }
                                    },
                                    backgroundColor: Color(0xFF808080),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: Card(
                                  color: const Color(0xFFF2F2F2),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              trip.tripName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              trip.destination,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF808080),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${DateFormat.yMMMd().format(trip.startDate)} - ${DateFormat.yMMMd().format(trip.endDate)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF4644db),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Color(0xFF808080),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddTripScreen(trip: trip),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
        2 => const ProfileScreen(),
        _ => const Center(child: AppText('Unknown tab')),
      },
      floatingActionButton: currentIndex.value == 1
          ? GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTripScreen(),
                  ),
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4644db),
                      Color(0xFF8e6eeb),
                      Color(0xFFe49efc),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            )
          : null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Container(
            height: 56,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => currentIndex.value = 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: currentIndex.value == 0
                        ? BoxDecoration(
                            color: const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(32),
                          )
                        : null,
                    child: Row(
                      children: [
                        Icon(
                          Icons.explore,
                          color: currentIndex.value == 0
                              ? Colors.white
                              : Colors.white70,
                          size: 28,
                        ),
                        if (currentIndex.value == 0) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'Discover',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => currentIndex.value = 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: currentIndex.value == 1
                        ? BoxDecoration(
                            color: const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(32),
                          )
                        : null,
                    child: Row(
                      children: [
                        Icon(
                          Icons.flight_takeoff,
                          color: currentIndex.value == 1
                              ? Colors.white
                              : Colors.white70,
                          size: 28,
                        ),
                        if (currentIndex.value == 1) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'Trips',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => currentIndex.value = 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: currentIndex.value == 2
                        ? BoxDecoration(
                            color: const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(32),
                          )
                        : null,
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: currentIndex.value == 2
                              ? Colors.white
                              : Colors.white70,
                          size: 28,
                        ),
                        if (currentIndex.value == 2) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
