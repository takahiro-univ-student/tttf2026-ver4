import 'package:flutter/material.dart';
import 'explore_screen.dart';
import 'island_bot_screen.dart';
import 'kids_bot_screen.dart';
import 'saved_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  final pages = const [
    ExploreScreen(),
    IslandBotScreen(),
    KidsBotScreen(),
    SavedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore), label: '探索'),
          NavigationDestination(icon: Icon(Icons.chat_bubble), label: '島AI'),
          NavigationDestination(icon: Icon(Icons.quiz), label: 'キッズ'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: '寄せ書き'),
        ],
      ),
    );
  }
}