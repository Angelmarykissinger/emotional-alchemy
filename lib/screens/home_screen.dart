import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'profile_screen.dart';
import 'recommendation_details.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onQuickAction;

  const HomeScreen({super.key, required this.onQuickAction});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String avgMood = "...";
  String avgSleep = "...";
  String taskComp = "...";

  @override
  void initState() {
    super.initState();
    fetchHomeStats();
  }

  Future<void> fetchHomeStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final now = DateTime.now();
      final fiveDaysAgo = now.subtract(const Duration(days: 4));
      final start = Timestamp.fromDate(DateTime(fiveDaysAgo.year, fiveDaysAgo.month, fiveDaysAgo.day));

      // Mood 
      final journals = await FirebaseFirestore.instance.collection("users").doc(user.uid).collection("journals").where("timestamp", isGreaterThanOrEqualTo: start).get();
      double mSum = 0;
      for (var d in journals.docs) { mSum += (d["moodScore"] as num?)?.toDouble() ?? 5.0; }
      String mLab = "No Data";
      if (journals.docs.isNotEmpty) {
         double mAvg = mSum / journals.docs.length;
         if (mAvg >= 7) mLab = "Happy";
         else if (mAvg <= 4) mLab = "Low";
         else mLab = "Neutral";
      }

      // Tasks
      final tasks = await FirebaseFirestore.instance.collection("users").doc(user.uid).collection("tasks").where("timestamp", isGreaterThanOrEqualTo: start).get();
      int tCompleted = 0;
      for (var d in tasks.docs) { if (d["completed"] == true) tCompleted++; }
      String tLab = tasks.docs.isNotEmpty ? "${((tCompleted / tasks.docs.length) * 100).toInt()}%" : "None";

      // Sleep
      final sleep = await FirebaseFirestore.instance.collection("users").doc(user.uid).collection("sleepLogs").where("timestamp", isGreaterThanOrEqualTo: start).get();
      double sHours = 0;
      
      double parseToHours(String t) {
         t = t.toLowerCase().replaceAll('\u202F', ' ').trim();
         bool pm = t.contains('pm');
         bool am = t.contains('am');
         String timeOnly = t.replaceAll(RegExp(r'[^0-9:]'), '');
         List<String> parts = timeOnly.split(':');
         if (parts.isEmpty || parts[0].isEmpty) return 0.0;
         int h = int.tryParse(parts[0]) ?? 0;
         int m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
         if (pm && h != 12) h += 12;
         if (am && h == 12) h = 0;
         return h + (m / 60.0);
      }
      
      for (var d in sleep.docs) {
         try {
            String bStr = d['bedtime']?.toString() ?? "";
            String wStr = d['wakeTime']?.toString() ?? "";
            if (bStr.isNotEmpty && wStr.isNotEmpty) {
               double bH = parseToHours(bStr);
               double wH = parseToHours(wStr);
               if (wH < bH) wH += 24.0;
               sHours += (wH - bH);
            }
         } catch(_) {}
      }
      String sLab = sleep.docs.isNotEmpty ? "${(sHours / sleep.docs.length).toStringAsFixed(1)}h" : "None";

      if (mounted) {
         setState(() {
            avgMood = mLab;
            taskComp = tLab;
            avgSleep = sLab;
         });
      }
    } catch (e) {
      debugPrint("Home Stats Error: $e");
    }
  }

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
              /// ✅ Header & Quote in AppBar area
              _buildAppBarSection(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      /// ✅ Analytics Section
                      _buildAnalyticsSection(context),

                      const SizedBox(height: 30),

                      /// ✅ Recommendations Section
                      _buildRecommendationsSection(context),

                      const SizedBox(height: 30),

                      /// ✅ Module Icons Box - Moved to bottom
                      _buildModuleIconsBox(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6), // Soft Lavender/Blue
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Progress",
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("Mood (Avg)", avgMood, Icons.sentiment_satisfied_alt, Colors.orange),
              _buildStatItem("Sleep (Avg)", avgSleep, Icons.bedtime_outlined, Colors.indigo),
              _buildStatItem("Task Comp.", taskComp, Icons.task_alt, Colors.green),
            ],
          ),
          const SizedBox(height: 15),
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                );
              },
              icon: const Icon(Icons.analytics_outlined, size: 16),
              label: const Text("View Detailed Stats"),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF1A237E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarSection() {
    final hour = DateTime.now().hour;
    String greeting = "Good Evening";
    if (hour < 12) greeting = "Good Morning";
    else if (hour < 17) greeting = "Good Afternoon";

    final quotes = [
      "\"Happiness is not something readymade. It comes from your own actions.\"",
      "\"The only way to do great work is to love what you do.\"",
      "\"Believe you can and you're halfway there.\"",
      "\"Inner peace begins the moment you choose not to allow another person or event to control your emotions.\"",
      "\"You are enough just as you are.\"",
    ];
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final randomQuote = quotes[dayOfYear % quotes.length];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo',
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.black, // Dark background to match logo
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF80CBC4), // Matching teal border
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Transform.scale(
                      scale: 1.4, // Zoom in to hide bottom text and center AE
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        isAntiAlias: true,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "Emotional Alchemy",
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A148C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            greeting,
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.grey[700],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.8)),
            ),
            child: Column(
              children: [
                const Text(
                  "Everyday Quote",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E24AA),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  randomQuote,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleIconsBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9), // Yellowish Green
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Access",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF33691E),
            ),
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 10,
            children: [
              _buildSmallIcon(Icons.book_outlined, "Journal", 1),
              _buildSmallIcon(Icons.chat_bubble_outline, "Chat", 2),
              _buildSmallIcon(Icons.bar_chart_outlined, "Stats", 3),
              _buildSmallIcon(Icons.check_circle_outline, "Tasks", 4),
              _buildSmallIcon(Icons.bed_outlined, "Sleep", 5),
              _buildSmallIcon(Icons.people_outline, "Support", 6),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIcon(IconData icon, String label, int index) {
    return InkWell(
      onTap: () => widget.onQuickAction(index),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF4A148C), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Uplift Your Mood",
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4A148C),
          ),
        ),
        const SizedBox(height: 15),
        _buildRecommendationCard(
          context,
          "Uplifting Songs",
          "Khairiyat / Stay With Me",
          const Color(0xFFFCE4EC), // Baby Pink
          Icons.music_note,
        ),
        _buildRecommendationCard(
          context,
          "Movie Picks",
          "Twinkling Watermelon / 2521",
          const Color(0xFFF3E5F5), // Lavender
          Icons.movie_outlined,
        ),
        _buildRecommendationCard(
          context,
          "Self-Care Exercises",
          "5 Min Deep Breathing / Stretching",
          const Color(0xFFF1F8E9), // Yellowish Green
          Icons.self_improvement,
        ),
        _buildRecommendationCard(
          context,
          "New Skills to Learn",
          "Painting / Crochet / Origami",
          const Color(0xFFFFF3E0), // Soft Orange
          Icons.brush,
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, String title, String subtitle, Color bgColor, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecommendationDetailsScreen(category: title),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4A148C)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF4A148C)),
          ],
        ),
      ),
    );
  }
}
