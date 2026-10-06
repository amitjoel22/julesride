import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';
import '../models/models.dart';

class ManageGroupsScreen extends StatelessWidget {
  const ManageGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Groups'),
      ),
      body: Consumer<RideProvider>(
        builder: (context, provider, child) {
          if (provider.groups.isEmpty) {
            return const Center(child: Text('No groups yet. Create one!'));
          }
          return ListView.builder(
            itemCount: provider.groups.length,
            itemBuilder: (context, index) {
              final group = provider.groups[index];
              return ExpansionTile(
                title: Text(group.name),
                children: [
                  ...group.riders.map((rider) => ListTile(
                        title: Text(rider.name),
                        leading: const Icon(Icons.person),
                      )),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add Rider'),
                    onTap: () => _showAddRiderDialog(context, group.id),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context),
        child: const Icon(Icons.group_add),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Group'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Group Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newGroup = RideGroup(name: nameController.text);
                  Provider.of<RideProvider>(context, listen: false)
                      .addGroup(newGroup);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showAddRiderDialog(BuildContext context, String groupId) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Rider to Group'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Rider Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newRider = Rider(name: nameController.text);
                  Provider.of<RideProvider>(context, listen: false)
                      .addRider(newRider);
                  Provider.of<RideProvider>(context, listen: false)
                      .addRiderToGroup(groupId, newRider);
                  Navigator.pop(context);
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
