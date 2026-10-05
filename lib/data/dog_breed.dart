class DogBreed {
  const DogBreed({
    required this.name,
    required this.imageLink,
    required this.energy,
    required this.barking,
    required this.shedding,
    required this.grooming,
    required this.trainability,
  });

  final String name;
  final String imageLink;
  final int energy;
  final int barking;
  final int shedding;
  final int grooming;
  final int trainability;

  factory DogBreed.fromJson(Map<String, dynamic> json) {
    return DogBreed(
      name: json['name'] as String? ?? '',
      imageLink: json['image_link'] as String? ?? '',
      energy: _asInt(json['energy']),
      barking: _asInt(json['barking']),
      shedding: _asInt(json['shedding']),
      grooming: _asInt(json['grooming']),
      trainability: _asInt(json['trainability']),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse('$value') ?? 0;
}
