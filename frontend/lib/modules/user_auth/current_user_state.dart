import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import '../../common/localstorage_service.dart';
import '../../common/socket_service.dart';
import './user_class.dart';

class CurrentUserState extends ChangeNotifier {
  SocketService _socketService = SocketService();
  LocalstorageService _localstorageService = LocalstorageService();

  var _currentUser = null;
  bool _isLoggedIn = false;
  LocalStorage _localstorage = null;
  List<String> _routeIds = [];

  get isLoggedIn => _isLoggedIn;

  get currentUser => _currentUser;

  void init() {
    if (_routeIds.length == 0) {
      _routeIds.add(_socketService.onRoute('getUserSession', callback: (String resString) {
        var res = json.decode(resString);
        var data = res['data'];
        if (data['valid'] == 1 && data.containsKey('user')) {
          var user = UserClass.fromJson(data['user']);
          if (user.id.length > 0) {
            setCurrentUser(user);
          }
        }
      }));
    }
  }

  void getLocalstorage() {
    if (_localstorage == null) {
      init();
      _localstorage = _localstorageService.localstorage;
    }
  }

  void setCurrentUser(var user) {
    _currentUser = user;
    _isLoggedIn = true;
    _socketService.setAuth(user.id, user.session_id);

    getLocalstorage();
    _localstorage.setItem('currentUser', _currentUser.toJson());

    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _isLoggedIn = false;
    _socketService.setAuth('', '');

    getLocalstorage();
    _localstorage.deleteItem('currentUser');

    notifyListeners();
  }

  void checkAndLogin() {
    getLocalstorage();
    var user = _localstorage.getItem('currentUser');
    if (user != null) {
      _socketService.emit('getUserSession', { 'user_id': user['id'], 'session_id': user['session_id'] });
    }
  }

  void logout() {
    if (_currentUser != null) {
      _socketService.emit('logout', { 'user_id': _currentUser.id, 'session_id': _currentUser.session_id });
    }
  }

  bool hasRole(String role) {
    if (_currentUser != null) {
      List<String> roles = _currentUser.roles.split(",");
      if (roles.contains(role)) {
        return true;
      }
    }
    return false;
  }
}