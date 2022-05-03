import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
//if (kIsWeb) {
//import 'dart:html' if (dart.library.html);
//}
import 'package:universal_html/html.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

import './common/socket_service.dart';
import './common/localstorage_service.dart';

import './routes.dart';

import './modules/user_auth/current_user_state.dart';

main() async {
  await dotenv.load(fileName: '.env');

  if (kIsWeb) {
    // Check for redirect.
    bool redirectIt = false;
    String url = Uri.base.toString();
    // dot env is not loading properly if on www? So just assume if null to redirect.
    // Check www first so can also redirect http to https after if necessary.
    if ((dotenv.env['REDIRECT_WWW'] == '1' || dotenv.env['REDIRECT_WWW'] == null) && url.contains('www.')) {
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
  runApp(
    MultiProvider(
      providers: [
        //ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => CurrentUserState()),
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    
    AppRouter appRouter = AppRouter(
      routes: AppRoutes.routes,
      notFoundHandler: AppRoutes.routeNotFoundHandler,
    );

    appRouter.setupRoutes();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<CurrentUserState>(context, listen: false).checkAndLogin();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'seed_app',
      onGenerateRoute: AppRouter.router.generator,
      theme: ThemeData(
        // https://paletton.com/#uid=53i0u0kDJDJiVIJpYEuFjqdJVjp
        primaryColor: Color.fromRGBO(0, 167, 0, 1),
        //primaryColor: Color.fromRGBO(0, 218, 0, 1),
        accentColor: Color.fromRGBO(15, 69, 194, 1),
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: Color.fromRGBO(0, 167, 0, 1),
          secondary: Color.fromRGBO(15, 69, 194, 1),
          primaryVariant: Color.fromRGBO(0, 124, 0, 1),
          secondaryVariant: Color.fromRGBO(6, 36, 104, 1),
          background: Color.fromRGBO(0, 181, 181, 1),
          surface: Color.fromRGBO(0, 93, 93, 1),
        ),
        backgroundColor: Colors.grey,
        textTheme: GoogleFonts.ptSansTextTheme(Theme.of(context).textTheme).copyWith(
          headline1: TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
          headline2: TextStyle(fontSize: 26, fontWeight: FontWeight.w300),
          headline3: TextStyle(fontSize: 21, fontWeight: FontWeight.w300),
          headline4: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
          headline5: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
          headline6: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
          bodyText1: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
          bodyText2: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
        ).apply(
          bodyColor: Color.fromRGBO(90, 90, 90, 1),
          displayColor: Color.fromRGBO(90, 90, 90, 1),
        ),
        //elevatedButtonTheme: ElevatedButtonThemeData(
        //  style: ElevatedButton.styleFrom(
        //    textStyle: TextStyle(
        //      letterSpacing: 1.05,
        //    ),
        //  )
        //),
      ),
    );
  }
}
