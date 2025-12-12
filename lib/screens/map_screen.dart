import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_fonts/google_fonts.dart';
// Components
import '../widgets/top_bar.dart';
import '../widgets/location_details_sheet.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/map_search_widget.dart';
import 'dart:ui'; // For BackdropFilter

// Models
import '../models/location_model.dart';

// Services
import '../services/api_service.dart';

// Screens
import 'rankings_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  static const LatLng _center = LatLng(-27.5945, -48.4500);
  final ApiService _apiService = ApiService();
  final MapController _mapController = MapController();
  late AnimationController _sidebarController;
  List<LocationModel> _allLocations = [];
  List<LocationModel> _visibleLocations = [];
  bool _isLocating = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fetchStadiums();
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  Future<void> _fetchStadiums() async {
    try {
      final stadiums = await _apiService.fetchStadiums();
      final stadiumLocations = stadiums.map((stadium) {
        return LocationModel(
          id: 'stadium_${stadium.idEstadio}',
          name: stadium.estadio,
          description:
              'Cidade: ${stadium.cidade} - ${stadium.uf}\nCapacidade: ${stadium.capacidade}',
          coordinates: LatLng(stadium.latitude, stadium.longitude),
          type: LocationType.stadium,
          rating: 0.0,
          imageUrl: '',
          city: stadium.cidade,
          state: stadium.uf,
          capacity: stadium.capacidade,
        );
      }).toList();

      setState(() {
        _allLocations = stadiumLocations;
        _visibleLocations = List.from(_allLocations);
      });

      // Artificial delay to show the effect
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Error fetching stadiums: $e');
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  void _filterStadiums(String query) {
    if (query.isEmpty) {
      setState(() {
        _visibleLocations = List.from(_allLocations);
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _visibleLocations = _allLocations.where((loc) {
        final nameMatch = loc.name.toLowerCase().contains(lowerQuery);
        final cityMatch = loc.city?.toLowerCase().contains(lowerQuery) ?? false;
        final stateMatch =
            loc.state?.toLowerCase().contains(lowerQuery) ?? false;
        return nameMatch || cityMatch || stateMatch;
      }).toList();
    });
  }

  void _fitAllStadiums() {
    if (_allLocations.isEmpty) return;

    // Calculate bounds from all locations
    double minLat = _allLocations.first.coordinates.latitude;
    double maxLat = _allLocations.first.coordinates.latitude;
    double minLng = _allLocations.first.coordinates.longitude;
    double maxLng = _allLocations.first.coordinates.longitude;

    for (final location in _allLocations) {
      final lat = location.coordinates.latitude;
      final lng = location.coordinates.longitude;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    // Create bounds with padding
    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));

    // Fit bounds to map
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  Future<void> _moveToCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check service
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      }

      // Get location
      final Position position = await Geolocator.getCurrentPosition();
      _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
    } catch (e) {
      debugPrint('Location error: $e');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _onMarkerTap(LocationModel location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LocationDetailsSheet(location: location),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 11.5,
              onTap: (_, __) {}, // Dismiss things if needed
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: _visibleLocations
                    .map((loc) => _buildCustomMarker(loc))
                    .toList(),
              ),
            ],
          ),

          // 2. Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(onMenuTap: () => _sidebarController.forward()),
          ),

          // 5. Action Buttons
          Positioned(
            bottom: 40,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MapSearchWidget(
                  onChanged: _filterStadiums,
                  onClear: () => _filterStadiums(''),
                ),
                const SizedBox(height: 16),
                _buildCircleButton(
                  Icons.my_location,
                  size: 50,
                  onTap: _moveToCurrentLocation,
                  isLoading: _isLocating,
                ),
              ],
            ),
          ),
          // 6. Sidebar (Highest z-index)
          Positioned.fill(
            child: SidebarWidget(
              animationController: _sidebarController,
              onClose: () => _sidebarController.reverse(),
              onHomeTap: _fitAllStadiums,
              onRankingsTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RankingsScreen(
                      locations: _allLocations,
                      onLocationTap: (location) {
                        // Center map on selected stadium
                        _mapController.move(location.coordinates, 15.0);
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // 7. Loading Overlay (Topmost)
          if (_isLoadingData)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFF69F0AE),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Carregando camadas...',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
    IconData icon, {
    double size = 40,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                ),
              )
            : Icon(icon, color: Colors.black87, size: size * 0.5),
      ),
    );
  }

  Marker _buildCustomMarker(LocationModel location) {
    return Marker(
      point: location.coordinates,
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => _onMarkerTap(location),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: const Color(0xFF69F0AE).withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF69F0AE).withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            _getIconForType(location.type),
            color: Colors.black87,
            size: 28,
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(LocationType type) {
    switch (type) {
      case LocationType.cultural:
        return Icons.wb_sunny;
      case LocationType.natural:
        return Icons.waves;
      case LocationType.trail:
        return Icons.hiking;
      case LocationType.stadium:
        return Icons.sports_soccer;
    }
  }
}
