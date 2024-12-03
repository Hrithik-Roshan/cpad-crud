import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List tasks = [];

  // Fetch tasks from Back4App
  Future<void> fetchTasks() async {
    final response = await http.get(
      Uri.parse('https://parseapi.back4app.com/classes/CPADTASK'),
      headers: {
        'X-Parse-Application-Id': 'app_id',
        'X-Parse-REST-API-Key': 'api_key',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        tasks = data['results'];
      });
    } else {
      print("Error fetching tasks: ${response.body}");
    }
  }

  // Add a new task
  Future<void> addTask(String taskName, String dueDate) async {
    final response = await http.post(
      Uri.parse('https://parseapi.back4app.com/classes/CPADTASK'),
      headers: {
        'X-Parse-Application-Id': 'app_id',
        'X-Parse-REST-API-Key': 'api_key',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'taskname': taskName,
        'taskstatus': false,
        'duedate': dueDate,
      }),
    );

    if (response.statusCode == 201) {
      print("Task added successfully.");
      fetchTasks(); // Refresh the task list
    } else {
      print("Error adding task: ${response.body}");
    }
  }

  // Update task status in Back4App
  Future<void> updateTaskStatus(String taskId, bool isChecked) async {
    final response = await http.put(
      Uri.parse('https://parseapi.back4app.com/classes/CPADTASK/$taskId'),
      headers: {
        'X-Parse-Application-Id': 'app_id',
        'X-Parse-REST-API-Key': 'api_key',
        'Content-Type': 'application/json',
      },
      body: json.encode({'taskstatus': isChecked}),
    );

    if (response.statusCode == 200) {
      print("Task status updated successfully.");
    } else {
      print("Error updating task status: ${response.body}");
    }
  }

  // Delete a task in Back4App
  Future<void> deleteTask(String taskId) async {
    final response = await http.delete(
      Uri.parse('https://parseapi.back4app.com/classes/CPADTASK/$taskId'),
      headers: {
        'X-Parse-Application-Id': 'app_id',
        'X-Parse-REST-API-Key': 'api_key',
      },
    );

    if (response.statusCode == 200) {
      print("Task deleted successfully.");
      fetchTasks(); // Refresh the task list
    } else {
      print("Error deleting task: ${response.body}");
    }
  }

    // Show a dialog to add a task
  void showAddTaskDialog() {
    final taskNameController = TextEditingController();
    final dueDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskNameController,
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: dueDateController,
                decoration: InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final taskName = taskNameController.text;
                final dueDate = dueDateController.text;
                if (taskName.isNotEmpty && dueDate.isNotEmpty) {
                  addTask(taskName, dueDate);
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }


  // Update task details
  Future<void> editTask(String taskId, String taskName, String dueDate) async {
    final response = await http.put(
      Uri.parse('https://parseapi.back4app.com/classes/CPADTASK/$taskId'),
      headers: {
        'X-Parse-Application-Id': 'app_id',
        'X-Parse-REST-API-Key': 'api_key',
        'Content-Type': 'application/json',
      },
      body: json.encode({'taskname': taskName, 'duedate': dueDate}),
    );

    if (response.statusCode == 200) {
      print("Task updated successfully.");
      fetchTasks(); // Refresh the task list
    } else {
      print("Error updating task: ${response.body}");
    }
  }

  // Show a dialog to edit a task
  void showEditTaskDialog(String taskId, String initialName, String initialDueDate) {
    final taskNameController = TextEditingController(text: initialName);
    final dueDateController = TextEditingController(text: initialDueDate);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskNameController,
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: dueDateController,
                decoration: InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final taskName = taskNameController.text;
                final dueDate = dueDateController.text;
                if (taskName.isNotEmpty && dueDate.isNotEmpty) {
                  editTask(taskId, taskName, dueDate);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: tasks.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task['taskname']),
                  subtitle: Text('Due: ${task['duedate']}'),
                  leading: Checkbox(
                    value: task['taskstatus'],
                    onChanged: (value) {
                      setState(() {
                        task['taskstatus'] = value;
                      });
                      updateTaskStatus(task['objectId'], value!);
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showEditTaskDialog(
                            task['objectId'],
                            task['taskname'],
                            task['duedate'],
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteTask(task['objectId']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add Task dialog
          showAddTaskDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
