import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

abstract class SplitWithMeService {
  Future<List<Friend>> fetchFriends();
  // Friend creation/deletion is managed externally and not provided here.

  // Expenses
  Future<List<Expense>> listExpenses();
  Future<Expense> getExpense(int id);
  Future<Expense> createExpense(Expense expense);
  Future<void> updateExpense(int id, Map<String, dynamic> data);
  Future<void> deleteExpense(int id);
  Future<List<Expense>> listFriendExpenses(int friendId);
  Future<List<Friend>> listExpenseFriends(int expenseId);
  Future<void> updateFriendCredit(int expenseId, int friendId, double amount);
}

class SplitWithMeAPIService implements SplitWithMeService {
  // Default to emulator-host for Android and localhost otherwise
  final String serverHost;
  final String serverPort;

  SplitWithMeAPIService({String? serverHost, String? serverPort})
      : serverHost = serverHost ?? (Platform.isAndroid ? '10.0.2.2' : '127.0.0.1'),
        serverPort = serverPort ?? '8000';

  Uri _http(String path) => Uri.http('$serverHost:$serverPort', path);

  // Friends
  @override
  Future<List<Friend>> fetchFriends() async {
    final uri = _http('friends');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Friend>.from(data.map((item) => Friend.fromJson(item)));
      }
      throw ServerException('Invalid data');
    } on http.ClientException {
      throw ServerException('Service is not available. Try again later.');
    }
  }

  // Note: creation/deletion of friends is intentionally not implemented
  // because participant/friend DB changes are handled by another team.

  // Expenses
  @override
  Future<List<Expense>> listExpenses() async {
    final uri = _http('expenses');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Expense>.from(data.map((item) => Expense.fromJson(item)));
      }
      throw ServerException('Invalid data');
    } on http.ClientException {
      throw ServerException('Service is not available. Try again later.');
    }
  }

  @override
  Future<Expense> getExpense(int id) async {
    final uri = _http('expenses/$id');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Expense.fromJson(data);
      }
      throw ServerException('Invalid data');
    } on http.ClientException {
      throw ServerException('Service is not available. Try again later.');
    }
  }

  @override
  Future<Expense> createExpense(Expense expense) async {
    final uri = _http('expenses/');
    try {
      final response = await http.post(uri,
          headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
          body: json.encode(expense.toJson()));
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Expense.fromJson(data);
      }
      throw ServerException('Invalid data');
    } on http.ClientException {
      throw ServerException('Service is not available. Try again later.');
    }
  }

  @override
  Future<void> updateExpense(int id, Map<String, dynamic> data) async {
    final uri = _http('expenses/$id');
    try {
      final response = await http.put(uri,
          headers: {'Content-Type': 'application/json', 'accept': 'application/json'}, body: json.encode(data));
      // The API returns 204 No Content on successful update
      if (response.statusCode == 204) return;
      throw ServerException('Invalid data');
    } on http.ClientException {
      throw ServerException('Service is not available. Try again later.');
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    final uri = _http('expenses/$id');
    try {
      final response = await http.delete(uri);
      if (response.statusCode == 204) return;
      throw ServerException('Invalid data');
    } on http.ClientException {
      throw ServerException('Service is not available. Try again later.');
    }
  }

  @override
  Future<List<Expense>> listFriendExpenses(int friendId) async {
    final uri = _http('friends/$friendId/expenses');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Expense>.from(data.map((item) => Expense.fromJson(item)));
      }
      throw ServerException('Invalid data');
    } on http.ClientException {
      throw ServerException('Service is not available. Try again later.');
    }
  }

  @override
  Future<List<Friend>> listExpenseFriends(int expenseId) async {
    final uri = _http('expenses/$expenseId/friends');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Friend>.from(data.map((item) => Friend.fromJson(item)));
      }
      throw ServerException('Invalid data');
    } on http.ClientException {
      throw ServerException('Service is not available. Try again later.');
    }
  }

  @override
  Future<void> updateFriendCredit(int expenseId, int friendId, double amount) async {
    final uri = _http('expenses/$expenseId/friends/$friendId').replace(queryParameters: {'amount': amount.toString()});
    try {
      final response = await http.put(uri);
      if (response.statusCode == 204) return;
      throw ServerException('Invalid data');
    } on http.ClientException {
      throw ServerException('Service is not available. Try again later.');
    }
  }
}

class ServerException implements Exception {
  final String errorMessage;
  ServerException(this.errorMessage);
}
