import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location.dart';

class LocationService {
  Future<List<Location>> searchCities(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=${Uri.encodeComponent(cleanQuery)}'
      '&count=10'
      '&language=vi'
      '&format=json',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Không thể kết nối tới dịch vụ tìm kiếm địa điểm');
      }

      final data = jsonDecode(response.body);

      if (data['results'] == null || (data['results'] as List).isEmpty) {
        return [];
      }

      final List results = data['results'];
      return results.map((item) => Location.fromJson(item)).toList();
    } catch (e) {
      // Return empty or rethrow
      return [];
    }
  }

  Future<Location> searchCity(String city) async {
    final results = await searchCities(city);
    if (results.isEmpty) {
      throw Exception('Không tìm thấy thành phố "$city"');
    }
    return results.first;
  }
}
