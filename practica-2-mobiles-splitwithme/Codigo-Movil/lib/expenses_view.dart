import 'package:flutter/material.dart';
import 'expenses_viewmodel.dart';
import 'expense_dialog.dart';
import 'expense_detail.dart';
import 'models.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key, required this.title, required this.viewModel});

  final String title;
  final ExpensesViewModel viewModel;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchController = TextEditingController();
  Expense? _selectedExpense;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([widget.viewModel, widget.viewModel.load]),
        builder: (context, child) {
          if (widget.viewModel.load.running) {
            return const Center(child: CircularProgressIndicator());
          }

          final query = _searchController.text.toLowerCase();
          final filtered = widget.viewModel.expenses.where((e) {
            final desc = e.description.toLowerCase();
            final date = e.date.toLowerCase();
            final id = (e.id ?? 0).toString();
            return desc.contains(query) || date.contains(query) || id.contains(query);
          }).toList();

          final listView = Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search expenses...',
                    // No suffix icon: use single floating action button to add expenses
                  ),
                  onChanged: (v) => setState(() {}),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No expenses'))
                    : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final e = filtered[index];
                    final idLabel = (e.id ?? 0).toString().padLeft(2, '0');
                    return ListTile(
                      leading: const Icon(Icons.monetization_on),
                      title: Text('$idLabel - ${e.description}'),
                      subtitle: Text('${e.date}  ${e.amount.toStringAsFixed(2)}€  •  ${e.numFriends} friends'),
                      trailing: IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          if (isTablet) {
                            setState(() => _selectedExpense = e);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ExpenseDetailScreen(expense: e)),
                            );
                          }
                        },
                      ),
                      onTap: () {
                        if (isTablet) {
                          setState(() => _selectedExpense = e);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ExpenseDetailScreen(expense: e)),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );

          if (!isTablet) return listView;

          return Row(
            children: [
              Expanded(flex: 2, child: listView),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 3,
                child: _selectedExpense != null
                    ? ExpenseDetailScreen(expense: _selectedExpense!)
                    : const Center(
                  child: Text(
                    'Select an expense to see details',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => ExpenseDialog(
            onAdd: (expense) async {
              await widget.viewModel.addExpense.execute(expense);
            },
          ),
        ),
        tooltip: 'Add expense',
        child: const Icon(Icons.add),
      ),
    );
  }
}
