import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'journal_screen.dart';
import 'chat_screen.dart';
import 'analytics_screen.dart';
import 'tasks_screen.dart';
import 'sleep_screen.dart';
import 'support_screen.dart';
import 'more_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onQuickAction: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      const JournalScreen(),
      const ChatScreen(),
      const AnalyticsScreen(),
      const TasksScreen(),
      const SleepScreen(),
      const SupportScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex > 3 ? 0 : selectedIndex, // Safety for index out of bounds
        children: [
          HomeScreen(
            onQuickAction: (index) {
              if (index == 1 || index == 2) {
                setState(() => selectedIndex = index);
              } else {
                // Navigate to screens not in the bottom bar
                Widget? screen;
                if (index == 3) screen = const AnalyticsScreen();
                if (index == 4) screen = const TasksScreen();
                if (index == 5) screen = const SleepScreen();
                if (index == 6) screen = const SupportScreen();

                if (screen != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
                }
              }
            },
          ),
          JournalScreen(onBack: () => setState(() => selectedIndex = 0)),
          ChatScreen(onBack: () => setState(() => selectedIndex = 0)),
          const MoreScreen(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex > 3 ? 0 : selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: "Journal"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
        ],
      ),
    );
  }
}
