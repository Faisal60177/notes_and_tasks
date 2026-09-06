import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/connectivity_service.dart';
import 'features/todo/data/datasources/todo_local_datasource.dart';
import 'features/todo/data/datasources/todo_remote_datasource.dart';
import 'features/todo/data/repository/todo_repository.dart';
import 'presentation/cubit/todo_cubit.dart';
import 'presentation/pages/todo_page.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  final repository = TodoRepository(
      local: TodoLocalDatasource(),
      remote: TodoRemoteDatasource(userId: userId),
      connectivity: ConnectivityService(),
  );

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget{
  final TodoRepository repository;
  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo(Cubit)',
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => TodoCubit(repository)..loadTodos(),
      child: const TodoPage(),) ,
    );
  }


}