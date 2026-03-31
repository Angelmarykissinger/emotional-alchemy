import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final taskController = TextEditingController();
  bool adding = false;

  /// ✅ Add Task
  Future<void> addTask() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final text = taskController.text.trim();
    if (text.isEmpty) return;

    setState(() => adding = true);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("tasks")
        .add({
      "title": text,
      "completed": false,
      "timestamp": FieldValue.serverTimestamp(),
    });

    taskController.clear();
    setState(() => adding = false);
  }

  /// ✅ Toggle Completion
  Future<void> toggleTask(String id, bool current) async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("tasks")
        .doc(id)
        .update({"completed": !current});
  }

  /// ✅ Delete Task
  Future<void> deleteTask(String id) async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("tasks")
        .doc(id)
        .delete();
  }

  /// ✅ Task Stream
  Stream<QuerySnapshot> taskStream() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("tasks")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  /// ✅ Task Progress Count
  Widget taskProgress(List docs) {
    final total = docs.length;
    final done = docs.where((t) => t["completed"] == true).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        "Progress: $done / $total completed",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Tasks"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF3E5F5), // Purple 50
              const Color(0xFFE1BEE7), // Purple 100
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// ✅ Input Box
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                hintText: "Add a new task...",
                filled: true,
                fillColor: Colors.deepPurple.shade50,
                prefixIcon: const Icon(Icons.task_alt),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// ✅ Add Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: adding ? null : addTask,
                icon: adding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(
                  adding ? "Adding..." : "Add Task",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// ✅ Live Task List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: taskStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No tasks yet.\nStart building your routine 💜",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      taskProgress(
                        docs.map((e) => e.data()).toList(),
                      ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final task =
                                docs[index].data() as Map<String, dynamic>;

                            final completed = task["completed"];

                            return Card(
                              elevation: 4,
                              margin:
                                  const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                  value: completed,
                                  activeColor: Colors.deepPurple,
                                  onChanged: (_) {
                                    toggleTask(
                                      docs[index].id,
                                      completed,
                                    );
                                  },
                                ),
                                title: Text(
                                  task["title"],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    decoration: completed
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () =>
                                      deleteTask(docs[index].id),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
