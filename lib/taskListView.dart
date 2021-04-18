import 'package:cached_grinz_alpha/model/task.dart';
import 'package:cached_grinz_alpha/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

class TaskReorderList extends StatefulWidget {
  @override
  TaskReorderListState createState() => TaskReorderListState();
}

class TaskReorderListState extends State<TaskReorderList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<String> items = [];
  Task task = Task('');

  final inputController = TextEditingController();

  List<Task> taskList;

  var lastIndex = 0;

  int index = 0;
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

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList();
      taskListFuture.then((taskList) {
        setState(() {
          this.taskList = taskList;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    if (taskList == null) {
      taskList = List<Task>();
      updateListView();
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: ReorderableListView(
            children: <Widget>[
              for (final item in taskList)
                Dismissible(
                  key: ValueKey(item),
                  onDismissed: (direction) {
                    setState(() {
                      _delete(context, this.taskList[taskList.indexOf(item)]);
                      taskList.removeAt(taskList.indexOf(item));
                      lastIndex = taskList.lastIndexOf(item);
                      
                      Vibration.vibrate(duration: 100);
                    });
                  },
                  child: Card(
                    key: ValueKey(item),
                    child: ListTile(
                      dense: true,
                      title: TextField(
                        /* controller: _itemController, */
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: this.taskList[taskList.indexOf(item)].title,
                        ),
                      ),
                      leading: Icon(
                        Icons.add_box_outlined,
                        color: Colors.black,
                      ),
                      autofocus: false,
                      trailing: IconButton(
                        icon: Icon(Icons.cancel_outlined),
                        color: Colors.black,
                        onPressed: () {
                          setState(() {
                            _delete(context, this.taskList[taskList.indexOf(item)]);
                            
                            Vibration.vibrate(duration: 100);
                          });
                        },
                      ),
                    ),
                  ),
                  background: Container(
                    color: Colors.red,
                  ),
                ),
            ],
            onReorder: (oldIndex, newIndex) {
              Vibration.vibrate(duration: 50);
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex = newIndex - 1;
                }
                final item = taskList.removeAt(oldIndex);
                taskList.insert(newIndex, item);
                lastIndex = taskList.lastIndexOf(item);
              });
            },
          ),
        ),
        Form(
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
                });
              }
            },
          ),
        ),
      ],
    );
  }

  // Save data to database
  void _save() async {
    int result;
    if (task.id != null) {
      // Case 1: Update operation
      result = await databaseHelper.updateTask(task);
    } else {
      // Case 2: Insert Operation
      result = await databaseHelper.insertTask(task);
    }

    if (result != 0) {
      // Success
      print('sucessfully pushed');
      updateListView();
    } else {
      // Failure
      print('failed');
    }
  }


    void _delete(BuildContext context, Task task) async {

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (task.id == null) {
      return;
    }
    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await databaseHelper.deleteTask(task.id);
    if (result != 0) {
      print('Task Deleted Successfully');
      updateListView();
    } else {
      print('Error Occured while Deleting Note');
    }
  }
}
