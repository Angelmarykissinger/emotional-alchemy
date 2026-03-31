import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MoodAlertScreen extends StatefulWidget {
  const MoodAlertScreen({super.key});

  @override
  State<MoodAlertScreen> createState() => _MoodAlertScreenState();
}

class _MoodAlertScreenState extends State<MoodAlertScreen> {
  bool isLoading = true;
  bool moodLow = false;

  List<String> supportContacts = [];
  int timelineDays = 7;

  @override
  void initState() {
    super.initState();
    checkMoodTimeline();
  }

  Future<void> checkMoodTimeline() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    /// Fetch user profile timeline
    final profileDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final profile = profileDoc.data()!;

    timelineDays = profile["timelineDays"];
    supportContacts =
        List<String>.from(profile["supportContacts"] ?? []);

    /// Fetch journal entries
    final journalSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("journals")
        .orderBy("timestamp", descending: true)
        .limit(timelineDays)
        .get();

    final journals = journalSnapshot.docs;

    /// Check if moodScore is LOW (<4) for all days
    if (journals.length >= timelineDays) {
      moodLow = journals.every((doc) {
        final score = doc["moodScore"];
        return score <= 3;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Safety Check"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : moodLow
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.warning,
                          size: 80, color: Colors.red),
                      const SizedBox(height: 15),

                      Text(
                        "Your mood has been low for $timelineDays days.",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Support Circle Contacts to Notify:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      Expanded(
                        child: ListView.builder(
                          itemCount: supportContacts.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(supportContacts[index]),
                              ),
                            );
                          },
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Alert Trigger Sent (Demo)"),
                            ),
                          );
                        },
                        child: const Text("Send Alert (Demo)"),
                      )
                    ],
                  ),
                )
              : const Center(
                  child: Text(
                    "Mood is Stable No alert needed.",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
    );
  }
}
