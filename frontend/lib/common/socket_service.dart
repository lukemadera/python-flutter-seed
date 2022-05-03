import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  SocketService._privateConstructor();
  static final SocketService _instance = SocketService._privateConstructor();
  factory SocketService() {
    return _instance;
  }

  var _channel;
  var _callbacksByRoute = {};
  var _auth = {
    'user_id': '',
    'session_id': '',
  };

  void connect(url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel.stream.listen((message) {
      handleMessage(message);
    });
  }

  void handleMessage(message) {
    String resString = utf8.decode(message);
    var res = jsonDecode(resString);
    //res['_auth'] = res['auth'];
    String resString1 = jsonEncode(res);
    if (res.containsKey('route') && _callbacksByRoute.containsKey(res['route'])) {
      for (var id in _callbacksByRoute[res['route']].keys) {
        _callbacksByRoute[res['route']][id]['callback'](resString1);
      }
      //_callbacksByRoute[res['route']].values.forEach((var cbObj) => {
      //  cbObj['callback'](resString1);
      //});
    }
  }

  void disconnect() {
    _channel.sink.close();
  }

  void emit(String route, var data) {
    String message = jsonEncode({
      'route': route,
      'auth': _auth,
      'data': data,
    });
    _channel.sink.add(utf8.encode(message));
  }

  String onRoute(String route, {Function(String)? callback}) {
    if (!_callbacksByRoute.containsKey(route)) {
      _callbacksByRoute[route] = {};
    }
    String id = new Random().nextInt(1000000).toString();
    _callbacksByRoute[route][id] = {
      'callback': callback,
    };
    return id;
  }

  void offRoute(String route, String id) {
    if (_callbacksByRoute.containsKey(route)) {
      _callbacksByRoute[route].remove(id);
    }
  }

  void offRouteIds(List<String> routeIds) {
    for (var ii = 0; ii < routeIds.length; ii++) {
    //routeIds.forEach((String routeId) =>
      String routeId = routeIds[ii];
      for (String route in _callbacksByRoute.keys) {
        bool found = false;
        for (String id in _callbacksByRoute[route].keys) {
          if (id == routeId) {
            _callbacksByRoute[route].remove(id);
            found = true;
            break;
          }
        }
        if (found) {
            break;
        }
      }
    }
  }

  void setAuth(String userId, String sessionId) {
    _auth['user_id'] = userId;
    _auth['session_id'] = sessionId;
  }
}