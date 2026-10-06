import 'package:uuid/uuid.dart';

class Rider {
  final String id;
  final String name;

  Rider({String? id, required this.name}) : id = id ?? const Uuid().v4();
}

class RideGroup {
  final String id;
  final String name;
  final List<Rider> riders;

  RideGroup({String? id, required this.name, List<Rider>? riders})
      : id = id ?? const Uuid().v4(),
        riders = riders ?? [];
}

class Photo {
  final String path;
  final String? description;
  final double? latitude;
  final double? longitude;

  Photo({
    required this.path,
    this.description,
    this.latitude,
    this.longitude,
  });
}

class Expense {
  final String id;
  final double amount;
  final String description;

  Expense({
    String? id,
    required this.amount,
    required this.description,
  }) : id = id ?? const Uuid().v4();
}

class Ride {
  final String id;
  final String name;
  final DateTime date;
  final RideGroup? group;
  final List<Photo> photos;
  final List<Expense> expenses;
  final double? startLatitude;
  final double? startLongitude;

  Ride({
    String? id,
    required this.name,
    required this.date,
    this.group,
    List<Photo>? photos,
    List<Expense>? expenses,
    this.startLatitude,
    this.startLongitude,
  })  : id = id ?? const Uuid().v4(),
        photos = photos ?? [],
        expenses = expenses ?? [];
}
