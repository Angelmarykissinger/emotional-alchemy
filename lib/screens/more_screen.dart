import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sleep_screen.dart';
import 'tasks_screen.dart';
import 'support_screen.dart';
import 'profile_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // Lavender background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF3E5F5), // Lavender
              Color(0xFFFCE4EC), // Baby Pink
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Explore More",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A148C),
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(24),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildMoreCard(
                      context,
                      "Sleep",
                      Icons.bed_outlined,
                      const Color(0xFFE8EAF6),
                      const SleepScreen(),
                    ),
                    _buildMoreCard(
                      context,
                      "Tasks",
                      Icons.check_circle_outline,
                      const Color(0xFFFCE4EC),
                      const TasksScreen(),
                    ),
                    _buildMoreCard(
                      context,
                      "Support",
                      Icons.people_outline,
                      const Color(0xFFE0F2F1),
                      const SupportScreen(),
                    ),
                    _buildMoreCard(
                      context,
                      "Profile",
                      Icons.person_outline,
                      const Color(0xFFFFF3E0),
                      const ProfileScreen(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreCard(BuildContext context, String title, IconData icon, Color bgColor, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF4A148C), size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
