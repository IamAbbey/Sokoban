import 'package:Sokoban/stages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GameScreen(),
    );
  }
}

List<String> board = List.generate(81, (index) => '$index');
int currentStage = 3;
// List<int> staticIndexList = [
//   2,
//   3,
//   4,
//   11,
//   13,
//   20,
//   22,
//   23,
//   24,
//   25,
//   27,
//   28,
//   29,
//   34,
//   36,
//   41,
//   42,
//   43,
//   45,
//   46,
//   47,
//   48,
//   50,
//   57,
//   59,
//   66,
//   67,
//   68
// ];

// List<int> bricksPosition = [30, 39, 49, 32];

// List<int> foodIndexList = [12, 33, 37, 58];

// int playerIndex = 40;

class GameScreen extends StatefulWidget {
  const GameScreen({Key key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    buildBoard();
  }

  List<int> staticIndexList = stages[currentStage].staticIndexList;

  List<int> bricksStartPosition = stages[currentStage].bricksStartPosition;

  List<int> foodPositionList = stages[currentStage].foodPositionList;

  int playerIndex = stages[currentStage].playerStartIndex;
  String oldPositionContent = '${stages[currentStage].playerStartIndex}';

  void buildBoard() {
    staticIndexList.sort();
    foodPositionList.sort();
    bricksStartPosition.sort();
    for (var i = 0; i < board.length; i++) {
      if (staticIndexList.contains(i)) {
        board[i] = 'X';
      }
      if (foodPositionList.contains(i)) {
        board[i] = 'F';
      }
      if (bricksStartPosition.contains(i)) {
        board[i] = 'B';
      }
      if (i == playerIndex) {
        board[i] = 'P';
      }
    }
  }

  makeMove(int moveCount, {bool positiveMove = true}) {
    int newplayerIndex;
    if (positiveMove) {
      newplayerIndex = playerIndex + moveCount;
    } else {
      newplayerIndex = playerIndex - moveCount;
    }
    if (board[newplayerIndex] == 'X') {
      return;
    } else if (board[newplayerIndex] == 'B') {
      print('in B');
      if (positiveMove) {
        if (board[newplayerIndex + moveCount] == 'X') {
          return;
        }
      } else {
        if (board[newplayerIndex - moveCount] == 'X') {
          return;
        }
      }
      print(positiveMove
          ? board[newplayerIndex + moveCount]
          : board[newplayerIndex - moveCount]);
      if (positiveMove
          ? board[newplayerIndex + moveCount] == 'F'
          : board[newplayerIndex - moveCount] == 'F') {
        oldPositionContent = board[newplayerIndex];
        print('oldP $oldPositionContent');
      } else {
        oldPositionContent = '$playerIndex';
      }
      setState(() {
        board[playerIndex] =
            oldPositionContent == 'F' ? '$oldPositionContent' : '$playerIndex';
        board[positiveMove
            ? newplayerIndex + moveCount
            : newplayerIndex - moveCount] = 'B';
        print(positiveMove
            ? newplayerIndex + moveCount
            : newplayerIndex - moveCount);
        // board[playerIndex] = oldPositionContent == 'F' ? 'F' : '$playerIndex';
        print(board[playerIndex]);
        playerIndex = newplayerIndex;
        board[playerIndex] = 'P';
        print(board[playerIndex]);
      });
      checkIfWin();
    } else if (board[newplayerIndex] == 'F') {
      print('in F');
      print(positiveMove
          ? board[newplayerIndex + moveCount]
          : board[newplayerIndex - moveCount]);
      if (positiveMove
          ? board[newplayerIndex + moveCount] == 'F'
          : board[newplayerIndex - moveCount] == 'F') {
        oldPositionContent = board[newplayerIndex];
        print('oldP $oldPositionContent');
      }
      setState(() {
        board[playerIndex] =
            oldPositionContent == 'F' ? '$oldPositionContent' : '$playerIndex';
        playerIndex = newplayerIndex;
        board[playerIndex] = 'P';
      });
      checkIfWin();
    } else {
      print('in else');
      // print(positiveMove
      //     ? board[newplayerIndex + moveCount]
      //     : board[newplayerIndex - moveCount]);
      // if (positiveMove
      //     ? board[newplayerIndex + moveCount] == 'F'
      //     : board[newplayerIndex - moveCount] == 'F') {
      //   oldPositionContent = board[newplayerIndex];
      //   print('oldP $oldPositionContent');
      // }
      setState(() {
        if (board.where((element) => element == 'F').length ==
            foodPositionList.length) {
          board[playerIndex] = '$playerIndex';
        } else {
          board[playerIndex] = oldPositionContent == 'F'
              ? '$oldPositionContent'
              : '$playerIndex';
        }
        // oldPositionContent = '$playerIndex';
        playerIndex = newplayerIndex;
        board[playerIndex] = 'P';
      });
      checkIfWin();
    }
  }

  void checkIfWin() {
    List<int> currentBrickPosition = [];
    board.asMap().forEach((index, element) {
      if (element == 'B') {
        currentBrickPosition.add(index);
      }
    });
    currentBrickPosition.sort();
    if (listEquals(currentBrickPosition, foodPositionList)) {
      // setState(() {
      //   currentStage += 1;
      // });
      print('won');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Sokoban'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: GridView.count(
                  crossAxisCount: 9,
                  children: board.map((e) {
                    if (e == 'X') {
                      return Card(color: Colors.grey[300]);
                    } else if (e == 'F') {
                      return Icon(
                        Icons.icecream,
                        color: Colors.yellow[700],
                      );
                    } else if (e == 'B') {
                      return Card(color: Colors.red[700]);
                    } else if (e == 'P') {
                      return Icon(
                        Icons.bug_report,
                        color: Colors.blue,
                      );
                    }
                    return Center(
                      child: Text(
                        e,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Card(
                          child: IconButton(
                            icon: Icon(Icons.keyboard_arrow_up),
                            onPressed: () {
                              makeMove(9, positiveMove: false);
                            },
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Card(
                          child: IconButton(
                            icon: Icon(Icons.keyboard_arrow_left),
                            onPressed: () {
                              makeMove(1, positiveMove: false);
                            },
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Card(
                          child: IconButton(
                            icon: Icon(Icons.keyboard_arrow_right),
                            onPressed: () {
                              makeMove(1);
                            },
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Card(
                          child: IconButton(
                            icon: Icon(Icons.keyboard_arrow_down),
                            onPressed: () {
                              makeMove(9);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
