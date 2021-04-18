class Task {
  int _id;
  String _task='';

  Task(this._task);

  Task.withId(this._id, this._task);

  int get id => _id;

  String get title => _task;

  set title(String newTask) {
    if (newTask.length <= 255) {
      this._task = newTask;
    }
  }

  // Convert a task object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['task'] = _task;
    return map;
  }

  // Extract a task object from a Map object
  Task.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._task = map['task'];
  }
}
