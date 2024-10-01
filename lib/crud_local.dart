import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Home_screen extends StatefulWidget {
  const Home_screen({super.key});
  @override
  State<Home_screen> createState() => _Home_screenState();
}

class _Home_screenState extends State<Home_screen> {
  late Database _database1;
  TextEditingController _title = new TextEditingController();
  TextEditingController _desc = new TextEditingController();
  List<Map<String, dynamic>> _tudus = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchTodos();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database1 = await openDatabase(
      join(await getDatabasesPath(), 'todos_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE todo(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT,desc TEXT)",
        );
      },
      version: 1,
    );
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final List<Map<String, dynamic>> todos = await _database1.query('todo');
    setState(() {
      _tudus = todos;
    });
  }

  Future<void> _addTodo(String task, String desc) async {
    if (task.isNotEmpty && desc.isNotEmpty) {
      await _database1.insert(
        'todo',
        {'title': task, 'desc': desc},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('add ');
    }
    _fetchTodos();
  }

  Future<void> _deleteTodo(int id) async {
    await _database1.delete(
      'todo',
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchTodos();
  }

  Future<void> _updateTodo(int id, String newTitle, String newDec) async {
    await _database1.update(
      'todo',
      {'title': newTitle, 'desc': newDec},
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchTodos();
  }

  void showButtom(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _title,
              ),
              TextField(
                controller: _desc,
              ),
              ElevatedButton(
                  onPressed: () {
                    _addTodo(_title.text, _desc.text);
                    Navigator.pop(context);
                  },
                  child: Text("add"))
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(_tudus);
    return Scaffold(
      floatingActionButton: ElevatedButton(
          onPressed: () {
            showButtom(context);
            _title.clear();
            _desc.clear();
            //   Navigator.push(context, MaterialPageRoute(builder: (context) => ,))
          },
          child: Text('add')),
      appBar: AppBar(
        title: Text('CRUD USING SDFLITE'),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: _tudus.length,
            itemBuilder: (context, index) {
              final todo = _tudus[index];
              TextEditingController _titleController =
                  TextEditingController(text: todo['title']);
              TextEditingController _descController =
                  TextEditingController(text: todo['desc']);
              return ListTile(
                leading: CircleAvatar(child: Text(todo['id'].toString())),
                title: Text(todo['title']),
                subtitle: Text(todo['desc']),
                trailing: Container(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _titleController,
                                    ),
                                    TextField(
                                      controller: _descController,
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          _updateTodo(
                                              todo['id'],
                                              _titleController.text,
                                              _descController.text);
                                          Navigator.pop(context);
                                        },
                                        child: Text("edit"))
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteTodo(todo['id']);
                        },
                        icon: Icon(Icons.delete),
                      )
                    ],
                  ),
                ),
              );
            },
          ))
        ],
      )),
    );
  }
}
