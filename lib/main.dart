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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    board = List.generate(81, (index) => '$index');
    staticIndexList = stages[currentStage].staticIndexList.sublist(0);

    bricksStartPosition = stages[currentStage].bricksStartPosition.sublist(0);

    foodPositionList = stages[currentStage].foodPositionList.sublist(0);

    playerIndex = stages[currentStage].playerStartIndex;
    buildBoard();
  }

  List<String> board = [];
  int currentStage = 0;

  List<int> staticIndexList = [];

  List<int> bricksStartPosition = [];

  List<int> foodPositionList = [];

  int playerIndex = 1;

  bool hasWon = false;
  bool endGame = false;

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
      if (positiveMove) {
        if (board[newplayerIndex + moveCount] == 'X' ||
            board[newplayerIndex + moveCount] == 'B') {
          return;
        }
      } else {
        if (board[newplayerIndex - moveCount] == 'X' ||
            board[newplayerIndex - moveCount] == 'B') {
          return;
        }
      }

      setState(() {
        board[playerIndex] = '$playerIndex';
        int newBrickPosition = positiveMove
            ? newplayerIndex + moveCount
            : newplayerIndex - moveCount;
        bricksStartPosition[bricksStartPosition.indexOf(newplayerIndex)] =
            newBrickPosition;
        playerIndex = newplayerIndex;
        board[playerIndex] = 'P';
      });
      checkIfWin();
    } else {
      setState(() {
        board[playerIndex] = '$playerIndex';
        playerIndex = newplayerIndex;
        board[playerIndex] = 'P';
      });
      checkIfWin();
    }
  }

  void checkIfWin() async {
    buildBoard();
    List<int> currentBrickPosition = [];
    board.asMap().forEach((index, element) {
      if (element == 'B') {
        currentBrickPosition.add(index);
      }
    });
    currentBrickPosition.sort();
    if (listEquals(currentBrickPosition, foodPositionList)) {
      setState(() {
        hasWon = true;
      });
      await Future.delayed(Duration(milliseconds: 800));
      if ((currentStage + 1) == stages.length) {
        setState(() {
          endGame = true;
        });
      } else {
        setState(() {
          currentStage += 1;
          board = List.generate(81, (index) => '$index');
          staticIndexList = stages[currentStage].staticIndexList.sublist(0);

          bricksStartPosition =
              stages[currentStage].bricksStartPosition.sublist(0);

          foodPositionList = stages[currentStage].foodPositionList.sublist(0);

          playerIndex = stages[currentStage].playerStartIndex;
          hasWon = false;
        });
        buildBoard();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[900],
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.replay_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              if (endGame) {
                currentStage = 0;
              }
              setState(() {
                endGame = false;
                hasWon = false;
                currentStage = currentStage;
                board = List.generate(81, (index) => '$index');
                staticIndexList =
                    stages[currentStage].staticIndexList.sublist(0);
                bricksStartPosition =
                    stages[currentStage].bricksStartPosition.sublist(0);
                foodPositionList =
                    stages[currentStage].foodPositionList.sublist(0);

                playerIndex = stages[currentStage].playerStartIndex;
              });
              setState(() {
                buildBoard();
              });
            },
          )
        ],
        backgroundColor: Colors.teal[900],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sokoban',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Level ${currentStage + 1}',
              style: TextStyle(
                  color: Colors.yellow[700], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: endGame
          ? Center(
              child: Text(
                'Game Complete!!!',
                style: Theme.of(context).textTheme.headline5.copyWith(
                      color: Colors.white,
                    ),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 800),
                        curve: Curves.bounceOut,
                        opacity: hasWon ? 0 : 1,
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
                            return Container();
                            // return Center(
                            //   child: Text(
                            //     e,
                            //     style: TextStyle(color: Colors.white),
                            //   ),
                            // );
                          }).toList(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Card(
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  child: IconButton(
                                    icon: Icon(Icons.keyboard_arrow_up),
                                    onPressed: () {
                                      makeMove(9, positiveMove: false);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Card(
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  child: IconButton(
                                    icon: Icon(Icons.keyboard_arrow_left),
                                    onPressed: () {
                                      makeMove(1, positiveMove: false);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Card(
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  child: IconButton(
                                    icon: Icon(Icons.keyboard_arrow_right),
                                    onPressed: () {
                                      makeMove(1);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Card(
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  child: IconButton(
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    onPressed: () {
                                      makeMove(9);
                                    },
                                  ),
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
