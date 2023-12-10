import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_api/screens/add_page.dart';
import 'package:http/http.dart' as http;

class Todolist extends StatefulWidget {
  const Todolist({super.key});

  @override
  State<Todolist> createState() => _TodolistState();
}

class _TodolistState extends State<Todolist> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTodoAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        title: const Text('Todo List'),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(
          child: CircularProgressIndicator(),
        ),
        replacement: RefreshIndicator(
          onRefresh: fetchTodoAll,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map;
              final id = item["_id"] as String;
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      //to Edit Page
                      navigateToEditPage(item);
                    } else if (value == 'delete') {
                      //operate delete
                      deleteById(id);
                    } else {
                      print('Error Page');
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text('Edit'),
                        value: 'edit',
                      ),
                      PopupMenuItem(
                        child: Text('Delete'),
                        value: 'delete',
                      ),
                    ];
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: Text('+ Data'),
      ),
    );
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => const AddPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodoAll();
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodoAll();
  }

  //delete List by id
  Future<void> deleteById(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filter = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filter;
      });
    } else {
      showFailedMessage('Failed Delete');
    }
  }

  //Api Get All
  Future<void> fetchTodoAll() async {
    setState(() {
      isLoading = true;
    });
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=20';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    //for display data on front
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void showFailedMessage(String massage) {
    final snackBar = SnackBar(
      content: Text(
        massage,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.redAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
