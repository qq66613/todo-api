import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPage extends StatefulWidget {
  final Map? todo;
  const AddPage({super.key, this.todo});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];

      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
        title: Text(isEdit ? 'Edit Todo List' : 'Add Todo List'),
      ),
      body: ListView(
        padding: EdgeInsets.all(25),
        children: [
          TextField(
            decoration: InputDecoration(hintText: 'Title'),
            controller: titleController,
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: 'Description'),
            keyboardType: TextInputType.multiline,
            minLines: 4,
            maxLines: 10,
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: isEdit ? updateData : submitData,
              child: Text(isEdit ? 'Edit Submit' : 'Submit'))
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print("You can't Updated");
      return;
    }
    final id = todo['_id'];
    //final iscompleted = todo['is_completed'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      showSuccessMessage('Success Created');
    } else {
      showFailedMessage('Failed Created');
      print(response.body);
    }
  }

  Future<void> submitData() async {
    // this handle to form
    // get the data form Form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    // Submit data to server
    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    // can show succes or fail message based on status
    if (response.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage('Succes Created');
    } else {
      showFailedMessage('Failed Created');
      print(response.body);
    }
  }

  void showSuccessMessage(String massage) {
    final snackBar = SnackBar(
      content: Text(
        massage,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blue,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
