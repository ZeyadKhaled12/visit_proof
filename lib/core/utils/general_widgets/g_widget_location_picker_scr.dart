import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../configs/app_theme.dart';

class _PlaceSuggestion {
  final String name;
  final String description;
  final LatLng location;

  const _PlaceSuggestion({
    required this.name,
    required this.description,
    required this.location,
  });

  factory _PlaceSuggestion.fromJson(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>;
    final coordinates =
        (feature['geometry'] as Map<String, dynamic>)['coordinates'] as List;

    String read(String key) => (properties[key] ?? '').toString().trim();

    final name = read('name').isNotEmpty
        ? read('name')
        : (read('street').isNotEmpty ? read('street') : read('city'));
    final details = <String>[
      read('housenumber'),
      read('street'),
      read('district'),
      read('city'),
      read('state'),
      read('country'),
    ].where((s) => s.isNotEmpty && s != name).toSet().join(', ');

    return _PlaceSuggestion(
      name: name.isEmpty ? 'Unnamed place' : name,
      description: details,
      // GeoJSON uses [longitude, latitude].
      location: LatLng(
        (coordinates[1] as num).toDouble(),
        (coordinates[0] as num).toDouble(),
      ),
    );
  }
}

class GWidgetLocationPickerScr extends StatefulWidget {
  const GWidgetLocationPickerScr({super.key, this.initialLocation});
  final LatLng? initialLocation;

  @override
  State<GWidgetLocationPickerScr> createState() =>
      _GWidgetLocationPickerScrState();
}

class _GWidgetLocationPickerScrState extends State<GWidgetLocationPickerScr> {
  static const LatLng _fallbackLocation = LatLng(0, 0);

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  LatLng _currentCenter = _fallbackLocation;
  String _currentAddress = 'Locating...';

  List<_PlaceSuggestion> _suggestions = [];
  Timer? _searchDebounce;
  Timer? _mapDebounce;
  int _searchGeneration = 0;
  int _addressGeneration = 0;
  bool _mapReady = false;
  bool _userPickedLocation = false;
  bool _gpsLoading = true;
  bool _dragging = false;
  bool _searchLoading = false;
  bool _showSuggestions = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_onFocusChanged);

    if (widget.initialLocation != null) {
      // 1. Set the center to the passed location
      _currentCenter = widget.initialLocation!;
      _gpsLoading = false;

      // 2. Fetch the address name for this location instead of getting GPS
      _reverseGeocode(_currentCenter);
    } else {
      // 3. ONLY fetch device GPS if no initial location was provided
      _loadDeviceLocation();
    }
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {
      if (!_searchFocus.hasFocus) {
        _showSuggestions = false;
      } else if (_searchController.text.trim().length >= 2) {
        _showSuggestions = true;
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _mapDebounce?.cancel();
    _searchFocus.removeListener(_onFocusChanged);
    _searchFocus.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _useFallback(
            'Location services are disabled. Select on map or search.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _useFallback(
            'Location permission not granted. Search or move the map.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );
      if (!mounted || _userPickedLocation) return;
      final coordinates = LatLng(position.latitude, position.longitude);
      setState(() {
        if (widget.initialLocation == null) {
          _currentCenter = coordinates;
        }
        _gpsLoading = false;
      });
      _moveMap(coordinates);
      await _reverseGeocode(coordinates);
    } catch (error) {
      debugPrint('Device location error: $error');
      _useFallback('Could not fetch GPS. Search or move the map.');
    }
  }

  void _useFallback(String message) {
    if (!mounted) return;
    if (_userPickedLocation) return;
    setState(() {
      _gpsLoading = false;
      _currentAddress = message;
    });
  }

  void _moveMap(LatLng target) {
    if (_mapReady) _mapController.move(target, 16);
  }

  Future<void> _reverseGeocode(LatLng target) async {
    final generation = ++_addressGeneration;
    if (!mounted) return;
    setState(() => _currentAddress = 'Fetching address...');
    try {
      final placemarks = await placemarkFromCoordinates(
        target.latitude,
        target.longitude,
      );
      if (!mounted || generation != _addressGeneration) return;
      if (placemarks.isEmpty) {
        setState(() => _currentAddress = _coordinatesLabel(target));
        return;
      }
      final place = placemarks.first;
      final parts = <String?>[
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ];
      final address = parts
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toSet()
          .join(', ');
      setState(() => _currentAddress =
          address.isEmpty ? _coordinatesLabel(target) : address);
    } catch (error) {
      if (!mounted || generation != _addressGeneration) return;
      setState(() => _currentAddress = _coordinatesLabel(target));
    }
  }

  String _coordinatesLabel(LatLng point) =>
      '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';

  void _onSearchTextChanged(String value) {
    _searchDebounce?.cancel();
    final generation = ++_searchGeneration;
    final query = value.trim();

    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _searchLoading = false;
        _searchError = null;
      });
      return;
    }

    setState(() {
      _suggestions = [];
      _showSuggestions = true;
      _searchLoading = true;
      _searchError = null;
    });
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      _searchPlaces(query, generation);
    });
  }

  Future<void> _searchPlaces(String query, int generation) async {
    try {
      final parameters = <String, String>{
        'q': query,
        'limit': '7',
        'lat': _currentCenter.latitude.toString(),
        'lon': _currentCenter.longitude.toString(),
        // Change to 'ar' if you prefer Arabic labels where available.
        'lang': 'en',
      };
      final uri = Uri.https('photon.komoot.io', '/api/', parameters);
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (!mounted || generation != _searchGeneration) return;
      if (response.statusCode != 200) {
        throw Exception('Search HTTP ${response.statusCode}');
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final features = payload['features'] as List<dynamic>? ?? [];
      final results = <_PlaceSuggestion>[];
      for (final raw in features) {
        try {
          results.add(_PlaceSuggestion.fromJson(raw as Map<String, dynamic>));
        } catch (error) {
          debugPrint('Skipping malformed Photon feature: $error');
        }
      }
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        _suggestions = results;
        _searchLoading = false;
        _searchError = null;
      });
    } catch (error) {
      if (!mounted || generation != _searchGeneration) return;
      debugPrint('Autocomplete error: $error');
      setState(() {
        _suggestions = [];
        _searchLoading = false;
        _searchError = 'Search unavailable. Check your connection.';
      });
    }
  }

  void _selectPlace(_PlaceSuggestion place) {
    _searchDebounce?.cancel();
    _mapDebounce?.cancel();
    ++_searchGeneration;
    ++_addressGeneration; // Ignore reverse-geocoding responses from old map locations.
    _searchFocus.unfocus();
    _searchController.value = TextEditingValue(
      text: place.name,
      selection: TextSelection.collapsed(offset: place.name.length),
    );
    setState(() {
      _showSuggestions = false;
      _searchLoading = false;
      _suggestions = [];
      _searchError = null;
      _dragging = false;
      _gpsLoading = false;
      _userPickedLocation = true;
      _currentCenter = place.location;
      _currentAddress = place.description.isEmpty
          ? place.name
          : '${place.name}, ${place.description}';
    });
    _moveMap(place.location);
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    ++_searchGeneration;
    _searchController.clear();
    setState(() {
      _suggestions = [];
      _searchLoading = false;
      _showSuggestions = false;
      _searchError = null;
    });
  }

  void _onMapPositionChanged(MapPosition position, bool hasGesture) {
    final center = position.center;
    if (center == null) return;
    _currentCenter = center;
    if (!hasGesture) return;
    _userPickedLocation = true;
    _gpsLoading = false;

    _mapDebounce?.cancel();
    ++_addressGeneration;
    if (!_dragging || _showSuggestions) {
      setState(() {
        _dragging = true;
        _showSuggestions = false;
      });
    }
    _mapDebounce = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() => _dragging = false);
      _reverseGeocode(_currentCenter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final resultsMaxHeight = (screenHeight * 0.43).clamp(140.0, 350.0);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _fallbackLocation,
                initialZoom: 16,
                onMapReady: () {
                  _mapReady = true;
                  _moveMap(_currentCenter);
                },
                onPositionChanged: _onMapPositionChanged,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.visit_proof',
                ),
              ],
            ),

            // Center pin is fixed while the map moves beneath it.
            IgnorePointer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    transform:
                        Matrix4.translationValues(0, _dragging ? -10 : 0, 0),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppTheme.primary,
                      size: 45,
                    ),
                  ),
                ),
              ),
            ),

            // Navigation and search field.
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Material(
                    color: AppTheme.surface,
                    elevation: 3,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: AppTheme.textPrimary),
                      onPressed: () => Navigator.pop(context, null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      color: AppTheme.searchFieldBg,
                      elevation: 3,
                      borderRadius: BorderRadius.circular(24),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onChanged: _onSearchTextChanged,
                        onSubmitted: (_) {
                          if (_suggestions.isNotEmpty) {
                            _selectPlace(_suggestions.first);
                          }
                        },
                        textInputAction: TextInputAction.search,
                        style: AppTheme.font(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.textTitle,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search for a place...',
                          hintStyle: AppTheme.font(color: AppTheme.textSecondary),
                          prefixIcon: Icon(Icons.search,
                              color: AppTheme.primary),
                          suffixIcon: _searchLoading
                              ? Padding(
                                  padding: EdgeInsets.all(15),
                                  child: SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                )
                              : _searchController.text.isNotEmpty
                                  ? IconButton(
                                      tooltip: 'Clear search',
                                      onPressed: _clearSearch,
                                      icon: Icon(Icons.close,
                                          color: AppTheme.textSecondary),
                                    )
                                  : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Live suggestions float over the map, below search input.
            if (_showSuggestions)
              Positioned(
                top: 82,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 9,
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: resultsMaxHeight),
                    child: _searchLoading
                        ? Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                              ),
                            ),
                          )
                        : _searchError != null
                            ? Padding(
                                padding: const EdgeInsets.all(18),
                                child: Text(_searchError!,
                                    textAlign: TextAlign.center),
                              )
                            : _suggestions.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(18),
                                    child: Text('No places found',
                                        textAlign: TextAlign.center),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: _suggestions.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 1),
                                    itemBuilder: (_, index) {
                                      final place = _suggestions[index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              AppTheme.searchFieldBg,
                                          child: Icon(Icons.place_outlined,
                                              color: AppTheme.primary),
                                        ),
                                        title: Text(
                                          place.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: place.description.isEmpty
                                            ? null
                                            : Text(
                                                place.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                        onTap: () => _selectPlace(place),
                                      );
                                    },
                                  ),
                  ),
                ),
              ),

            // Bottom confirmation card: keep it out of the way during search.
            if (!keyboardVisible && !_showSuggestions)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowColor,
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: AppTheme.font(
                          fontSize: AppTheme.textSmall,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.place,
                              size: 20, color: AppTheme.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _currentAddress,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.font(
                                color: AppTheme.textPrimary,
                                fontSize: AppTheme.textTitle,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _dragging || _gpsLoading
                              ? null
                              : () => Navigator.pop(context, _currentCenter),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Confirm Location',
                            style: AppTheme.font(
                              fontSize: AppTheme.textTitle,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_gpsLoading)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
