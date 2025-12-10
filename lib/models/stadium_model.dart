class StadiumModel {
  final int idEstadio;
  final String estadio;
  final String cidade;
  final String uf;
  final int capacidade;
  final double latitude;
  final double longitude;

  StadiumModel({
    required this.idEstadio,
    required this.estadio,
    required this.cidade,
    required this.uf,
    required this.capacidade,
    required this.latitude,
    required this.longitude,
  });

  factory StadiumModel.fromJson(Map<String, dynamic> json) {
    return StadiumModel(
      idEstadio: json['id_estadio'],
      estadio: json['estadio'],
      cidade: json['cidade'],
      uf: json['uf'],
      capacidade: json['capacidade'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
