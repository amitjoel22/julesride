import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import 'manage_groups_screen.dart';
import 'ride_details_screen.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bike Rides'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageGroupsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: Consumer<RideProvider>(
        builder: (context, provider, child) {
          if (provider.rides.isEmpty) {
            return const Center(child: Text('No rides yet. Start a new one!'));
          }
          return ListView.builder(
            itemCount: provider.rides.length,
            itemBuilder: (context, index) {
              final ride = provider.rides[index];
              return ListTile(
                title: Text(ride.name),
                subtitle: Text(ride.date.toLocal().toString().split(' ')[0]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RideDetailsScreen(rideId: ride.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRideDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRideDialog(BuildContext context) {
    final nameController = TextEditingController();
    RideGroup? selectedGroup;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Start New Ride'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Ride Name'),
                  ),
                  Consumer<RideProvider>(
                    builder: (context, provider, child) {
                      if (provider.groups.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text('No groups available. You can add one from the groups page.'),
                        );
                      }
                      return DropdownButton<RideGroup>(
                        hint: const Text('Select Group'),
                        value: selectedGroup,
                        isExpanded: true,
                        items: provider.groups.map((group) {
                          return DropdownMenuItem<RideGroup>(
                            value: group,
                            child: Text(group.name),
                          );
                        }).toList(),
                        onChanged: (group) {
                          setState(() {
                            selectedGroup = group;
                          });
                        },
                      );
                    },
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      double? lat;
                      double? lng;
                      try {
                        LocationPermission permission = await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          permission = await Geolocator.requestPermission();
                        }
                        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
                           Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                           lat = position.latitude;
                           lng = position.longitude;
                        }
                      } catch (e) {
                        debugPrint("Error getting location: \$e");
                      }

                      final newRide = Ride(
                        name: nameController.text,
                        date: DateTime.now(),
                        group: selectedGroup,
                        startLatitude: lat,
                        startLongitude: lng,
                      );
                      Provider.of<RideProvider>(context, listen: false).addRide(newRide);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Start'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
