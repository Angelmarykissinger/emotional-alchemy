import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool loading = false;

  /// ✅ Add Contact
  Future<void> addSupportPerson() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter name + phone")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("supportCircle")
        .add({
      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "timestamp": FieldValue.serverTimestamp(),
    });

    nameController.clear();
    phoneController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to Support Circle")),
    );
  }

  /// ✅ Delete Contact
  Future<void> deleteContact(String docId) async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("supportCircle")
        .doc(docId)
        .delete();
  }

  /// ✅ Mood Trigger Check (Uses Journal MoodScore)
  Future<void> checkLowMoodAlert() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    /// Load timelineDays from Profile
    final profileDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    int timelineDays = profileDoc.data()?["timelineDays"] ?? 7;

    /// Get last N journal entries
    final journals = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("journals")
        .orderBy("timestamp", descending: true)
        .limit(timelineDays)
        .get();

    int lowCount = 0;
    int normalCount = 0;

    for (var doc in journals.docs) {
      final moodScore = doc["moodScore"];
      if (moodScore <= 4) lowCount++;
      if (moodScore >= 5) normalCount++;
    }

    final alertsRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("supportAlerts");

    final activeAlerts = await alertsRef.where("status", isEqualTo: "active").get();

    /// Clear alerts if mood normalizes significantly
    if (normalCount >= 3) {
       for (var doc in activeAlerts.docs) {
          await doc.reference.update({"status": "resolved"});
       }
       return;
    }

    /// Trigger new alert if majority days low and no active alert
    if (activeAlerts.docs.isEmpty && lowCount >= (timelineDays * 0.7).round()) {
      await alertsRef.add({
        "message": "⚠ User has been feeling low for $timelineDays days. Support Circle should check in.",
        "timestamp": FieldValue.serverTimestamp(),
        "status": "active"
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠ Support Alert Triggered!")),
        );
      }
    } else if (activeAlerts.docs.isNotEmpty) {
      /// Auto Dialer logic for unresolved alerts older than 2 hours
      final activeDoc = activeAlerts.docs.first;
      final timestamp = activeDoc["timestamp"] as Timestamp?;

      if (timestamp != null) {
        final diff = DateTime.now().difference(timestamp.toDate());
        if (diff.inHours >= 2) {
          final profileData = profileDoc.data();
          final lastCall = profileData?["lastAutoCallDate"] as String?;
          final todayStr = DateTime.now().toIso8601String().split('T')[0];

          if (lastCall != todayStr) {
            final contacts = await FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .collection("supportCircle")
                .limit(1)
                .get();

            if (contacts.docs.isNotEmpty) {
              final phone = contacts.docs.first["phone"];
              final url = Uri.parse("tel:$phone");
              
              if (await canLaunchUrl(url)) {
                await launchUrl(url);

                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .set({"lastAutoCallDate": todayStr}, SetOptions(merge: true));
              }
            }
          }
        }
      }
    }
  }

  /// ✅ Streams
  Stream<QuerySnapshot> supportStream() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("supportCircle")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> alertStream() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("supportAlerts")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    checkLowMoodAlert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support Circle"),
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
          padding: const EdgeInsets.all(18),
        child: ListView(
          children: [
            /// ✅ Heading
            const Text(
              "Trusted Contacts 💜",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// ✅ Input Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Person Name",
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.deepPurple.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        prefixIcon: const Icon(Icons.phone),
                        filled: true,
                        fillColor: Colors.deepPurple.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: addSupportPerson,
                        icon: const Icon(Icons.add),
                        label: const Text(
                          "Add Contact",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// ✅ Contacts List
            const Text(
              "Your Support Circle",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: supportStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final contacts = snapshot.data!.docs;

                if (contacts.isEmpty) {
                  return const Text("No contacts added yet.");
                }

                return Column(
                  children: contacts.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.people, color: Colors.white),
                        ),
                        title: Text(data["name"]),
                        subtitle: Text(data["phone"]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => deleteContact(doc.id),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),

            /// ✅ Alerts Log
            const Text(
              "Alert Logs ⚠",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: alertStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final alerts = snapshot.data!.docs;

                if (alerts.isEmpty) {
                  return const Text("No alerts triggered yet.");
                }

                return Column(
                  children: alerts.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data.containsKey("status") ? data["status"] : "active";
                    final message = status == "resolved" ? "${data["message"]} (Resolved)" : data["message"];

                    return Card(
                      color: status == "resolved" ? Colors.grey.shade200 : Colors.red.shade50,
                      child: ListTile(
                        leading: Icon(Icons.warning, color: status == "resolved" ? Colors.grey : Colors.red),
                        title: Text(message),
                        trailing: status == "active" ? IconButton(
                           icon: const Icon(Icons.phone, color: Colors.green),
                           onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) return;
                              final contacts = await FirebaseFirestore.instance.collection("users").doc(user.uid).collection("supportCircle").limit(1).get();
                              if (contacts.docs.isNotEmpty) {
                                 final phone = contacts.docs.first["phone"];
                                 await launchUrl(Uri.parse("tel:$phone"));
                                 
                                 // Prevent auto-dialing today if user dialed manually
                                 final todayStr = DateTime.now().toIso8601String().split('T')[0];
                                 await FirebaseFirestore.instance
                                     .collection("users")
                                     .doc(user.uid)
                                     .set({"lastAutoCallDate": todayStr}, SetOptions(merge: true));
                              }
                           }
                        ) : null,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
        ),
      ),
    );
  }
}
