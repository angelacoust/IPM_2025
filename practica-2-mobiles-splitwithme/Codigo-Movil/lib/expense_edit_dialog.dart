import 'package:flutter/material.dart';
import 'utils/date_validator.dart';

/// Shows an alert dialog to edit an expense.
/// 
/// Pre-fills the dialog with current expense data (description, date, amount).
/// Validates all fields:
/// - description: non-empty
/// - date: YYYY-MM-DD format with realistic day/month values
/// - amount: valid decimal number greater than 0
/// 
/// Returns a Map with keys: description, date, amount
/// or null if cancelled.
Future<Map<String, dynamic>?> showExpenseEditDialog(
  BuildContext context, {
  required String description,
  required String date,
  required double amount,
}) async {
  final descController = TextEditingController(text: description);
  final dateController = TextEditingController(text: date);
  final amountController = TextEditingController(text: amount.toString());

  return showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Editar Gasto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  hintText: '2024-01-15',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final desc = descController.text.trim();
              final dateStr = dateController.text.trim();
              final amountStr = amountController.text.trim();

              // Validations
              if (desc.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La descripción no puede estar vacía')),
                );
                return;
              }

              if (dateStr.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La fecha no puede estar vacía')),
                );
                return;
              }

              if (!isValidDateFormat(dateStr)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Formato de fecha inválido. Usa YYYY-MM-DD con día/mes válidos',
                    ),
                  ),
                );
                return;
              }

              if (amountStr.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La cantidad no puede estar vacía')),
                );
                return;
              }

              double? parsedAmount;
              try {
                parsedAmount =
                    double.parse(amountStr.replaceAll(',', '.'));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cantidad inválida')),
                );
                return;
              }

              if (parsedAmount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La cantidad debe ser mayor a 0')),
                );
                return;
              }

              Navigator.of(context).pop<Map<String, dynamic>>({
                'description': desc,
                'date': dateStr,
                'amount': parsedAmount,
              });
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}
