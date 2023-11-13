import 'package:flutter/material.dart';

ThemeData getAppTheme(BuildContext context, bool isDarkTheme) {
  return ThemeData(
    dialogBackgroundColor: isDarkTheme ? Colors.black : Colors.white,
    dialogTheme: DialogTheme(
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(color: Colors.white),
      contentTextStyle: TextStyle(color: Colors.white),
        iconColor: Colors.white,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.black;
        } else {
          return Colors.grey;
        }
      }),
    ),
    cardColor: isDarkTheme ? Colors.grey : Colors.white,
    scaffoldBackgroundColor: isDarkTheme ? Colors.black : Colors.white,
    textTheme: Theme.of(context)
        .textTheme
        .copyWith(
          titleSmall: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 11),
        )
        .apply(
          bodyColor: isDarkTheme ? Colors.white : Colors.black,
          displayColor: Colors.grey,
        ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(
        isDarkTheme ? Colors.orange : Colors.purple,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: isDarkTheme ? Colors.orange : Colors.purple,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
      iconTheme: IconThemeData(color: isDarkTheme ? Colors.white : Colors.black54),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
    ),

  );
}
