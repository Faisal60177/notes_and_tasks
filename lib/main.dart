import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/note_controller.dart';
import 'controllers/todo_controller.dart';
import 'screens/home_screen.dart';

// main() — App এর শুরু এখান থেকে
void main() {
  // WidgetsFlutterBinding.ensureInitialized() — Flutter engine প্রস্তুত করো
  // async কাজ main() এ করার আগে এটা দরকার
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp()); // App চালু করো
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      // GetMaterialApp — GetX এর MaterialApp
      // এটা ব্যবহার করলে Get.to(), Get.back(), Get.snackbar() সব কাজ করবে
      title: 'Do ALL Notes',
      debugShowCheckedModeBanner: false, // Debug banner সরাও

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Material Design 3 চালু করো
      ),

      // initialBinding — App শুরুতেই এই controllers তৈরি করে রাখো
      // পরে Get.find() দিয়ে যেকোনো জায়গা থেকে access করা যাবে
      initialBinding: BindingsBuilder(() {
        // put() — controller তৈরি করো ও register করো
        Get.put(NoteController());
        Get.put(TodoController());
      }),

      home: const HomeScreen(), // প্রথম screen
    );
  }
}