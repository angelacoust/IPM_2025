import 'package:flutter/material.dart';

class UpdateCreditDialog extends StatefulWidget {
  const UpdateCreditDialog({super.key, required this.friendName});

  final String friendName;

  @override
  State<StatefulWidget> createState() => _UpdateCreditDialogState();
}

class _UpdateCreditDialogState extends State<UpdateCreditDialog> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update ${widget.friendName} Credit'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: amountController,
          decoration: const InputDecoration(
            labelText: 'Amount to add',
            hintText: 'Enter positive amount',
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.isEmpty) return 'You have not added a required field';
            final n = double.tryParse(v.replaceAll(',', '.'));
            if (n == null) return 'Invalid input format. Please try again.';
            if (n <= 0) return 'Invalid input format. Please try again.';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final amtText = amountController.text.trim().replaceAll(',', '.');
            final amount = double.parse(amtText);
            Navigator.pop(context, amount);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
