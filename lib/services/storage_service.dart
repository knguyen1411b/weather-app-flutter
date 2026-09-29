import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location.dart';

class StorageService {
  static const String _keyFavorites = 'saved_favorite_locations';
  static const String _keyLastLocation = 'saved_last_location';
  static const String _keyIsCelsius = 'saved_is_celsius';

  // Default preset locations
  static final List<Location> defaultLocations = [
    Location(
      name: 'Hà Nội',
      latitude: 21.0285,
      longitude: 105.8542,
      country: 'Việt Nam',
      countryCode: 'VN',
      admin1: 'Hà Nội',
    ),
    Location(
      name: 'TP. Hồ Chí Minh',
      latitude: 10.8231,
      longitude: 106.6297,
      country: 'Việt Nam',
      countryCode: 'VN',
      admin1: 'Hồ Chí Minh',
    ),
    Location(
      name: 'Đà Nẵng',
      latitude: 16.0544,
      longitude: 108.2022,
      country: 'Việt Nam',
      countryCode: 'VN',
      admin1: 'Đà Nẵng',
    ),
    Location(
      name: 'Huế',
      latitude: 16.4637,
      longitude: 107.5909,
      country: 'Việt Nam',
      countryCode: 'VN',
      admin1: 'Thừa Thiên Huế',
    ),
    Location(
      name: 'Tokyo',
      latitude: 35.6762,
      longitude: 139.6503,
      country: 'Nhật Bản',
      countryCode: 'JP',
      admin1: 'Tokyo',
    ),
    Location(
      name: 'Paris',
      latitude: 48.8566,
      longitude: 2.3522,
      country: 'Pháp',
      countryCode: 'FR',
      admin1: 'Île-de-France',
    ),
  ];

  Future<List<Location>> getFavoriteLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_keyFavorites);
      if (jsonStr == null || jsonStr.isEmpty) {
        // Return default list if none saved
        return [defaultLocations[0], defaultLocations[1], defaultLocations[2]];
      }
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) => Location.fromJson(item)).toList();
    } catch (e) {
      return [defaultLocations[0], defaultLocations[1], defaultLocations[2]];
    }
  }

  Future<void> saveFavoriteLocations(List<Location> locations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = locations.map((loc) => loc.toJson()).toList();
    await prefs.setString(_keyFavorites, jsonEncode(jsonList));
  }

  Future<void> toggleFavorite(Location location) async {
    final list = await getFavoriteLocations();
    final index = list.indexWhere((item) => item.name == location.name);
    if (index >= 0) {
      list.removeAt(index);
    } else {
      list.add(location);
    }
    await saveFavoriteLocations(list);
  }

  Future<bool> isFavorite(Location location) async {
    final list = await getFavoriteLocations();
    return list.any((item) => item.name == location.name);
  }

  Future<Location?> getLastLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_keyLastLocation);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        return Location.fromJson(jsonDecode(jsonStr));
      }
    } catch (_) {}
    return defaultLocations[0];
  }

  Future<void> saveLastLocation(Location location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastLocation, jsonEncode(location.toJson()));
  }

  Future<bool> getIsCelsius() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsCelsius) ?? true;
  }

  Future<void> setIsCelsius(bool isCelsius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsCelsius, isCelsius);
  }
}
