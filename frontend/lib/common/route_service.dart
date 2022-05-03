import 'package:flutter/material.dart';

class RouteService {
  RouteService._privateConstructor();
  static final RouteService _instance = RouteService._privateConstructor();
  factory RouteService() {
    return _instance;
  }

  void goHome(var context) {
    Navigator.pushNamed(context, '/home');
  }
}