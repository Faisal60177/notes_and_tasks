import 'package:flutter/material.dart';
import 'package:notes_app/presentation/pages/notes_page.dart';
import 'package:notes_app/presentation/pages/profile_page.dart';
import 'package:notes_app/presentation/pages/todo_page.dart';

class HomeShell extends StatefulWidget{
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();

}

class _HomeShellState extends State<HomeShell> {
  int _index = 1;

  static const _pages = [
    NotesPage(),
    TodoPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages,),
      bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),

          destinations: const[
            NavigationDestination(icon: Icon(Icons.note_alt_outlined), label: 'Notes'),
            NavigationDestination(icon: Icon(Icons.check_circle_outline), label: 'Tasks'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          ]),
    );
  }
}