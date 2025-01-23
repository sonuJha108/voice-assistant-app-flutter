
import 'package:flutter/material.dart';
import 'package:voice_assistant_app/colorFile/pallete.dart';
import 'package:voice_assistant_app/pages/views/homePage.dart';

void main(){
  runApp(const MyApp());
}

// state less widget to create the My app 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "voice assistant app",
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Pallete.whiteColor,
       appBarTheme: const AppBarTheme(
         backgroundColor: Pallete.whiteColor
       ),
      ),
      debugShowCheckedModeBanner: false,
      home: const Homepage(),
    );
  }
}
