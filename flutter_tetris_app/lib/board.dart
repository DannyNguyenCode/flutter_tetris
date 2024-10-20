import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tetris_app/piece.dart';
import 'package:flutter_tetris_app/pixel.dart';
import 'package:flutter_tetris_app/values.dart';
import 'dart:async';

List<List<Tetromino?>> gameBoard= List.generate(
    colLength,
        (i)=>List.generate(
              rowLength,
              (j)=> null,
        )
);

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {

  @override
  void initState(){
    super.initState();
    startGame();
  }
  Piece currentPiece = Piece(type: Tetromino.T);
  int currentScore =  0;
  bool gameOver = false;

  void startGame(){

    createNewPiece();
    // frame refresh rate
    Duration frameRate = const Duration(milliseconds: 300);
    gameLoop(frameRate);
  }
  void gameLoop(Duration frameRate){
    Timer.periodic(
      frameRate,
      (timer){
        setState(() {
          clearLines();
          checkLanding();
          if(gameOver == true){
            timer.cancel();
            showGameOverDialog();
          }
          currentPiece.movePiece(Directions.down);
        });
      });
  }

  void showGameOverDialog(){
    showDialog(context: context, builder: (context)=>AlertDialog(
      title:  const Text('Game Over'),
      content: Text('Your score is: $currentScore'),
      actions: [
        TextButton(
            onPressed: (){
              resetGame();
              Navigator.pop(context);
            },
            child: const Text('Play Again')
        )
      ],
    ));
  }

  void resetGame(){
    gameBoard= List.generate(
        colLength,
            (i)=>List.generate(
          rowLength,
              (j)=> null,
        )
    );
    gameOver = false;
    currentScore = 0;
    createNewPiece();
    startGame();
  }

  bool checkCollision(Directions direction){

    for(int i =0; i < currentPiece.position.length; i++){

      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      if(direction == Directions.left){
        col -= 1;
      }else if(direction == Directions.right){
        col += 1;
      }else if(direction == Directions.down){
        row += 1;
      }
      if(row >= colLength || col < 0 || col>=rowLength){
        return true;
      }
      if (row < colLength && row >= 0 && gameBoard[row][col] != null) {
        return true; // collision with a landed piece
      }

    }
    return false;
  }
  void checkLanding(){
    if(checkCollision(Directions.down)){

      for(int i = 0; i < currentPiece.position.length; i++){
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;
        if(row >= 0 && col >=0){
          gameBoard[row][col] = currentPiece.type;
        }
      }
      createNewPiece();
    }
  }

  void createNewPiece(){
      Random rand = Random();
      Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
      currentPiece = Piece(type: randomType);
      currentPiece.initializePiece();
      if(isGameOver()){
        gameOver = true;
      }
  }

  void moveLeft(){
    if(!checkCollision(Directions.left)){
      setState(() {
        currentPiece.movePiece(Directions.left);
      });
    }
  }
  void moveRight(){
    if(!checkCollision(Directions.right)){
      setState(() {
        currentPiece.movePiece(Directions.right);
      });
    }
  }
  void rotatePiece(){
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  void clearLines(){
    for(int row = colLength - 1; row >=0;row--){
      bool rowIsFull = true;
      for(int col = 0; col < rowLength; col++){
        if(gameBoard[row][col] == null){
          rowIsFull = false;
          break;
        }
      }
      if(rowIsFull){
        for(int r = row; r > 0; r--){
          gameBoard[r] = List.from(gameBoard[r-1]);
        }
        gameBoard[0] = List.generate(row, (index)=>null);
        currentScore++;
      }
    }
  }
  bool isGameOver(){
    for(int col =0; col < rowLength; col++){
      if(gameBoard[0][col] != null){
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GridView.builder(
              itemCount: rowLength * colLength,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: rowLength),
                itemBuilder: (context,index){
                  int row = (index / rowLength).floor();
                  int col = index % rowLength;
                  if(currentPiece.position.contains(index)){
                    return Pixel(
                        color: currentPiece.color,
                    );
                  }else if(gameBoard[row][col] != null){
                    final Tetromino? tetrominoType = gameBoard[row][col];
                      return Pixel(
                          color: tetrominoColors[tetrominoType] as Color,
                      );
                  }else{
                    return Pixel(
                        color: Colors.grey[900] as Color,
                    );
                  }
                },
            ),
          ),
          Text(
              'Score: ${currentScore.toString()}',
              style: const TextStyle(
                color: Colors.white
              ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom:50.0, top: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                    onPressed: moveLeft,
                    icon: const Icon(Icons.arrow_left)
                ),
                IconButton(
                    onPressed:(){
                      rotatePiece();
                    },
                    icon: const Icon(Icons.rotate_right)
                ),
                IconButton(
                    onPressed: moveRight,
                    icon: const Icon(Icons.arrow_right)
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}
