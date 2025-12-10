import 'package:latlong2/latlong.dart';

enum LocationType { cultural, natural, trail, stadium }

class LocationModel {
  final String id;
  final String name;
  final String description;
  final LatLng coordinates;
  final LocationType type;
  final double rating;
  final String imageUrl;

  const LocationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coordinates,
    required this.type,
    required this.rating,
    required this.imageUrl,
  });
}
