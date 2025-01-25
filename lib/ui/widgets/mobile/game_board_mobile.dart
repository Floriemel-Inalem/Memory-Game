import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:memory_game/models/game.dart';
import 'package:memory_game/ui/widgets/game_confetti.dart';

import 'package:memory_game/ui/widgets/memory_card.dart';
import 'package:memory_game/ui/widgets/mobile/game_best_time_mobile.dart';
import 'package:memory_game/ui/widgets/mobile/game_timer_mobile.dart';
import 'package:memory_game/ui/widgets/restart_game.dart';

class GameBoardMobile extends StatefulWidget {
  const GameBoardMobile({
    required this.gameLevel,
    super.key,
  });

  final int gameLevel;

  @override
  State<GameBoardMobile> createState() => _GameBoardMobileState();
}

class _GameBoardMobileState extends State<GameBoardMobile> {
  late Timer timer;
  late Game game;
  late Duration duration;
  int bestTime = 0;
  bool showConfetti = false;
  late Box gameBox;

  @override
  void initState() {
    super.initState();
    game = Game(widget.gameLevel);
    duration = const Duration();
    startTimer();
    _openHiveBox();
  }

  // Open the Hive box to store and retrieve the best time
  Future<void> _openHiveBox() async {
    gameBox = await Hive.openBox('gameData');
    getBestTime();
  }

  // Get the best time from Hive
  void getBestTime() {
    final storedBestTime = gameBox.get('${widget.gameLevel}BestTime', defaultValue: 0);
    setState(() {
      bestTime = storedBestTime;
    });
  }

  // Start the timer
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      setState(() {
        final seconds = duration.inSeconds + 1;
        duration = Duration(seconds: seconds);
      });

      if (game.isGameOver) {
        timer.cancel();

        // Save the best time to Hive
        if (gameBox.get('${widget.gameLevel}BestTime', defaultValue: 0) > duration.inSeconds || bestTime == 0) {
          gameBox.put('${widget.gameLevel}BestTime', duration.inSeconds);

          setState(() {
            showConfetti = true;
            bestTime = duration.inSeconds;
          });
        }
      }
    });
  }

  // Pause the timer
  void pauseTimer() {
    timer.cancel();
  }

  // Reset the game and timer
  void _resetGame() {
    game.resetGame();
    setState(() {
      timer.cancel();
      duration = const Duration();
      startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = MediaQuery.of(context).size.aspectRatio;

    return SafeArea(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              RestartGame(
                isGameOver: game.isGameOver,
                pauseGame: () => pauseTimer(),
                restartGame: () => _resetGame(),
                continueGame: () => startTimer(),
                color: Colors.amberAccent[700]!,
              ),
              GameTimerMobile(
                time: duration,
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: game.gridSize,
                  childAspectRatio: aspectRatio * 2,
                  children: List.generate(game.cards.length, (index) {
                    return MemoryCard(
                      index: index,
                      card: game.cards[index],
                      onCardPressed: game.onCardPressed,
                    );
                  }),
                ),
              ),
              GameBestTimeMobile(
                bestTime: bestTime,
              ),
            ],
          ),
          showConfetti ? const GameConfetti() : const SizedBox(),
        ],
      ),
    );
  }
}
