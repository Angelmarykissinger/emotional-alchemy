import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../main.dart'; // import AuthWrapper

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  String gender = "Other";
  DateTime? dob;
  String? photoUrl;
  XFile? _imageFile;

  bool supportAlerts = false;
  int timelineDays = 7;

  bool loading = false;

  final uid = FirebaseAuth.instance.currentUser!.uid;
  final email = FirebaseAuth.instance.currentUser!.email;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// ✅ Load Profile Data
  Future<void> loadProfile() async {
    final doc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;

      nameController.text = data["name"] ?? "";
      bioController.text = data["bio"] ?? "";
      gender = data["gender"] ?? "Other";
      if (data["dob"] != null) {
        dob = (data["dob"] as Timestamp).toDate();
      }
      photoUrl = data["photoUrl"];
      supportAlerts = data["supportAlerts"] ?? false;
      timelineDays = data["timelineDays"] ?? 7;

      setState(() {});
    }
  }

  /// ✅ Save Profile Updates
  Future<void> saveProfile() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance.collection("users").doc(uid).set({
      "name": nameController.text.trim(),
      "bio": bioController.text.trim(),
      "gender": gender,
      "dob": dob != null ? Timestamp.fromDate(dob!) : null,
      "photoUrl": photoUrl,
      "supportAlerts": supportAlerts,
      "timelineDays": timelineDays,
      "email": email,
    }, SetOptions(merge: true));

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(" Profile Updated Successfully")),
    );

    Navigator.pop(context);
  }

  /// ✅ LOGOUT PERFECT FIX
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    }
  }

  /// ✅ Pick Image Function
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = image;
        // In a real app, you'd upload this to Firebase Storage and get a URL.
        // For now, we'll use the local path/blob as a placeholder.
        photoUrl = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // Lavender background
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF4A148C),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              /// ✅ Profile Image Section
              Stack(
                children: [
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFFE1BEE7),
                        backgroundImage: _imageFile != null
                            ? (kIsWeb
                                ? NetworkImage(_imageFile!.path)
                                : FileImage(File(_imageFile!.path)) as ImageProvider)
                            : (photoUrl != null ? NetworkImage(photoUrl!) : null),
                        child: (_imageFile == null && photoUrl == null)
                            ? const Icon(Icons.person, size: 80, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A148C),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                email ?? "",
                style: GoogleFonts.lato(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 30),

              /// ✅ Profile Fields
              _buildProfileField(
                label: "Full Name",
                controller: nameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildProfileField(
                label: "Bio",
                controller: bioController,
                icon: Icons.info_outline,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: "Gender",
                      value: gender,
                      items: ["Male", "Female", "Non-binary", "Other"],
                      onChanged: (val) => setState(() => gender = val!),
                    ),
                  ),
                  const SizedBox(width: 10), // Reduced from 15
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dob ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => dob = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), // Reduced horizontal padding
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date of Birth",
                              style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              dob == null ? "Select Date" : "${dob!.day}/${dob!.month}/${dob!.year}",
                              style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              /// ✅ Settings Section
              const Divider(),
              const SizedBox(height: 10),
              SwitchListTile(
                title: Text("Support Alerts", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                subtitle: Text("Notify contacts if mood stays low", style: GoogleFonts.lato(fontSize: 12)),
                value: supportAlerts,
                activeColor: const Color(0xFF4A148C),
                onChanged: (val) => setState(() => supportAlerts = val),
              ),
              const SizedBox(height: 10),
              _buildDropdownField(
                label: "Alert Timeline",
                value: timelineDays,
                items: [7, 14],
                onChanged: (val) => setState(() => timelineDays = val!),
                prefix: "Every ",
                suffix: " Days",
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A148C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Save Changes",
                          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: const Color(0xFF4A148C)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String prefix = "",
    String suffix = "",
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Reduced horizontal padding from 16
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
          border: InputBorder.none,
        ),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text("$prefix$item$suffix", style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
