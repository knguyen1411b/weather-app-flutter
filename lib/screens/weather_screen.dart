import 'package:flutter/material.dart';
import '../models/location.dart';
import '../models/weather.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import '../widgets/city_manager_sheet.dart';
import '../widgets/city_search_sheet.dart';
import '../widgets/glass_card.dart';
import '../widgets/weather_background.dart';
import '../widgets/weather_card.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  final StorageService _storageService = StorageService();

  Location _currentLocation = StorageService.defaultLocations[0]; // Hà Nội by default
  FullWeatherData? _weatherData;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isCelsius = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    _isCelsius = await _storageService.getIsCelsius();
    final lastLoc = await _storageService.getLastLocation();
    if (lastLoc != null) {
      _currentLocation = lastLoc;
    }
    await _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isFav = await _storageService.isFavorite(_currentLocation);
      final data = await _weatherService.getFullWeather(
        _currentLocation.latitude,
        _currentLocation.longitude,
      );

      if (mounted) {
        setState(() {
          _weatherData = data;
          _isFavorite = isFav;
          _isLoading = false;
        });
        await _storageService.saveLastLocation(_currentLocation);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _onLocationSelected(Location location) {
    setState(() {
      _currentLocation = location;
    });
    _loadWeatherData();
  }

  Future<void> _toggleFavorite() async {
    await _storageService.toggleFavorite(_currentLocation);
    final isFav = await _storageService.isFavorite(_currentLocation);
    setState(() {
      _isFavorite = isFav;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFav
                ? 'Đã lưu ${_currentLocation.name} vào danh sách yêu thích'
                : 'Đã xóa ${_currentLocation.name} khỏi danh sách yêu thích',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1F293D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  void _openSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CitySearchSheet(
        onLocationSelected: _onLocationSelected,
      ),
    );
  }

  void _openManagerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CityManagerSheet(
        currentLocation: _currentLocation,
        isCelsius: _isCelsius,
        onLocationSelected: _onLocationSelected,
        onUnitChanged: (isCelsius) {
          setState(() {
            _isCelsius = isCelsius;
          });
          _storageService.setIsCelsius(isCelsius);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWeather = _weatherData?.current;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
          ),
          tooltip: 'Quản lý thành phố',
          onPressed: _openManagerSheet,
        ),
        title: GestureDetector(
          onTap: _openSearchSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, color: Color(0xFF00E5FF), size: 16),
                const SizedBox(width: 6),
                Text(
                  _currentLocation.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isFavorite ? const Color(0xFFFF5252) : Colors.white,
                size: 20,
              ),
            ),
            tooltip: 'Yêu thích',
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
            ),
            tooltip: 'Tìm kiếm',
            onPressed: _openSearchSheet,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: WeatherBackground(
        weather: currentWeather,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadWeatherData,
            color: const Color(0xFF00E5FF),
            backgroundColor: const Color(0xFF131B2A),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _weatherData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF00E5FF),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Đang cập nhật thời tiết...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _weatherData == null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(24),
          child: Center(
            child: GlassCard(
              padding: const EdgeInsets.all(28),
              borderRadius: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 64,
                    color: Color(0xFFFF5252),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Không thể tải dữ liệu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadWeatherData,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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

    if (_weatherData != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: WeatherCard(
          location: _currentLocation,
          weatherData: _weatherData!,
          isCelsius: _isCelsius,
          onSearchTap: _openSearchSheet,
          onFavoriteTap: _toggleFavorite,
          isFavorite: _isFavorite,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
