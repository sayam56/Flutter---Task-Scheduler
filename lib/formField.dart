import 'package:cached_grinz_alpha/model/task.dart';
import 'package:cached_grinz_alpha/taskListView.dart';
import 'package:cached_grinz_alpha/utils/helper.dart';
import 'package:flutter/material.dart';
import './taskListView.dart';

class NewTaskForm extends StatefulWidget {
  @override
  NewTaskFormState createState() {
    return NewTaskFormState();
  }
}

class NewTaskFormState extends State<NewTaskForm> {
  Task task = Task('');

  DatabaseHelper helper = DatabaseHelper();
  List<Task> taskList;

  final inputController = TextEditingController();

  final taskListInstance = new TaskReorderListState();

  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      child: TextFormField(
        autofocus: true,
        focusNode: myFocusNode,
        controller: inputController,
        textInputAction: TextInputAction.done,
        validator: (text) {
          if (text.isEmpty) {
            return 'Please insert a task';
          }
          return null;
        },
        decoration: InputDecoration(
          icon: Icon(Icons.add_box),
          hintText: 'Enter A New Task',
        ),
        onFieldSubmitted: (text) {
          if (_formKey.currentState.validate()) {
            setState(() {
              task.title = inputController.text;
              _save();
              inputController.clear();
              myFocusNode.requestFocus();
              taskListInstance.build(context);
            });
          }
        },
      ),
    );
  }

  // Save data to database
  void _save() async {
    int result;
    if (task.id != null) {
      // Case 1: Update operation
      result = await helper.updateTask(task);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertTask(task);
    }

    if (result != 0) {
      // Success
      print('sucessfully pushed');
    } else {
      // Failure
      print('failed');
    }
  }
}
