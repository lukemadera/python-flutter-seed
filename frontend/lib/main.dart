import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:seed_app/styles/custom_theme.dart';
//if (kIsWeb) {
//import 'dart:html' if (dart.library.html);
//}
import 'package:universal_html/html.dart';
import 'package:url_strategy/url_strategy.dart';

import './common/localstorage_service.dart';
import './common/socket_service.dart';
import './modules/user_auth/current_user_state.dart';
import './routes.dart';

main() async {
  await dotenv.load(fileName: '.env');

  if (kIsWeb) {
    // Check for redirect.
    bool redirectIt = false;
    String url = Uri.base.toString();
    // dot env is not loading properly if on www? So just assume if null to redirect.
    // Check www first so can also redirect http to https after if necessary.
    if ((dotenv.env['REDIRECT_WWW'] == '1' ||
            dotenv.env['REDIRECT_WWW'] == null) &&
        url.contains('www.')) {
      if (url.contains('https://') || url.contains('http://')) {
        url = url.replaceAll('www.', '');
      } else {
        url = url.replaceAll('www.', 'https://');
      }
      redirectIt = true;
    }
    if (dotenv.env['REDIRECT_HTTP'] == '1' && url.contains('http://')) {
      url = url.replaceAll('http://', 'https://');
      redirectIt = true;
    }
    if (redirectIt) {
      window.location.href = url;
    }
  }

  LocalstorageService _localstorageService = LocalstorageService();
  _localstorageService.init(dotenv.env['APP_NAME']);

  SocketService _socketService = SocketService();
  _socketService.connect(dotenv.env['SOCKET_URL_PUBLIC']);

  setPathUrlStrategy();
  runApp(MultiProvider(
    providers: [
      //ChangeNotifierProvider(create: (context) => AppState()),
      ChangeNotifierProvider(create: (context) => CurrentUserState()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  GoRouter _appRouter = AppGoRouter().router;

  @override
  Widget build(BuildContext context) {
    Provider.of<CurrentUserState>(context, listen: false).checkAndLogin();

    return MaterialApp.router(
      theme: CustomTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      title: 'seed_app',
      routerConfig: _appRouter,
    );
    ;
  }
}
