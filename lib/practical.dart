import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> datalist = [];
  bool ishow = false;

  final nameController = TextEditingController();
  final Random random = Random();

  Future<void> getData() async {
    setState(() {
      ishow = false;
    });
    final response = await http
        .get(Uri.parse("https://66f56a079aa4891f2a2521bf.mockapi.io/crud"));
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      setState(() {
        datalist = jsondata;
        ishow = true;
      });
    } else {
      print("Error fetching data");
      setState(() {
        ishow = true;
      });
    }
  }

  Future<void> postData(Map<String, dynamic> map) async {
    final response = await http.post(
      Uri.parse("https://66f56a079aa4891f2a2521bf.mockapi.io/crud"),
      body: map,
    );
    print(response.body);
    if (response.statusCode == 201) {
      print("Data added");
      getData();
    } else {
      print("Failed to add data");
    }
  }

  Future<void> updateData(String id, Map<String, dynamic> map) async {
    final response = await http.put(
      Uri.parse("https://66f56a079aa4891f2a2521bf.mockapi.io/crud/$id"),
      body: map,
    );
    if (response.statusCode == 200) {
      print("Data updated");
      getData();
    } else {
      print("Failed to update data");
    }
  }

  Future<void> deleteData(String id) async {
    final response = await http.delete(
      Uri.parse("https://66f56a079aa4891f2a2521bf.mockapi.io/crud/$id"),
    );
    if (response.statusCode == 200) {
      print("Data deleted");
      getData();
    } else {
      print("Failed to delete data");
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void showUpdateDialog(String id, String currentName) {
    nameController.text = currentName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Data"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Enter new name",
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Map<String, dynamic> map = {'name': nameController.text};
                  updateData(id, map);
                  nameController.clear();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Name cannot be empty")));
                }
              },
              child: Text("Update"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Add Data"),
                content: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Enter name",
                  ),
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          Map<String, dynamic> map = {
                            'name': nameController.text
                          };
                          postData(map);
                          nameController.clear();
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Name cannot be empty")));
                        }
                      },
                      child: Text("Add"))
                ],
              );
            },
          );
        },
        child: Text("Add"),
      ),
      appBar: AppBar(
        title: Text("API Data List"),
      ),
      body: ishow == false
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.separated(
              itemCount: datalist.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final item = datalist[datalist.length - index - 1];
                return ListTile(
                  title: Text(
                    item["name"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text("ID: ${item["id"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showUpdateDialog(item["id"], item["name"]);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Delete Data"),
                                content: Text(
                                    "Are you sure you want to delete this item?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteData(item["id"]);
                                      Navigator.pop(context);
                                    },
                                    child: Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
