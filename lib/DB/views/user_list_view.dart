import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  final UserRepository _userRepository = UserRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _channelNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Analytics - Users'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _userRepository.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final users = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user.userName),
                      subtitle: Text(user.channelName),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _userRepository.delete(user.userId);
                          setState(() {});
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'User Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a user name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _channelNameController,
                  decoration: const InputDecoration(labelText: 'Channel Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a channel name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final user = User(
                    userId: const Uuid().v4(),
                    userName: _nameController.text,
                    channelName: _channelNameController.text,
                    channelCreationDate: DateTime.now(),
                    description: _descriptionController.text,
                    totalViews: 0,
                    totalSubs: 0,
                    totalComments: 0,
                    totalWatchtime: 0,
                    totalRevenue: 0,
                    channelImageLink: '',
                  );

                  await _userRepository.insert(user);
                  if (mounted) {
                    Navigator.of(context).pop();
                    setState(() {});
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

  @override
  void dispose() {
    _nameController.dispose();
    _channelNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
