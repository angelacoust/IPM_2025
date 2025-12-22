import 'package:flutter/material.dart';

import 'models.dart';
import 'repositories.dart';
import 'utils/result.dart';
import 'utils/command.dart';

class ExpensesViewModel extends ChangeNotifier {
  ExpensesViewModel({required ExpenseRepository expenseRepository}) : _expenseRepository = expenseRepository {
    load = Command0(_load);
    addExpense = Command1(_addExpense);
    updateExpense = Command1(_updateExpense);
    deleteExpense = Command1(_deleteExpense);
    updateCredit = Command1(_updateCredit);
    if (expenses.isEmpty) {
      load.execute();
    }
  }

  final ExpenseRepository _expenseRepository;
  late final Command0 load;
  late final Command1<void, Expense> addExpense;
  late final Command1<void, Map<String, dynamic>> updateExpense;
  late final Command1<void, int> deleteExpense;
  late final Command1<void, Map<String, dynamic>> updateCredit;

  List<Expense> expenses = [];
  String? errorMessage;

  Future<Result<void>> _load() async {
    final result = await _expenseRepository.listExpenses();
    switch (result) {
      case Ok<List<Expense>>():
        expenses = result.value;
        notifyListeners();
        return Result.ok(null);
      case Error<List<Expense>>():
        errorMessage = "Cannot retrieve the list of expenses";
        notifyListeners();
        return Result.error(result.error);
    }
  }

  Future<Result<void>> _addExpense(Expense expense) async {
    final result = await _expenseRepository.createExpense(expense);
    switch (result) {
      case Ok<Expense>():
        expenses.add(result.value);
      case Error<Expense>():
        errorMessage = "Cannot add expense";
    }
    notifyListeners();
    return result;
  }

  Future<Result<void>> _updateExpense(Map<String, dynamic> payload) async {
    final id = payload['id'] as int;
    final data = payload['data'] as Map<String, dynamic>;
    final result = await _expenseRepository.updateExpense(id, data);
    switch (result) {
      case Ok<void>():
        // refresh list
        await _load();
      case Error<void>():
        errorMessage = "Cannot update expense";
    }
    notifyListeners();
    return result;
  }

  Future<Result<void>> _deleteExpense(int id) async {
    final result = await _expenseRepository.deleteExpense(id);
    switch (result) {
      case Ok<void>():
        expenses.removeWhere((e) => e.id == id);
      case Error<void>():
        errorMessage = "Cannot remove expense";
    }
    notifyListeners();
    return result;
  }

  Future<Result<void>> _updateCredit(Map<String, dynamic> payload) async {
    final expenseId = payload['expenseId'] as int;
    final friendId = payload['friendId'] as int;
    final amount = payload['amount'] as double;
    final result = await _expenseRepository.updateFriendCredit(expenseId, friendId, amount);
    switch (result) {
      case Ok<void>():
        // refresh list to reflect updated balances
        await _load();
      case Error<void>():
        errorMessage = "Cannot update credit";
    }
    notifyListeners();
    return result;
  }
}
