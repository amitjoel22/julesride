import 'package:flutter/foundation.dart';
import '../models/models.dart';

class RideProvider with ChangeNotifier {
  final List<Ride> _rides = [];
  final List<RideGroup> _groups = [];
  final List<Rider> _riders = [];

  List<Ride> get rides => _rides;
  List<RideGroup> get groups => _groups;
  List<Rider> get riders => _riders;

  void addRide(Ride ride) {
    _rides.add(ride);
    notifyListeners();
  }

  void addGroup(RideGroup group) {
    _groups.add(group);
    notifyListeners();
  }

  void addRider(Rider rider) {
    _riders.add(rider);
    notifyListeners();
  }

  void addPhotoToRide(String rideId, Photo photo) {
    final rideIndex = _rides.indexWhere((ride) => ride.id == rideId);
    if (rideIndex != -1) {
      _rides[rideIndex].photos.add(photo);
      notifyListeners();
    }
  }

  void addExpenseToRide(String rideId, Expense expense) {
    final rideIndex = _rides.indexWhere((ride) => ride.id == rideId);
    if (rideIndex != -1) {
      _rides[rideIndex].expenses.add(expense);
      notifyListeners();
    }
  }

  void addRiderToGroup(String groupId, Rider rider) {
    final groupIndex = _groups.indexWhere((group) => group.id == groupId);
    if (groupIndex != -1) {
      _groups[groupIndex].riders.add(rider);
      notifyListeners();
    }
  }
}
