import 'services.dart';
import 'models.dart';
import 'utils/result.dart';

class FriendRepository {
  FriendRepository({required SplitWithMeService service}) : _service = service;
  late final SplitWithMeService _service;


  Future<Result<List<Friend>>> fetchFriends() async {
    try {
      final friends = await _service.fetchFriends();
      return Result.ok(friends);
    } on Exception catch (e){
      return Result.error(e);
    }
  }



}

class ExpenseRepository {
  ExpenseRepository({required SplitWithMeService service}) : _service = service;
  late final SplitWithMeService _service;

  Future<Result<List<Expense>>> listExpenses() async {
    try {
      final expenses = await _service.listExpenses();
      return Result.ok(expenses);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<Expense>> getExpense(int id) async {
    try {
      final expense = await _service.getExpense(id);
      return Result.ok(expense);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<List<Expense>>> listFriendExpenses(int friendId) async {
    try {
      final expenses = await _service.listFriendExpenses(friendId);
      return Result.ok(expenses);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<List<Friend>>> listExpenseFriends(int expenseId) async {
    try {
      final friends = await _service.listExpenseFriends(expenseId);
      return Result.ok(friends);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<Expense>> createExpense(Expense expense) async {
    try {
      final newExp = await _service.createExpense(expense);
      return Result.ok(newExp);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> updateExpense(int id, Map<String, dynamic> data) async {
    try {
      await _service.updateExpense(id, data);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> deleteExpense(int id) async {
    try {
      await _service.deleteExpense(id);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> updateFriendCredit(int expenseId, int friendId, double amount) async {
    try {
      await _service.updateFriendCredit(expenseId, friendId, amount);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
