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
  static const bool _isAdmin = bool.fromEnvironment('IS_ADMIN', defaultValue: false);

  int _currentIndex = 0;

  final List<Widget> _tabs = [const PlayTab(), const LeaderboardTab(), if (_isAdmin) const AddQuestionTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LevelUp42 by AaronSGomez', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 10)),
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
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill), label: 'Jugar'),
            const BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Ranking'),
            if (_isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Aportar'),
          ],
        ),
      ),
    );
  }
}
