import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'expenses_viewmodel.dart';
import 'models.dart';
import 'repositories.dart';
import 'update_credit_dialog.dart';
import 'expense_edit_dialog.dart';
import 'utils/result.dart';

class ExpenseDetailScreen extends StatefulWidget {
  const ExpenseDetailScreen({super.key, required this.expense});

  final Expense expense;

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  /// Participantes actuales del gasto
  final List<Friend> _participants = [];

  /// IDs de amigos que están en el gasto
  Set<int> _participantIds = {};

  /// Estado de carga de participantes
  bool _isLoadingParticipants = false;
  String? _participantsError;

  /// Copia local del gasto visible en pantalla (se actualiza tras edits)
  late Expense _currentExpense;

  /// Nota: la lista completa de amigos y la gestión de participantes
  /// la maneja el backend/otro equipo; esta pantalla solo muestra
  /// los participantes actuales y permite ver/actualizar saldos.

  @override
  void initState() {
    super.initState();
    _currentExpense = widget.expense;
    _initParticipantIdsFromExpense();
    _loadParticipants();
  }

  @override
  void didUpdateWidget(covariant ExpenseDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambiamos de gasto (modo tablet), reseteamos estado y recargamos
    if (oldWidget.expense.id != widget.expense.id) {
      _participants.clear();
      _participantsError = null;
      _currentExpense = widget.expense;
      _initParticipantIdsFromExpense();
      _loadParticipants();
    }
  }

  void _initParticipantIdsFromExpense() {
    _participantIds = {
      for (final id in (_currentExpense.participants ?? const <int>[])) id,
    };
  }

  Future<void> _loadParticipants() async {
    final repo = context.read<ExpenseRepository>();
    final id = widget.expense.id;

    if (id == null) {
      setState(() {
        _participants.clear();
        _participantIds = {};
        _participantsError = null;
        _isLoadingParticipants = false;
      });
      return;
    }

    setState(() {
      _isLoadingParticipants = true;
      _participantsError = null;
    });

    final result = await repo.listExpenseFriends(id);

    if (!mounted) return;

    switch (result) {
      case Ok<List<Friend>>():
        setState(() {
          _participants.clear();
          _participants.addAll(result.value);
          _participantIds = {
            for (final f in _participants)
              if (f.id != null) f.id!,
          };
          _isLoadingParticipants = false;
        });
      case Error<List<Friend>>():
        setState(() {
          _participants.clear();
          _participantIds = {};
          _participantsError = result.error.toString();
          _isLoadingParticipants = false;
        });
    }
  }

  

  

  Future<void> _showUpdateCreditDialog(Friend friend) async {
    if (friend.id == null || widget.expense.id == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (!mounted) return;
    final amount = await showDialog<double>(
      context: navigator.context,
      builder: (_) => UpdateCreditDialog(friendName: friend.name),
    );

    if (amount == null || !mounted) return;

    final vm = context.read<ExpensesViewModel>();
    final payload = {
      'expenseId': widget.expense.id!,
      'friendId': friend.id!,
      'amount': amount,
    };

    await vm.updateCredit.execute(payload);

    if (!mounted) return;

    final result = vm.updateCredit.result;
    if (result is Ok<void>) {
      await _loadParticipants();
      messenger.showSnackBar(
        SnackBar(content: Text('Updated ${friend.name} credit by ${amount.toStringAsFixed(2)}€')),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Error updating credit')),
      );
    }
  }

  Future<void> _showExpenseEditDialog() async {
    final messenger = ScaffoldMessenger.of(context);
    if (widget.expense.id == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se puede editar un gasto sin ID')),
      );
      return;
    }
    final result = await showExpenseEditDialog(
      context,
      description: _currentExpense.description,
      date: _currentExpense.date,
      amount: _currentExpense.amount,
    );

    if (result == null || !mounted) return;

    final description = result['description'] as String;
    final date = result['date'] as String;
    final amount = result['amount'] as double;

    // If nothing changed, do not call update
    final bool noChange = description == _currentExpense.description &&
        date == _currentExpense.date &&
        amount == _currentExpense.amount;
    if (noChange) {
      messenger.showSnackBar(const SnackBar(content: Text('No se han realizado cambios')));
      return;
    }

    final vm = context.read<ExpensesViewModel>();
    final updateData = {
      'description': description,
      'date': date,
      'amount': amount,
      'num_friends': _participantIds.length,
      'participants': _participantIds.toList(),
    };

    final payload = {
      'id': widget.expense.id!,
      'data': updateData,
    };

    await vm.updateExpense.execute(payload);

    if (!mounted) return;

    final updateResult = vm.updateExpense.result;
    if (updateResult is Ok<void>) {
      // Refresh the local expense from the repository so UI reflects changes
        try {
          final repo = context.read<ExpenseRepository>();
          final fetched = await repo.getExpense(widget.expense.id!);
          if (fetched is Ok<Expense>) {
            setState(() {
              _currentExpense = fetched.value;
            });
            await _loadParticipants(); //actualizar participantes tras editar gasto
          }
        } catch (_) {}

      messenger.showSnackBar(
        SnackBar(content: Text('Gasto ${widget.expense.id} actualizado')),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Error al actualizar el gasto')),
      );
    }
  }

  Future<void> _confirmDeleteExpense() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final vm = context.read<ExpensesViewModel>();

    if (widget.expense.id == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se puede eliminar un gasto sin ID')),
      );
      return;
    }


    if (!mounted) return;
    final should = await showDialog<bool>(
      context: navigator.context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Seguro que quieres eliminar el gasto "${widget.expense.description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (should != true) return;
    if (!mounted) return;

    await vm.deleteExpense.execute(widget.expense.id!);

    if (!mounted) return;

    final result = vm.deleteExpense.result;
    if (result is Ok<void>) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gasto ${widget.expense.id} eliminado')),
      );
      // Go back to previous screen
      try {
        navigator.pop();
      } catch (_) {}
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Error al eliminar el gasto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expense = _currentExpense;
    final idLabel = (expense.id ?? 0).toString().padLeft(2, '0');

    final numFriendsLabel =
    _participantIds.isNotEmpty ? _participantIds.length : expense.numFriends;

    return Scaffold(
      appBar: AppBar(
        title: Text('$idLabel - ${expense.description}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Editar gasto',
            onPressed: _showExpenseEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: 'Eliminar gasto',
            onPressed: _confirmDeleteExpense,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta superior con datos del gasto
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${expense.date}  '
                          '${expense.amount.toStringAsFixed(2)}€  •  '
                          '$numFriendsLabel friends',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Participants:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openEditParticipantsDialog(),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar participantes'),
                ),
              ],
            ),

            // (Nota informativa eliminada: la UI ya no muestra controles para gestionar participantes.)

            // Lista de participantes
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_isLoadingParticipants) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_participantsError != null) {
                    return Center(
                      child: Text(
                        'Cannot load participants: $_participantsError',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (_participants.isEmpty) {
                    return const Center(
                      child: Text('No friends assigned to this expense.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: _participants.length,
                    itemBuilder: (context, index) {
                      final f = _participants[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text('${f.id} - ${f.name}'),
                        subtitle: Text(
                          'Credit: ${f.creditBalance?.toStringAsFixed(2) ?? "0.00"}€   •   '
                              'Debit: ${f.debitBalance?.toStringAsFixed(2) ?? "0.00"}€',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.attach_money),
                          tooltip: 'Update credit',
                          onPressed: () => _showUpdateCreditDialog(f),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditParticipantsDialog() async {
    if (widget.expense.id == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final friendRepo = context.read<FriendRepository>();
    final vm = context.read<ExpensesViewModel>();

    // Load all friends
    final allResult = await friendRepo.fetchFriends();
    if (allResult is! Ok<List<Friend>>) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la lista de amigos')),
      );
      return;
    }

    final allFriends = allResult.value;

    // Prepare selection map
    final selected = <int>{..._participantIds};

    final navigator = Navigator.of(context);

    if (!mounted) return;
    // Safe: navigator was captured from context above and we check `mounted`.
    // The analyzer may still warn about passing a BuildContext into async gaps.
    // ignore: use_build_context_synchronously
    final updated = await showDialog<Set<int>>(
      context: navigator.context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Editar participantes'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allFriends.length,
                  itemBuilder: (context, idx) {
                  final friend = allFriends[idx];
                  final fid = friend.id;
                  if (fid == null) {
                    return const SizedBox.shrink();
                  }
                  final isParticipant = selected.contains(fid);

                  // Determine the credit for this friend *in this expense* (if participant)
                  final matched = _participants.where((p) => p.id == fid).toList();
                  final expenseCredit = matched.isNotEmpty ? (matched.first.creditBalance ?? 0.0) : 0.0;
                  final hasExpenseCredit = expenseCredit > 0.0;

                  return CheckboxListTile(
                    value: isParticipant,
                    onChanged: (val) {
                      // Prevent removing if friend has positive credit in THIS expense
                      if (hasExpenseCredit && isParticipant && val == false) {
                        // ignore
                        return;
                      }
                      setState(() {
                        if (val == true) {
                          selected.add(fid);
                        } else {
                          selected.remove(fid);
                        }
                      });
                    },
                    title: Text(friend.name),
                    subtitle: Text('Credit (en este gasto): ${expenseCredit.toStringAsFixed(2)}€'),
                    secondary: hasExpenseCredit && isParticipant
                        ? const Icon(Icons.lock, size: 18, color: Colors.grey)
                        : null,
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => navigator.pop(), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  navigator.pop(selected);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        });
      },
    );

    if (updated == null) return;
    if (!mounted) return;

    // If selection didn't change, don't call update
    if (updated.length == _participantIds.length && updated.containsAll(_participantIds)) {
      messenger.showSnackBar(const SnackBar(content: Text('No se han realizado cambios')));
      return;
    }

    // Check that we didn't try to remove someone with credit > 0
    final removed = _participantIds.difference(updated);
    final removedWithCredit = _participants.where((p) => removed.contains(p.id) && (p.creditBalance ?? 0.0) > 0.0).toList();
    if (removedWithCredit.isNotEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pueden eliminar participantes con crédito positivo')),
      );
      return;
    }

    // Build update payload using current expense fields
    final updateData = {
      'description': _currentExpense.description,
      'date': _currentExpense.date,
      'amount': _currentExpense.amount,
      'num_friends': updated.length,
      'participants': updated.toList(),
    };

    final payload = {'id': widget.expense.id!, 'data': updateData};

    try {
      await vm.updateExpense.execute(payload);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      return;
    }

    if (!mounted) return;
    final result = vm.updateExpense.result;
    if (result is Ok<void>) {
      await _loadParticipants();
      messenger.showSnackBar(const SnackBar(content: Text('Participantes actualizados')));
    } else {
      messenger.showSnackBar(const SnackBar(content: Text('Error al actualizar participantes')));
    }
  }
}