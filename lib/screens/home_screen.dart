import 'package:flutter/material.dart';
import 'notes/notes_list_screen.dart';
import 'todos/todo_list_screen.dart';

// HomeScreen — App এর মূল screen, BottomNavigationBar দিয়ে দুটো section switch করা যাবে
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // এখন কোন tab selected — 0 = Notes, 1 = Todos
  int _currentIndex = 0;

  // দুটো screen — index অনুযায়ী দেখাবে
  final List<Widget> _screens = const [
    NotesListScreen(),
    TodoListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack — সব screen একসাথে রাখে কিন্তু একটাই দেখায়
      // PageView এর চেয়ে ভালো কারণ screen switch করলে state হারায় না
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.note_outlined),
            activeIcon: Icon(Icons.note), // selected হলে ভরা icon
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            activeIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }
}