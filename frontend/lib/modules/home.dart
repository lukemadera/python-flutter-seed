import 'package:flutter/material.dart';

import '../app_scaffold.dart';

class HomeComponent extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AppScaffoldComponent(
      body: ListView(
        children: [
          Text('Home'),
        ]
      )
    );
  }
}
