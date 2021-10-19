import 'package:flutter/material.dart';
import 'package:apps/base/base_param.dart';
import 'dart:async';
import 'package:apps/db_todolist.dart';
import 'model/task.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:MyToDoPage(),
    );
  }
}

class MyToDoPage extends StatefulWidget {
  const MyToDoPage({Key? key}) : super(key: key);

  static const String title = appName;
  @override
  _MyToDoPageState createState() => _MyToDoPageState();
}

class _MyToDoPageState extends State<MyToDoPage> {
  late List<Task> todoList = [];
  Task task = new Task.empty();

  @override
  void initState() {
    super.initState();

    refreshToDoList();
  }

  Future refreshToDoList() async {
    this.todoList = await ToDoListDatabase.instance.readAllToDo();
    setState(() => {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Things To Do'),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.search),
          ),
          Icon(Icons.sort),
        ],
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
          itemCount: todoList.length,
          itemBuilder: (context, index) {
             return GestureDetector(
               onLongPress: () => navigateToDetail(index),
               child: Card(
              child: Container (
                child: Row (
                  children: [
                    Expanded(
                      flex: 100,
                      child: Column(
                        children: <Widget>[
                          Row(children: [
                            Text('${todoList[index].title}',
                                style: TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 20,)
                            ),
                          ]),
                          Row(
                            children: [
                              Padding(padding: EdgeInsets.fromLTRB(16,0,0,0),
                                  child : Text('${todoList[index].desc}',
                                    style: TextStyle(fontSize: 16 ),)
                              )
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                delTask(todoList[index].id);
                                },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
             );
          },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createForm,
        tooltip: 'Create',
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
  void createForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateForm(todoList,null )),
    ).then(refresh);
  }

  void navigateToDetail(int index) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CreateForm(todoList, index);
    })).then(refresh);

  }

  FutureOr refresh(dynamic value) {
    setState(() {
      refreshToDoList();
    });
  }

  Future updateToDoList(Task task) async {
    await ToDoListDatabase.instance.update(task);
  }

  Future delTask(int id) async{
    await ToDoListDatabase.instance.delete(id).then(refresh);
  }
}

class CreateForm extends StatefulWidget {
  int? index;
  List<Task> todolist;
  CreateForm (this.todolist, this.index);

  @override
  State<StatefulWidget> createState() {
    return _CreateFormState();
  }
}

class _CreateFormState extends State<CreateForm> {
  final _formKey = GlobalKey<FormState>();
  Task tempTask = new Task.empty();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  bool isSwitched = false;

  @override
  void dispose(){
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.index != null){
      titleController.text = widget.todolist[widget.index!].getTitle;
      descController.text = widget.todolist[widget.index!].getDesc;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("New"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child : TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      controller: titleController,
                    ),
                  ),
                ],
                ),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
                        controller: descController,
                      )
                  ),
                ],
              ),
              ]
          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(widget.index != null){
            tempTask.setTitle = titleController.text;
            tempTask.setDesc = descController.text;

            widget.todolist[widget.index!].title = tempTask.title;
            widget.todolist[widget.index!].desc = tempTask.desc;
            print(tempTask.desc);
            print(tempTask.title);
            print(tempTask);
            updateValueTask(widget.todolist[widget.index!]);
            print(widget.todolist[widget.index!]);
            Navigator.pop(context);

          } else if (_formKey.currentState!.validate()) {
            tempTask.setTitle = titleController.text;
            tempTask.setDesc = descController.text;

            print(tempTask.desc);
            print(tempTask.title);
            addTask(tempTask);
            widget.todolist.add(tempTask);
            print(widget.todolist);
            print(widget.todolist.length);
            Navigator.pop(context);
          }
        },
        child: const Icon(Icons.check),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  Future addTask(Task task) async {
    await ToDoListDatabase.instance.create(task);
  }
  Future updateValueTask(Task task) async {
    await ToDoListDatabase.instance.update(task);
  }
}
