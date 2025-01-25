import 'package:flutter/material.dart';
import 'package:memory_game/memory_game.dart';
import 'package:hive_flutter/hive_flutter.dart';


void main() async {
  await Hive.initFlutter();
  runApp(const MemoryGame());
}