import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'tabs/play_tab.dart';
import 'tabs/leaderboard_tab.dart';
import 'tabs/add_question_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [PlayTab(), LeaderboardTab(), AddQuestionTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LevelUp42 Trivia', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill), label: 'Jugar'),
            BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Ranking'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Aportar'),
          ],
        ),
      ),
    );
  }
}
