import 'package:flutter/material.dart';
import '../models/location.dart';
import '../services/storage_service.dart';

class CityManagerSheet extends StatefulWidget {
  final Location currentLocation;
  final bool isCelsius;
  final Function(Location) onLocationSelected;
  final Function(bool) onUnitChanged;

  const CityManagerSheet({
    super.key,
    required this.currentLocation,
    required this.isCelsius,
    required this.onLocationSelected,
    required this.onUnitChanged,
  });

  @override
  State<CityManagerSheet> createState() => _CityManagerSheetState();
}

class _CityManagerSheetState extends State<CityManagerSheet> {
  final StorageService _storageService = StorageService();
  List<Location> _favoriteLocations = [];
  bool _isLoading = true;
  late bool _currentIsCelsius;

  @override
  void initState() {
    super.initState();
    _currentIsCelsius = widget.isCelsius;
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final list = await _storageService.getFavoriteLocations();
    if (mounted) {
      setState(() {
        _favoriteLocations = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteLocation(Location loc) async {
    setState(() {
      _favoriteLocations.removeWhere((item) => item.name == loc.name);
    });
    await _storageService.saveFavoriteLocations(_favoriteLocations);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF131B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quản lý thành phố',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Unit toggle row (°C / °F)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.thermostat_rounded, color: Color(0xFFFFB300), size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Đơn vị nhiệt độ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('°C', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('°F', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                  selected: {_currentIsCelsius},
                  onSelectionChanged: (Set<bool> newSelection) {
                    final selected = newSelection.first;
                    setState(() {
                      _currentIsCelsius = selected;
                    });
                    widget.onUnitChanged(selected);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Color(0xFF00E5FF);
                        }
                        return Colors.transparent;
                      },
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.black;
                        }
                        return Colors.white70;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Danh sách thành phố đã lưu',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 10),

          // Favorite Cities List
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
              ),
            )
          else if (_favoriteLocations.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Chưa có thành phố nào được lưu.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _favoriteLocations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final loc = _favoriteLocations[index];
                  final isCurrent = loc.name == widget.currentLocation.name;

                  return Container(
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF00E5FF).withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFF00E5FF).withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.1),
                        width: isCurrent ? 1.5 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Text(loc.flagEmoji, style: const TextStyle(fontSize: 26)),
                      title: Text(
                        loc.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? const Color(0xFF00E5FF) : Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        loc.country ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Đang xem',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00E5FF),
                                ),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                            onPressed: () => _deleteLocation(loc),
                          ),
                        ],
                      ),
                      onTap: () {
                        widget.onLocationSelected(loc);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
