import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen1 extends StatefulWidget {
  const HomeScreen1({super.key});

  @override
  State<HomeScreen1> createState() => _HomeScreen1State();
}

class _HomeScreen1State extends State<HomeScreen1> {
  late Database _database1;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _citynameController = TextEditingController();
  String? _selectedCityId;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _cities = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database1 = await openDatabase(
      join(await getDatabasesPath(), 'users_and_cities.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cities(
            cityid TEXT PRIMARY KEY,
            cityname TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            cityid TEXT,
            FOREIGN KEY(cityid) REFERENCES cities(cityid)
          );
        ''');
      },
      version: 1,
    );
    _fetchUsers();
    _fetchCities();
  }

  Future<void> _fetchUsers() async {
    final List<Map<String, dynamic>> users = await _database1.query('users');
    setState(() {
      _users = users;
    });
  }

  Future<void> _fetchCities() async {
    final List<Map<String, dynamic>> cities = await _database1.query('cities');
    setState(() {
      _cities = cities;
    });
  }

  Future<void> _addUser(String username, String cityid) async {
    if (username.isNotEmpty && cityid.isNotEmpty) {
      await _database1.insert(
        'users',
        {'username': username, 'cityid': cityid},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _fetchUsers();
    }
  }

  Future<void> _addCity(String cityid, String cityname) async {
    if (cityid.isNotEmpty && cityname.isNotEmpty) {
      await _database1.insert(
        'cities',
        {'cityid': cityid, 'cityname': cityname},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _fetchCities();
    }
  }

  Future<void> _deleteUser(int id) async {
    await _database1.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchUsers();
  }

  Future<void> _updateUser(int id, String newUsername, String newCityid) async {
    await _database1.update(
      'users',
      {'username': newUsername, 'cityid': newCityid},
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchUsers();
  }

  void showBottomSheet(BuildContext context,
      {bool isAddingUser = true, Map<String, dynamic>? user}) {
    if (user != null) {
      _usernameController.text = user['username'];
      _selectedCityId = user['cityid'];
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Enter Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCityId,
                hint: Text('Select City'),
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                items: _cities.map<DropdownMenuItem<String>>((city) {
                  return DropdownMenuItem<String>(
                    value: city['cityid'],
                    child: Text(city['cityname']),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedCityId = value;
                  });
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (isAddingUser) {
                    _addUser(_usernameController.text, _selectedCityId!);
                  } else {
                    _updateUser(user!['id'], _usernameController.text,
                        _selectedCityId!);
                  }
                  Navigator.pop(context);
                },
                child: Text(isAddingUser ? "Add User" : "Update User"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  showAddCityDialog(context);
                },
                child: Text('Add City'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showAddCityDialog(BuildContext context) {
    TextEditingController _newCityIdController = TextEditingController();
    TextEditingController _newCityNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New City'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newCityIdController,
                decoration: InputDecoration(
                  labelText: 'City ID',
                ),
              ),
              TextField(
                controller: _newCityNameController,
                decoration: InputDecoration(
                  labelText: 'City Name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addCity(
                    _newCityIdController.text, _newCityNameController.text);
                Navigator.pop(context);
              },
              child: Text('Add City'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _usernameController.clear();
          _selectedCityId = null;
          showBottomSheet(context);
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.add,
          size: 30,
          color: Colors.blueAccent,
        ),
      ),
      appBar: AppBar(
        title: Text('CRUD with Cities'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text((index + 1).toString()),
                    ),
                    title: Text(user['username']),
                    subtitle: Text(user['cityid']),
                    trailing: Container(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {
                              showBottomSheet(context,
                                  isAddingUser: false, user: user);
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _deleteUser(user['id']);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
