import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseViewerScreen extends StatelessWidget {
  const DatabaseViewerScreen({super.key});

  Stream<QuerySnapshot> getCollection(String name) {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection(name)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Widget buildCollection(String title, String collectionName) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: getCollection(collectionName),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(),
              );
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(10),
                child: Text("No data yet."),
              );
            }

            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                return ListTile(
                  title: Text(data.toString()),
                );
              }).toList(),
            );
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Database Live Viewer"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          const Text(
            "Live Firestore Data",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          buildCollection("📓 Journals", "journals"),
          buildCollection("✅ Tasks", "tasks"),
          buildCollection("🛏 Sleep Logs", "sleepLogs"),
          buildCollection("💬 Chat Messages", "chatMessages"),
        ],
      ),
    );
  }
}
