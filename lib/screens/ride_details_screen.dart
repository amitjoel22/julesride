import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/ride_provider.dart';
import '../models/models.dart';

class RideDetailsScreen extends StatelessWidget {
  final String rideId;

  const RideDetailsScreen({super.key, required this.rideId});

  @override
  Widget build(BuildContext context) {
    final ride = Provider.of<RideProvider>(context)
        .rides
        .firstWhere((r) => r.id == rideId);

    double totalExpenses = ride.expenses.fold(0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(ride.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(ride, totalExpenses),
            const Divider(),
            _buildSectionHeader('Photos'),
            _buildPhotoGrid(ride),
            const Divider(),
            _buildSectionHeader('Food Expenses'),
            _buildExpensesList(ride),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "photo_btn",
            onPressed: () => _addPhoto(context, rideId),
            tooltip: 'Add Photo',
            child: const Icon(Icons.add_a_photo),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "expense_btn",
            onPressed: () => _showAddExpenseDialog(context, rideId),
            tooltip: 'Add Expense',
            child: const Icon(Icons.attach_money),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Ride ride, double totalExpenses) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${ride.date.toLocal().toString().split(' ')[0]}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Group: ${ride.group?.name ?? "None"}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Total Expenses: \$${totalExpenses.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (ride.startLatitude != null && ride.startLongitude != null) ...[
              const SizedBox(height: 8),
              Text('Start Location: ${ride.startLatitude?.toStringAsFixed(4)}, ${ride.startLongitude?.toStringAsFixed(4)}'),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPhotoGrid(Ride ride) {
    if (ride.photos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No photos yet.'),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ride.photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemBuilder: (context, index) {
        final photo = ride.photos[index];
        return GestureDetector(
          onTap: () {
            _showPhotoDialog(context, photo);
          },
          child: Image.file(
            File(photo.path),
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  void _showPhotoDialog(BuildContext context, Photo photo) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(photo.path)),
              if (photo.description != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(photo.description!),
                ),
              if (photo.latitude != null && photo.longitude != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Lat: ${photo.latitude?.toStringAsFixed(4)}, Lng: ${photo.longitude?.toStringAsFixed(4)}'),
                )
            ],
          ),
        );
      }
    );
  }

  Widget _buildExpensesList(Ride ride) {
    if (ride.expenses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No food expenses yet.'),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ride.expenses.length,
      itemBuilder: (context, index) {
        final expense = ride.expenses[index];
        return ListTile(
          leading: const Icon(Icons.fastfood),
          title: Text(expense.description),
          trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
        );
      },
    );
  }

  Future<void> _addPhoto(BuildContext context, String rideId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
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

      // Normally we'd ask for a description here
      final newPhoto = Photo(
        path: image.path,
        latitude: lat,
        longitude: lng,
        description: 'Ride photo'
      );

      // ignore: use_build_context_synchronously
      Provider.of<RideProvider>(context, listen: false).addPhotoToRide(rideId, newPhoto);
    }
  }

  void _showAddExpenseDialog(BuildContext context, String rideId) {
    final descController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Food Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description (e.g., Lunch)'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (descController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null) {
                    final newExpense = Expense(
                      amount: amount,
                      description: descController.text,
                    );
                    Provider.of<RideProvider>(context, listen: false)
                        .addExpenseToRide(rideId, newExpense);
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
