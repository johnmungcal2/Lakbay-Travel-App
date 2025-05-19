import 'package:flutter/material.dart';
import 'package:lesson_7/models/trip_model.dart';
import 'package:lesson_7/screens/add_trip_screen.dart';
import 'package:lesson_7/services/foursquare_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lesson_7/reusable_widgets/app_text.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final service = FoursquareService();

  List<dynamic> weekendTrips = [];
  List<dynamic> famousAttractions = [];
  Map<String, String?> images = {};
  bool isLoading = true;

  String searchQuery = '';
  List<dynamic> searchResults = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() {
      isLoading = true;
    });

    try {
      final manila = await service.getWeekendTripsInManila();

      final queries = [
        'Golden Gate Bridge',
        'Burj Khalifa',
        'Louvre Museum',
        'Colosseum',
        'Eiffel Tower',
        'Acropolis of Athens',
        'Sydney Opera House',
        'The Grand Palace',
        'Sagrada Familia',
        'Milan Cathedral',
        'Machu Picchu',
        'Angkor Wat',
        'Santorini',
        'Yosemite National Park',
        'Neuschwanstein Castle',
        'Anne Frank House',
        'Petra',
        'Christ the Redeemer',
        'Stonehenge',
        'Buckingham Palace',
      ];

      final attractions = <dynamic>[];

      final attractionFutures = queries
          .map((query) => service.getPlacesByQuery(query, limit: 1))
          .toList();
      final attractionResults = await Future.wait(attractionFutures);
      for (final result in attractionResults) {
        if (result.isNotEmpty) attractions.add(result.first);
      }

      setState(() {
        weekendTrips = manila;
        famousAttractions = attractions;
        isLoading = false;
      });

      final allPlaces = [...manila, ...attractions];
      for (final place in allPlaces) {
        final fsqId = place['fsq_id'];
        service.getPlaceImageUrl(fsqId).then((url) {
          if (mounted) {
            setState(() {
              images[fsqId] = url;
            });
          }
        });
      }
    } catch (e) {
      print('Error loading trips: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void showPlaceDetails(
      BuildContext context, Map<String, dynamic> place) async {
    final name = place['name'] ?? 'No name';
    final category =
        place['categories'] != null && place['categories'].isNotEmpty
            ? place['categories'][0]['name']
            : 'No category';
    final address = place['location']?['formatted_address'] ?? '';
    final fsqId = place['fsq_id'] ?? '';

    final images = await service.getPlaceImageUrls(fsqId, maxImages: 5);

    int currentIndex = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: 420,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: images.isNotEmpty
                                      ? Image.network(
                                          images[currentIndex],
                                          height: 220,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 220,
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.photo,
                                              size: 80, color: Colors.white70),
                                        ),
                                ),
                                if (images.length > 1)
                                  Positioned(
                                    left: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_back_ios),
                                      onPressed: currentIndex > 0
                                          ? () => setState(() => currentIndex--)
                                          : null,
                                    ),
                                  ),
                                if (images.length > 1)
                                  Positioned(
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios),
                                      onPressed: currentIndex <
                                              images.length - 1
                                          ? () => setState(() => currentIndex++)
                                          : null,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (images.length > 1)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: AppText(
                                    '${currentIndex + 1} / ${images.length}'),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF808080),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            address,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4644db),
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        final trip = Trip(
                          tripName: name,
                          destination: address,
                          startDate: DateTime.now(),
                          endDate: DateTime.now(),
                          description: '',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTripScreen(trip: trip),
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
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildAttractionList(List<dynamic> data, Color color) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final place = data[index];
          final fsqId = place['fsq_id'];
          final imageUrl = images[fsqId];
          final name = place['name'] ?? 'No name';
          final category =
              place['categories'] != null && place['categories'].isNotEmpty
                  ? place['categories'][0]['name']
                  : 'No category';
          final address = place['location']?['formatted_address'] ?? '';

          return GestureDetector(
            onTap: () => showPlaceDetails(context, place),
            child: Container(
              width: 180,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Shimmer.fromColors(
                            baseColor: Color(0xFFE0D4FD),
                            highlightColor: Color(0xFFF3EBFF),
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.grey.shade300,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 12.0, top: 12.0, right: 12.0, bottom: 4),
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF808080),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 12.0, right: 12.0, top: 4, bottom: 8),
                    child: Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4644db),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Explore Destinations',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a place near you...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onSubmitted: (value) async {
                        setState(() {
                          isSearching = true;
                        });
                        final results = await FoursquareService()
                            .getNearbyPlaces(value, limit: 30);
                        setState(() {
                          searchQuery = value;
                          searchResults = results;
                          isSearching = false;
                        });
                      },
                    ),
                  ),
                  if (isSearching)
                    const Center(child: CircularProgressIndicator())
                  else if (searchResults.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          child: Text('Search Results',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        buildAttractionList(
                            searchResults.toList(), Colors.purple.shade50),
                      ],
                    ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Weekend Trips in Manila 🇵🇭',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  buildAttractionList(weekendTrips, Colors.blue.shade100),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Famous Attractions Around the World 🌍',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  buildAttractionList(
                      famousAttractions, Colors.orange.shade100),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Explore More by Category 🔍',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Color(0xFFC9C6CB),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.kayaking,
                                  color: Color(0xFF7B6F89),
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Kayaking',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Color(0xFFCAD1D1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.hiking,
                                  color: Color(0xFF4A8E8A),
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Hiking',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Color(0xFFD4D0C5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.pool,
                                  color: Color(0xFFB19B5E),
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Swimming',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Color(0xFFB7D0E8),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.directions_bike,
                                  color: Color(0xFF3A6EA5),
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Cycling',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
