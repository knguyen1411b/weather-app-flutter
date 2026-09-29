import 'dart:async';
import 'package:flutter/material.dart';
import '../models/location.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

class CitySearchSheet extends StatefulWidget {
  final Function(Location) onLocationSelected;

  const CitySearchSheet({super.key, required this.onLocationSelected});

  @override
  State<CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<CitySearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  Timer? _debounceTimer;

  List<Location> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _searchError = null;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      setState(() {
        _isSearching = true;
        _searchError = null;
      });

      try {
        final results = await _locationService.searchCities(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
            if (results.isEmpty) {
              _searchError = 'Không tìm thấy địa điểm nào phù hợp.';
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _searchError = 'Đã có lỗi xảy ra khi tìm kiếm.';
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                'Tìm kiếm địa điểm',
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

          // Search Field
          TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            onChanged: _onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Nhập tên thành phố (ví dụ: Đà Nẵng, Tokyo)...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00E5FF)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                      onPressed: () {
                        _searchController.clear();
                        _onQueryChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 16),

          // Popular Cities chips (if not typing)
          if (_searchController.text.isEmpty) ...[
            Text(
              'Thành phố phổ biến',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: StorageService.defaultLocations.map((loc) {
                return ActionChip(
                  avatar: Text(loc.flagEmoji, style: const TextStyle(fontSize: 16)),
                  label: Text(loc.name),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onPressed: () {
                    widget.onLocationSelected(loc);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Search Results or Loading Indicator
          if (_isSearching)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00E5FF),
                ),
              ),
            )
          else if (_searchError != null)
            Expanded(
              child: Center(
                child: Text(
                  _searchError!,
                  style: const TextStyle(color: Colors.white60, fontSize: 15),
                ),
              ),
            )
          else if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.white.withValues(alpha: 0.08),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final loc = _searchResults[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(loc.flagEmoji, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    title: Text(
                      loc.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      loc.admin1 != null && loc.country != null
                          ? '${loc.admin1}, ${loc.country}'
                          : (loc.country ?? ''),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.white38,
                    ),
                    onTap: () {
                      widget.onLocationSelected(loc);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
