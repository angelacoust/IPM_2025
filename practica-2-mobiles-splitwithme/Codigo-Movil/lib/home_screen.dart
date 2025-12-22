import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'friends_view.dart';
import 'friends_viewmodel.dart';
import 'repositories.dart';
import 'expenses_view.dart';
import 'expenses_viewmodel.dart';
import 'expense_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final friendRepo = Provider.of<FriendRepository>(context, listen: false);
    final expenseVm = Provider.of<ExpensesViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SplitWithMe'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Split your expenses with friends!',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Botón crear gasto
            SizedBox(
              width: 260,
              child: ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ExpenseDialog(
                    onAdd: (expense) async {
                      await expenseVm.addExpense.execute(expense);
                    },
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '+ Create an expense',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Botones Friends / Expenses
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Friends
                SizedBox(
                  width: 150,
                  height: 140,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendsScreen(
                          title: 'Friends',
                          viewModel: FriendViewModel(
                            friendRepository: friendRepo,
                          ),
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color.fromARGB(255, 138, 189, 240),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 42, color: Colors.black),
                        SizedBox(height: 8),
                        Text(
                          'Friends',
                          style:
                          TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Expenses
                SizedBox(
                  width: 150,
                  height: 140,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpensesScreen(
                          title: 'Expenses',
                          viewModel: expenseVm,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color.fromARGB(255, 138, 189, 240),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 42, color: Colors.black),
                        SizedBox(height: 8),
                        Text(
                          'Expenses',
                          style:
                          TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
