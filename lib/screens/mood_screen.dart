import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String selectedMood = "Happy 😊";

  Future<void> saveMood() async {
    await FirebaseFirestore.instance.collection("moods").add({
      "mood": selectedMood,
      "user": FirebaseAuth.instance.currentUser!.email,
      "timestamp": Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mood Saved Successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moods = [
      "Happy 😊",
      "Sad 😢",
      "Angry 😠",
      "Stressed 😰",
      "Calm 😌",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Tracker"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          DropdownButton(
            value: selectedMood,
            items: moods
                .map((m) =>
                    DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (val) {
              setState(() => selectedMood = val!);
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saveMood,
            child: const Text("Save Mood"),
          ),

          const Divider(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("moods")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc["mood"]),
                      subtitle: Text(doc["user"]),
                    );
                  }).toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
