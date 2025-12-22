class Friend {

  Friend({this.id, required this.name, this.creditBalance, this.debitBalance});
  final int? id;
  final String name;
  final double? creditBalance;
  final double? debitBalance;
  bool starred = false;

  
  Friend.fromJson(Map json) 
  : id = json["id"],
  name = json["name"],
  creditBalance = (json["credit_balance"] is num) ? (json["credit_balance"] as num).toDouble() : null,
  debitBalance = (json["debit_balance"] is num) ? (json["debit_balance"] as num).toDouble() : null;

  @override
  String toString() {
    return "$id | $name | $creditBalance | $debitBalance | $starred";
  }

}
/*
class ServerException implements Exception {
  String errorMessage;
  ServerException(this.errorMessage);
}*/

class Expense {
  Expense({this.id, required this.description, required this.date, required this.amount, this.numFriends = 1, this.participants});

  final int? id;
  final String description;
  final String date;
  final double amount;
  final int numFriends;
  final List<int>? participants;

  Expense.fromJson(Map json)
    : id = json['id'],
      description = json['description'] ?? '',
      date = json['date'] ?? '',
      amount = (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      numFriends = json['num_friends'] ?? 1,
      participants = (json['participants'] is List) ? List<int>.from(json['participants'].map((e) => e as int)) : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'date': date,
    'amount': amount,
    'num_friends': numFriends,
    'participants': participants,
  };

  @override
  String toString() => '$id | $description | $date | $amount';
}