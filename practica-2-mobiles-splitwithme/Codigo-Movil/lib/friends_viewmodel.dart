import 'package:flutter/material.dart';
import 'package:splitwithfriends/models.dart';

import 'repositories.dart';
import 'utils/result.dart';
import 'utils/command.dart';

class FriendViewModel extends ChangeNotifier {
  FriendViewModel({required FriendRepository friendRepository})
    : _friendRepository = friendRepository {
    load = Command0(_load);
    if (friends.isEmpty) {
      load.execute();
    }
  }

  final FriendRepository _friendRepository;
  late final Command0 load;
  // add/remove friend operations removed per enunciado (external management)

  List<Friend> friends = [];
  String? errorMessage;

  Future<Result<void>> _load() async {
    final result = await _friendRepository.fetchFriends();
    switch (result) {
      case Ok<List<Friend>>():
        friends = result.value;
        notifyListeners();
        return Result.ok(null);
      case Error<List<Friend>>():
        errorMessage = "Cannot retrieve the list of friends";
        notifyListeners();
        return Result.error(result.error);
    }
  }
  
}
