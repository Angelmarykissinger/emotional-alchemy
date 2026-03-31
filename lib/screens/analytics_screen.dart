import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool isLoading = true;

  // Real data spots
  List<FlSpot> moodData = [
    const FlSpot(0, 5), // Day -4
    const FlSpot(1, 5), // Day -3
    const FlSpot(2, 5), // Day -2
    const FlSpot(3, 5), // Yesterday
    const FlSpot(4, 5), // Today
  ];

  int totalJournals = 0;
  int totalChats = 0;
  int alchemyPoints = 0;

  // New Metrics
  int completedTasks = 0;
  int totalTasks = 0;
  int sleepLogCount = 0;
  double averageSleepHours = 0.0;

  String weeklyInsightText = "Keep logging your journey to see more insights!";
  String weeklyInsightTip = "Tip: Consistent daily logging helps track progress.";

  @override
  void initState() {
    super.initState();
    fetchAnalyticsData();
  }

  Future<void> fetchAnalyticsData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final now = DateTime.now();
      final fiveDaysAgo = now.subtract(const Duration(days: 4)); // 5 days inclusive (today down to 4 days ago)
      final startOfFiveDaysAgo = DateTime(fiveDaysAgo.year, fiveDaysAgo.month, fiveDaysAgo.day);

      // --- Mood Analytics ---
      final journalsSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("journals")
          .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfFiveDaysAgo))
          .get();

      // Removed where("sender", isEqualTo: "user") to avoid Firestore Composite Index crash
      final chatsSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("chatMessages")
          .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfFiveDaysAgo))
          .get();

      totalJournals = journalsSnap.docs.length;
      totalChats = chatsSnap.docs.length;

      List<double> dailySums = [0, 0, 0, 0, 0];
      List<int> dailyCounts = [0, 0, 0, 0, 0];

      for (var doc in journalsSnap.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        final score = (data['moodScore'] as num?)?.toDouble() ?? 5.0;

        if (timestamp != null) {
          int dayDifference = _daysBetween(startOfFiveDaysAgo, timestamp);
          if (dayDifference >= 0 && dayDifference <= 4) {
             dailySums[dayDifference] += score;
             dailyCounts[dayDifference] += 1;
          }
        }
      }

      for (var doc in chatsSnap.docs) {
        final data = doc.data();
        if (data['sender'] != 'user') continue; // Client-side filter
        
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        final text = (data['text'] as String?)?.toLowerCase() ?? "";

        double chatScore = 5.0;
        if (text.contains("happy") || text.contains("good") || text.contains("great") || text.contains("thanks")) {
          chatScore = 7.0;
        } else if (text.contains("sad") || text.contains("bad") || text.contains("stress") || text.contains("hurt")) {
          chatScore = 3.0;
        }

        if (timestamp != null) {
          int dayDifference = _daysBetween(startOfFiveDaysAgo, timestamp);
          if (dayDifference >= 0 && dayDifference <= 4) {
            dailySums[dayDifference] += chatScore;
            dailyCounts[dayDifference] += 1;
          }
        }
      }

      List<FlSpot> updatedSpots = [];
      for (int i = 0; i < 5; i++) {
        double average = dailyCounts[i] > 0 ? (dailySums[i] / dailyCounts[i]) : 5.0;
        updatedSpots.add(FlSpot(i.toDouble(), average.clamp(1.0, 10.0)));
      }

      // --- Task Analytics ---
      final tasksSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("tasks")
          .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfFiveDaysAgo))
          .get();

      int tempTotalTasks = tasksSnap.docs.length;
      int tempCompletedTasks = 0;
      for (var doc in tasksSnap.docs) {
        if (doc.data()['completed'] == true) {
           tempCompletedTasks++;
        }
      }

      // --- Sleep Analytics ---
      final sleepSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("sleepLogs")
          .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfFiveDaysAgo))
          .get();

      int tempSleepLogs = sleepSnap.docs.length;
      double totalSleepHours = 0.0;
      
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
      
      for (var doc in sleepSnap.docs) {
        final data = doc.data();
        final bedStr = data['bedtime'] as String?;
        final wakeStr = data['wakeTime'] as String?;
        
        if (bedStr != null && wakeStr != null) {
           try {
              double bH = parseToHours(bedStr);
              double wH = parseToHours(wakeStr);
              if (wH < bH) wH += 24.0;
              totalSleepHours += (wH - bH);
           } catch(e) {
              debugPrint("Error parsing time: $e");
           }
        }
      }

      // Final calculations
      alchemyPoints = (totalJournals * 10) + (totalChats * 5) + (tempCompletedTasks * 15) + (tempSleepLogs * 20);
      double tempAvgSleep = tempSleepLogs > 0 ? (totalSleepHours / tempSleepLogs) : 0.0;

      // Generate Insights Check
      double avgPast = (updatedSpots[0].y + updatedSpots[1].y + updatedSpots[2].y) / 3;
      double avgRecent = (updatedSpots[3].y + updatedSpots[4].y) / 2;

      String iText = "Your emotional journey is forming. ";
      String iTip = "Tip: Log all aspects of your day to get better insights.";

      if (avgRecent > avgPast + 1) {
        iText = "Great news! Your mood is trending upwards recently.";
        iTip = "Tip: Note down what you did differently today.";
      } else if (avgRecent < avgPast - 1) {
        iText = "Things have been a bit tougher the last couple of days. Remember it's completely okay to have low periods.";
        iTip = "Tip: Check your Support Screen or reach out to a friend.";
      } else if (tempTotalTasks > 0 && (tempCompletedTasks / tempTotalTasks) > 0.8) {
         iText = "You are incredibly productive! Finishing tasks provides a strong foundation for a stable mood.";
         iTip = "Tip: Remember to balance productivity with actual rest.";
      } else if (tempAvgSleep > 0 && tempAvgSleep < 6.0) {
         iText = "Your sleep has been a bit short recently. Less than 6 hours can heavily impact your emotional resilience.";
         iTip = "Tip: Try going to bed 30 minutes earlier tonight.";
      }

      if (mounted) {
        setState(() {
          moodData = updatedSpots;
          totalTasks = tempTotalTasks;
          completedTasks = tempCompletedTasks;
          sleepLogCount = tempSleepLogs;
          averageSleepHours = tempAvgSleep;
          weeklyInsightText = iText;
          weeklyInsightTip = iTip;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching analytics: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
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
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 30),
                      _buildMoodTrendChart(moodData),
                      const SizedBox(height: 25),
                      Row(
                         children: [
                           Expanded(child: _buildTaskEfficiencyCard()),
                           const SizedBox(width: 15),
                           Expanded(child: _buildSleepBalanceCard()),
                         ],
                      ),
                      const SizedBox(height: 25),
                      _buildAlchemyPointsCard(),
                      const SizedBox(height: 30),
                      _buildWeeklyInsightCard(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4A148C)),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 15),
            Text(
              "Emotional Analytics",
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A148C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 45),
          child: Text(
            "Analyzing your emotional journey",
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodTrendChart(List<FlSpot> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
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
            "Mood Progress (Past 5 Days)",
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A148C),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 1,
                maxY: 10,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Color(0xFF6A1B9A),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        );
                        String text = '';
                        switch (value.toInt()) {
                          case 0: text = 'Day -4'; break;
                          case 1: text = 'Day -3'; break;
                          case 2: text = 'Day -2'; break;
                          case 3: text = 'Yester'; break;
                          case 4: text = 'Today'; break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 22,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF9C27B0).withOpacity(0.2),
                          const Color(0xFFE91E63).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskEfficiencyCard() {
     double efficiency = totalTasks > 0 ? (completedTasks / totalTasks) : 0;
     String status = totalTasks == 0 ? "No Tasks" : "${(efficiency * 100).toInt()}% Done";
     
     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
          ]
       ),
       child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Icon(Icons.task_alt, color: Colors.blue.shade700, size: 28),
             const SizedBox(height: 12),
             Text("Task Efficiency", style: GoogleFonts.lato(fontSize: 14, color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
             const SizedBox(height: 6),
             Text(status, style: GoogleFonts.lato(fontSize: 12, color: Colors.blue.shade800)),
             const SizedBox(height: 12),
             LinearProgressIndicator(
                value: efficiency,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
             )
          ]
       )
     );
  }

  Widget _buildSleepBalanceCard() {
     String sleepHoursFormatted = averageSleepHours.toStringAsFixed(1);
     String status = "Need Data";
     if (sleepLogCount > 0) {
        if (averageSleepHours >= 7 && averageSleepHours <= 9) status = "Optimal";
        else if (averageSleepHours < 7) status = "Needs Rest";
        else status = "Over-resting";
     }

     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
          ]
       ),
       child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Icon(Icons.nightlight_round, color: Colors.indigo.shade700, size: 28),
             const SizedBox(height: 12),
             Text("Sleep Balance", style: GoogleFonts.lato(fontSize: 14, color: Colors.indigo.shade900, fontWeight: FontWeight.bold)),
             const SizedBox(height: 6),
             Text(sleepLogCount == 0 ? status : "$sleepHoursFormatted hr/day", style: GoogleFonts.lato(fontSize: 12, color: Colors.indigo.shade800)),
             const SizedBox(height: 12),
             Row(
               children: [
                 Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(8)
                    ),
                    child: Text(status, style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo.shade600)),
                 )
               ]
             )
          ]
       )
     );
  }

  Widget _buildAlchemyPointsCard() {
    int maxLevelPoints = 500;
    // ensure points cap or scale for demo
    int currentPoints = alchemyPoints > 0 ? alchemyPoints : 0;
    while(currentPoints > maxLevelPoints && maxLevelPoints < 5000) {
       maxLevelPoints += 500;
    }
    double progress = maxLevelPoints > 0 ? (currentPoints / maxLevelPoints).clamp(0.0, 1.0) : 0;
    int pointsToNext = maxLevelPoints - currentPoints;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9), // Yellowish Green
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Alchemy Points",
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF33691E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAlchemyPointRow("Journals Logged ($totalJournals)", "+${totalJournals * 10} AP", Icons.book_outlined),
          const SizedBox(height: 10),
          _buildAlchemyPointRow("Tasks Done ($completedTasks)", "+${completedTasks * 15} AP", Icons.check_circle_outline),
          const SizedBox(height: 10),
          _buildAlchemyPointRow("Sleep Logged ($sleepLogCount)", "+${sleepLogCount * 20} AP", Icons.bed_outlined),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Level: Rising Alchemist",
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                "$currentPoints / $maxLevelPoints AP",
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A148C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A148C)),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "$pointsToNext AP to next level",
              style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlchemyPointRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[700]),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF33691E),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyInsightCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC), // Baby Pink
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Insights",
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF880E4F),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            weeklyInsightText,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF880E4F)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  weeklyInsightTip,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF880E4F),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}