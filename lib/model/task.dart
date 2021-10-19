
final String tableTask = 'task';
class TaskFields{
  static final List<String> values = [
    /// Add all fields
    id,
    title,
    desc,
  ];

  static final String id = '_id';
  static final String title = 'title';
  static final String desc = 'desc';
}

class Task {
  static int number = 0;
  var id;
  var title;
  var desc;

  Task({
    this.id,
    required this.title,
    required this.desc,});

  Task copy({
    int? id,
    String? title,
    String? desc, }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        desc: desc ?? this.desc,
      );

  Task.empty(){
    this.title = '';
    this.desc = '';
  }

  Map<String, Object?> toJson() => {
    TaskFields.id: this.id,
    TaskFields.title: this.title,
    TaskFields.desc: this.desc,
  };

  static Task fromJson(Map<String, Object?> json){
    return Task(
      id: json[TaskFields.id] as int?,
      title: json[TaskFields.title] as String,
      desc: json[TaskFields.desc] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'title': title,
      'desc': desc,
    };
  }
  //setter
  set setTitle(String title){
    this.title = title;
  }
  set setDesc(String desc){
    this.desc = desc;
  }
  //getter
  String get getTitle{
    return title;
  }
  String get getDesc{
    return desc;
  }


  @override
  String toString() {
    return 'ToDo{id: $id, title: $title, desc: $desc}';
  }
}