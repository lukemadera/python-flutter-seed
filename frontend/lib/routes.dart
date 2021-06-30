import 'dart:async';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import './modules/home.dart';
import './modules/user_auth/user_email_verify.dart';
import './modules/user_auth/user_login.dart';
import './modules/user_auth/user_logout.dart';
import './modules/user_auth/user_password_reset.dart';
import './modules/user_auth/user_signup.dart';

class AppRouter {
  static FluroRouter router = FluroRouter.appRouter;

  final List<AppRoute> _routes;
  final Handler _notFoundHandler;

  List<AppRoute> get routes => _routes;

  const AppRouter({ @required List<AppRoute> routes, @required Handler notFoundHandler, }) :
    _routes = routes,
    _notFoundHandler = notFoundHandler;

  void setupRoutes() {
    router.notFoundHandler = _notFoundHandler;
    routes.forEach(
      (AppRoute route) => router.define(route.route, handler: route.handler, transitionType: TransitionType.fadeIn),
    );
  }
}

class AppRoutes {
  static final routeNotFoundHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return RouteNotFoundPage();
    }
  );

  static final rootRoute = AppRoute('/', Handler(
    handlerFunc: (context, parameters) => HomeComponent(),
  ));
  static final homeRoute = AppRoute('/home', Handler(
    handlerFunc: (context, parameters) => HomeComponent(),
  ));
  static final loginRoute = AppRoute('/login', Handler(
    handlerFunc: (context, parameters) => UserLoginComponent(),
  ));
  static final logoutRoute = AppRoute('/logout', Handler(
    handlerFunc: (context, parameters) => UserLogoutComponent(),
  ));
  static final signupRoute = AppRoute('/signup', Handler(
    handlerFunc: (context, parameters) => UserSignupComponent(),
  ));
  static final emailVerifyRoute = AppRoute('/email-verify', Handler(
    handlerFunc: (context, parameters) => UserEmailVerifyComponent(),
  ));
  static final passwordResetRoute = AppRoute('/password-reset', Handler(
    handlerFunc: (context, parameters) => UserPasswordResetComponent(),
  ));

  // Primitive function to get one param detail route (i.e. id).
  //static String getDetailRoute(String parentRoute, String id) {
  //  return "$parentRoute/$id";
  //}

  static final List<AppRoute> routes = [
    rootRoute,
    homeRoute,
    loginRoute,
    logoutRoute,
    signupRoute,
    emailVerifyRoute,
    passwordResetRoute,
  ];
}

class RouteNotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Route not found"),
            TextButton(
              onPressed: () => AppRouter.router.navigateTo(
                context,
                AppRoutes.rootRoute.route,
                replace: true,
                clearStack: true,
                transition: TransitionType.none,
              ),
              child: const Text("Go Home"),
            )
          ],
        ),
      ),
    );
  }
}

class ReRoutePage extends StatefulWidget {
  @override
  _ReRouteState createState() => _ReRouteState();
}

class _ReRouteState extends State<ReRoutePage> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(milliseconds: 100), () {
      Navigator.pushNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Loading.."),
          ],
        ),
      ),
    );
  }
}
