import 'package:flutter/material.dart';
import 'package:memory_game/ui/pages/startup_page.dart';

class MemoryGame extends StatelessWidget{
  const MemoryGame ({
     super.key,
  });



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const StartUpPage(),
      title: 'MEMORY GAME',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}