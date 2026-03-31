import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final nameController = TextEditingController();

  bool supportAlerts = false;
  int timelineDays = 7;
  bool saving = false;

  Future<void> finishSetup() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name")),
      );
      return;
    }

    setState(() => saving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final email = FirebaseAuth.instance.currentUser!.email;

    /// ✅ Save Profile in Firestore
    await FirebaseFirestore.instance.collection("users").doc(uid).set({
      "name": nameController.text.trim(),
      "email": email,
      "supportAlerts": supportAlerts,
      "timelineDays": timelineDays,
      "createdAt": FieldValue.serverTimestamp(),
    });

    setState(() => saving = false);

    /// ✅ GO TO HOME (Correct Route)
    Navigator.pushReplacementNamed(context, "/home");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        centerTitle: true,
        backgroundColor: const Color(0xFFB39DDB), // Deep Purple 200
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF3E5F5), // Purple 50
              const Color(0xFFE1BEE7), // Purple 100
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: const Icon(Icons.person, size: 60, color: Color(0xFFB39DDB)),
              ),
              const SizedBox(height: 20),

              Text(
                "Let’s personalize your experience ✨",
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 25),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: SwitchListTile(
                  value: supportAlerts,
                  activeColor: const Color(0xFFB39DDB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  secondary: const Icon(Icons.group_add, color: Color(0xFFF48FB1)),
                  title: const Text(
                    "Enable Support Circle Alerts",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    "Notify trusted contacts if your mood stays low for a while.",
                    style: TextStyle(fontSize: 12),
                  ),
                  onChanged: (val) {
                    setState(() => supportAlerts = val);
                  },
                ),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<int>(
                value: timelineDays,
                decoration: InputDecoration(
                  labelText: "Mood Alert Timeline",
                  prefixIcon: const Icon(Icons.timer_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 7, child: Text("7 Days")),
                  DropdownMenuItem(value: 14, child: Text("14 Days")),
                ],
                onChanged: (val) {
                  setState(() => timelineDays = val!);
                },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB39DDB),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: saving ? null : finishSetup,
                  child: saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save & Continue →",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
