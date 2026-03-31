import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  TimeOfDay? bedtime;
  TimeOfDay? wakeTime;

  /// Pick Time
  Future<TimeOfDay?> pickTime() async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  /// ✅ Cross-check Phone Rest (based on lastActive)
  Future<String> checkDeviceRest(DateTime bedtimeDate) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "Unknown";

    final profileDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final lastActiveTimestamp = profileDoc.data()?["lastActive"];

    if (lastActiveTimestamp == null) return "No activity data";

    final lastActive = (lastActiveTimestamp as Timestamp).toDate();

    final difference = bedtimeDate.difference(lastActive).inMinutes;

    if (difference <= 10) {
      return "Phone was active near bedtime 📱";
    } else {
      return "Phone was resting before sleep 🌙";
    }
  }

  /// Save Sleep Log to Firestore
  Future<void> saveSleepLog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (bedtime == null || wakeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select both times")),
      );
      return;
    }

    /// Convert bedtime to DateTime
    final now = DateTime.now();
    final bedtimeDate = DateTime(
      now.year,
      now.month,
      now.day,
      bedtime!.hour,
      bedtime!.minute,
    );

    /// ✅ Cross-check rest state
    final restStatus = await checkDeviceRest(bedtimeDate);

    /// Save Sleep Log
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("sleepLogs")
        .add({
      "bedtime": bedtime!.format(context),
      "wakeTime": wakeTime!.format(context),
      "restStatus": restStatus,
      "timestamp": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sleep Log Saved")),
    );
  }

  /// Fetch Sleep Logs Live
  Stream<QuerySnapshot> sleepStream() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("sleepLogs")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sleep Tracker"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Pick Bedtime
            ListTile(
              title: const Text("Select Bedtime"),
              subtitle: Text(
                bedtime == null ? "Not selected" : bedtime!.format(context),
              ),
              trailing: const Icon(Icons.nightlight_round),
              onTap: () async {
                final picked = await pickTime();
                if (picked != null) setState(() => bedtime = picked);
              },
            ),

            /// Pick Wake Time
            ListTile(
              title: const Text("Select Wake-up Time"),
              subtitle: Text(
                wakeTime == null ? "Not selected" : wakeTime!.format(context),
              ),
              trailing: const Icon(Icons.wb_sunny),
              onTap: () async {
                final picked = await pickTime();
                if (picked != null) setState(() => wakeTime = picked);
              },
            ),

            const SizedBox(height: 15),

            /// Save Button
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
                onPressed: saveSleepLog,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Sleep Log",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Sleep Logs History
            const Text(
              "Sleep History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: sleepStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final logs = snapshot.data!.docs;

                  if (logs.isEmpty) {
                    return const Center(child: Text("No sleep logs yet."));
                  }

                  return ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log =
                          logs[index].data() as Map<String, dynamic>;

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.bed),
                          title: Text("Bedtime: ${log["bedtime"]}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Wake: ${log["wakeTime"]}"),
                              const SizedBox(height: 5),
                              Text(
                                log["restStatus"] ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
