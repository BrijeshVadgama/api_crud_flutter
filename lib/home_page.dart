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
  List<dynamic> filteredDataList = []; // To hold filtered data
  bool ishow = false; // Controls whether data is loaded

  final searchController = TextEditingController(); // Search input controller
  final Random random = Random(); // Random instance to generate colors

  Future<void> getData() async {
    setState(() {
      ishow = false; // Start loading
    });
    final response = await http
        .get(Uri.parse("https://66f56a079aa4891f2a2521bf.mockapi.io/crud"));
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      setState(() {
        datalist = jsondata;
        filteredDataList = datalist; // Initially show all data
        ishow = true; // Data loaded successfully
      });
    } else {
      print("Error fetching data");
      setState(() {
        ishow = true; // End loading even if there's an error
      });
    }
  }

  Future<void> postData(Map<String, dynamic> map) async {
    final response = await http.post(
        Uri.parse("https://66f56a079aa4891f2a2521bf.mockapi.io/crud"),
        body: map);
    print(response.body);
    if (response.statusCode == 201) {
      print("Data added");
      getData(); // Refresh data after adding
    } else {
      print("Failed to add data");
    }
  }

  Future<void> updateData(String id, Map<String, dynamic> map) async {
    final response = await http.put(
        Uri.parse("https://65d6d5fef6967ba8e3beadc1.mockapi.io/crud/$id"),
        body: map);
    if (response.statusCode == 200) {
      print("Data updated");
      getData(); // Refresh data after updating
    } else {
      print("Failed to update data");
    }
  }

  Future<void> deleteData(String id) async {
    final response = await http.delete(
        Uri.parse("https://65d6d5fef6967ba8e3beadc1.mockapi.io/crud/$id"));
    if (response.statusCode == 200) {
      print("Data deleted");
      getData(); // Refresh data after deletion
    } else {
      print("Failed to delete data");
    }
  }

  @override
  void initState() {
    super.initState();
    getData(); // Fetch data on initialization
  }

  final nameController = TextEditingController();

  // Function to handle search input
  void filterData(String query) {
    setState(() {
      filteredDataList = datalist
          .where((item) =>
              item["name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Generate a random color
  Color getRandomColor() {
    return Color.fromRGBO(
      random.nextInt(256), // Random red value
      random.nextInt(256), // Random green value
      random.nextInt(256), // Random blue value
      1, // Full opacity
    );
  }

  void showUpdateDialog(String id, String currentName) {
    nameController.text = currentName; // Set the current name in the controller
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
                          Map<String, dynamic> map = {};
                          map['name'] = nameController.text;
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                filterData(value); // Filter data as the user types
              },
            ),
          ),
          Expanded(
            child: ishow == false
                ? Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator
                : ListView.separated(
                    itemCount: filteredDataList.length,
                    separatorBuilder: (context, index) =>
                        Divider(), // Add divider between items
                    itemBuilder: (context, index) {
                      final item =
                          filteredDataList[filteredDataList.length - index - 1];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: getRandomColor(), // Set random color
                          child: Text(
                            item["name"][0].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
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
                                showUpdateDialog(item["id"],
                                    item["name"]); // Show update dialog
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
                                            Navigator.pop(
                                                context); // Cancel deletion
                                          },
                                          child: Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            deleteData(
                                                item["id"]); // Delete item
                                            Navigator.pop(
                                                context); // Close dialog
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
          ),
        ],
      ),
    );
  }
}
