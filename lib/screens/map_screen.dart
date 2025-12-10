import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

// Components
import '../widgets/top_bar.dart';
import '../widgets/glassy_container.dart';
import '../widgets/location_details_sheet.dart';

// Models
import '../models/location_model.dart';

// Services
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _center = LatLng(-27.5945, -48.4500);
  final ApiService _apiService = ApiService();
  final MapController _mapController = MapController();

  bool _isSatellite = false;
  List<LocationModel> _allLocations = [];
  List<LocationModel> _visibleLocations = [];

  @override
  void initState() {
    super.initState();
    _fetchStadiums();
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
        );
      }).toList();

      setState(() {
        _allLocations = stadiumLocations;
        _visibleLocations = List.from(_allLocations);
      });
    } catch (e) {
      debugPrint('Error fetching stadiums: $e');
    }
  }

  Future<void> _moveToCurrentLocation() async {
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
                urlTemplate: _isSatellite
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                subdomains: _isSatellite
                    ? const ['a', 'b', 'c', 'd']
                    : const [],
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
          const Positioned(top: 0, left: 0, right: 0, child: TopBar()),

          // 3. Day/Night Switcher
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: GlassyContainer(
                borderRadius: 50,
                padding: const EdgeInsets.all(4),
                child: FittedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSwitchOption(
                        'Dia',
                        !_isSatellite,
                        () => setState(() => _isSatellite = false),
                      ),
                      _buildSwitchOption(
                        'Noite',
                        _isSatellite,
                        () => setState(() => _isSatellite = true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 5. Action Buttons
          Positioned(
            bottom: 40,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCircleButton(
                  Icons.my_location,
                  size: 50,
                  onTap: _moveToCurrentLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchOption(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF69F0AE) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.black87 : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(
    IconData icon, {
    double size = 40,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
        child: Icon(icon, color: Colors.black87, size: size * 0.5),
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
