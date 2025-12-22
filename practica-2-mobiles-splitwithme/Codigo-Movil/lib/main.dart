import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitwithfriends/services.dart';

import 'home_screen.dart';
import 'repositories.dart';
import 'expenses_viewmodel.dart';

void main() {
  var providers = [
    Provider<SplitWithMeService>(
      create: (context) => SplitWithMeAPIService(),
    ),
    Provider(
      create: (context) => FriendRepository(service: context.read<SplitWithMeService>()),
    ),
    Provider(
      create: (context) => ExpenseRepository(service: context.read<SplitWithMeService>()),
    ),
    // Expenses view model (ChangeNotifier)
    ChangeNotifierProvider(
      create: (context) => ExpensesViewModel(expenseRepository: context.read<ExpenseRepository>()),
    ),
  ];

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SplitWithMe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.blue[50],
        appBarTheme: AppBarTheme(backgroundColor: Colors.blue),
      ),
      home: HomeScreen(),
    );
  }
}
