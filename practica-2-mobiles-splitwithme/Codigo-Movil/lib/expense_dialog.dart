import 'package:flutter/material.dart';

import 'models.dart';
import 'utils/date_validator.dart';

class ExpenseDialog extends StatefulWidget {
  const ExpenseDialog({super.key, required this.onAdd});

  final Future<void> Function(Expense) onAdd;

  @override
  State<StatefulWidget> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    dateController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => (v == null || v.isEmpty) ? 'You have not added a required field' : null,
              ),
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'You have not added a required field';
                  if (!isValidDateFormat(v.trim())) return 'Invalid date. Use YYYY-MM-DD with valid day/month.';
                  return null;
                },
              ),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'You have not added a required field';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null) return 'Invalid input format. Please try again.';
                  if (n <= 0) return 'Invalid input format. Please try again.';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            final amtText = amountController.text.trim().replaceAll(',', '.');
            final expense = Expense(
              description: descriptionController.text.trim(),
              date: dateController.text.trim(),
              amount: double.parse(amtText),
            );
            // Capture navigator and messenger before async gap to avoid using
            // BuildContext synchronously after await.
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);
            try {
              await widget.onAdd(expense);
              navigator.pop();
            } catch (e) {
              // Show user friendly error
              final msg = (e is Exception) ? e.toString() : 'An error occurred';
              messenger.showSnackBar(SnackBar(content: Text(msg)));
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
