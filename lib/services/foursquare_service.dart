import 'dart:convert';
import 'package:http/http.dart' as http;

class FoursquareService {
  static const String apiKey =
      'fsq3g+/f0dWfdx0lB7A5EcWGfNR/2RsreKo+wJQmN17LO3U=';

  static const String baseUrl = 'https://api.foursquare.com/v3/places';

  final String _categories = '10000,16000';
  final int _radius = 10000;

  Future<List<dynamic>> getWeekendTripsInManila({int limit = 30}) async {
    final double manilaLat = 14.5995;
    final double manilaLon = 120.9842;

    final uri = Uri.parse(
      '$baseUrl/search?ll=$manilaLat,$manilaLon&radius=$_radius&categories=$_categories&limit=$limit&sort=POPULARITY',
    );

    final response = await http.get(uri, headers: {
      'Authorization': apiKey,
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception(
          'Failed to load weekend trips in Manila: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getPlacesByQuery(String query, {int limit = 1}) async {
    final uri = Uri.parse(
      '$baseUrl/search?query=${Uri.encodeComponent(query)}&limit=$limit',
    );

    final response = await http.get(uri, headers: {
      'Authorization': apiKey,
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to search for "$query": ${response.statusCode}');
    }
  }

  Future<String?> getPlaceImageUrl(String fsqId) async {
    final uri = Uri.parse('$baseUrl/$fsqId/photos');

    final response = await http.get(uri, headers: {
      'Authorization': apiKey,
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;

      if (data.isNotEmpty) {
        final photo = data[0];
        final prefix = photo['prefix'];
        final suffix = photo['suffix'];

        return '$prefix' + '300x300' + '$suffix';
      }

      return null;
    } else {
      return null;
    }
  }

  Future<List<String>> getPlaceImageUrls(String fsqId,
      {int maxImages = 5}) async {
    final uri = Uri.parse('$baseUrl/$fsqId/photos');
    final response = await http.get(uri, headers: {
      'Authorization': apiKey,
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.take(maxImages).map<String>((photo) {
        final prefix = photo['prefix'];
        final suffix = photo['suffix'];
        return '$prefix' + '600x600' + '$suffix';
      }).toList();
    } else {
      return [];
    }
  }
}
