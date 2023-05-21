import 'package:flutter/material.dart';

import 'database_helper.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    final users = await _databaseHelper.getAllUsers();
    setState(() {
      _users = users;
    });
  }

  void _addUser() async {
    final name = _nameController.text;
    final age = int.tryParse(_ageController.text);

    if (name.isNotEmpty && age != null) {
      final user = User(name: name, age: age);
      await _databaseHelper.addUser(user);
      _nameController.clear();
      _ageController.clear();
      _loadUsers();
    }
  }

  void _deleteUser(int id) async {
    await _databaseHelper.deleteUser(id);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Database'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _ageController,
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _addUser,
                  child: Text('Add User'),
                ),
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    title: Text(user.name!),
                    subtitle: Text('Age: ${user.age}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showEditDialog(user, user.name.toString(), user.age.toString()),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteUser(user.id!),
                        ),
                      ],
                    ),
                  );
                },
              )

          ),
        ],
      ),
    );
  }
  void _showEditDialog(User user, String name, String age) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        _nameController.text = name;
        _ageController.text = age;
        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(

                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),

              ),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                //initialValue: user.age.toString(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateUser(user);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
  void _updateUser(User user) async {
    final updatedUser = User(
      id: user.id,
      name: _nameController.text,
      age: int.tryParse(_ageController.text),
    );

    if (updatedUser.name!.isNotEmpty && updatedUser.age != null) {
      await _databaseHelper.updateUser(updatedUser);
      _nameController.clear();
      _ageController.clear();
      _loadUsers();
    }
  }

}
