import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // https://paletton.com/#uid=53i0u0kDJDJiVIJpYEuFjqdJVjp
      primaryColor: Color.fromRGBO(0, 167, 0, 1),
      backgroundColor: Colors.grey,
      textTheme: GoogleFonts.ptSansTextTheme()
          .copyWith(
            headline1: TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
            headline2: TextStyle(fontSize: 26, fontWeight: FontWeight.w300),
            headline3: TextStyle(fontSize: 21, fontWeight: FontWeight.w300),
            headline4: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
            headline5: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
            headline6: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            bodyText1: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
            bodyText2: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
          )
          .apply(
            bodyColor: Color.fromRGBO(90, 90, 90, 1),
            displayColor: Color.fromRGBO(90, 90, 90, 1),
          ),
      colorScheme: const ColorScheme.light(
        primary: Color.fromRGBO(0, 167, 0, 1),
        secondary: Color.fromRGBO(15, 69, 194, 1),
        background: Color.fromRGBO(0, 181, 181, 1),
        surface: Color.fromRGBO(0, 93, 93, 1),
      ).copyWith(secondary: Color.fromRGBO(15, 69, 194, 1)),
      // elevatedButtonTheme: ElevatedButtonThemeData(
      //     style: ElevatedButton.styleFrom(
      //   textStyle: TextStyle(
      //     letterSpacing: 1.05,
      //   ),
      // )),
    );
  }
}
