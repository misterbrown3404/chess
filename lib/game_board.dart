import 'package:chess/components/dead_piece.dart';
import 'package:chess/components/helper/helper_methods.dart';
import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {

  // A 2-dimensional last representing the chessboard,
  // with each position possibly containing a chess piece
  late List<List<ChessPiece?>> board;

  // the currently selected piece on the chess board
  // with each position possibly containing a chess piece

  ChessPiece? selectedPiece;

  // the row index of the selected piece
  // default value -1 indicated no piece is currently selected
  int selectedRow = -1;


  // the col index of the selected piece
  // default value -1 indicated no piece is currently selected
  int selectedCol = -1;


  // A list of valid moves for the currently selected piece
  // each move is represented as  a list with 2 element : row and col
  List<List<int >> validMoves = [];

  // A list of white piece that been taken by black player
  List<ChessPiece> whitePieceTaken = [];


  // A list of black piece that been taken by white player
 List<ChessPiece> blackPieceTaken = [];

 // A boolean to indicate whose turn it is
  bool isWhiteTurn = true;

  //initial position of king (keep track of this to make it easier later to see if king is in check)
  List<int> whiteKingPosition = [7,4];
  List<int> blackKingPosition = [0,4];

  bool checkStatus = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _intitializeBoard();
  }


  // Initialize Board
  void _intitializeBoard(){
    // initialize the board with nulls, meaning no pieces in those positions
    List<List<ChessPiece?>> newBoard = List.generate(8,(index) => List.generate(8,(index) => null));



    //place pawns
     for (int i = 0; i < 8; i++){
       newBoard[1][i] = ChessPiece(type:
       ChessPieceType.pawn, isWhite:false, imagePath: "lib/image/black/pawn.png"
       );
       newBoard[6][i] = ChessPiece(type:
       ChessPieceType.pawn, isWhite:true, imagePath: "lib/image/white/pawn.png"
        );
     }

    //place rooks


    newBoard[0][0] = ChessPiece(type:
    ChessPieceType.rook,
        isWhite:false,
        imagePath: "lib/image/black/rook.png"
    );
    newBoard[0][7] = ChessPiece(type:
    ChessPieceType.rook,
        isWhite:false,
        imagePath: "lib/image/black/rook.png"
    );
    newBoard[7][0] = ChessPiece(type:
    ChessPieceType.rook,
        isWhite:true,
        imagePath: "lib/image/white/rook.png"
    );
    newBoard[7][7] = ChessPiece(type:
    ChessPieceType.rook,
        isWhite:true,
        imagePath: "lib/image/white/rook.png"
    );

    //place knights
    newBoard[0][1] = ChessPiece(type:
    ChessPieceType.knight,
        isWhite:false,
        imagePath: "lib/image/black/knight.png"
    );
    newBoard[0][6] = ChessPiece(type:
    ChessPieceType.knight,
        isWhite:false,
        imagePath: "lib/image/black/knight.png"
    );
    newBoard[7][1] = ChessPiece(type:
    ChessPieceType.knight,
        isWhite:true,
        imagePath: "lib/image/white/knight.png"
    );
    newBoard[7][6] = ChessPiece(type:
    ChessPieceType.knight,
        isWhite:true,
        imagePath: "lib/image/white/knight.png"
    );


    //place bishops
    newBoard[0][2] = ChessPiece(type:
    ChessPieceType.bishop,
        isWhite:false,
        imagePath: "lib/image/black/bishop.png"
    );
    newBoard[0][5] = ChessPiece(type:
    ChessPieceType.bishop,
        isWhite:false,
        imagePath: "lib/image/black/bishop.png"
    );
    newBoard[7][2] = ChessPiece(type:
    ChessPieceType.bishop,
        isWhite:true,
        imagePath: "lib/image/white/bishop.png"
    );
    newBoard[7][5] = ChessPiece(type:
    ChessPieceType.bishop,
        isWhite:true,
        imagePath: "lib/image/white/bishop.png"
    );

    //place queens
    newBoard[0][3] = ChessPiece(type:
    ChessPieceType.queen,
        isWhite:false,
        imagePath: "lib/image/black/queen.png"
    );
    newBoard[7][4] = ChessPiece(type:
    ChessPieceType.queen,
        isWhite:true,
        imagePath: "lib/image/white/queen.png"
    );

    //place kings
    newBoard[0][4] = ChessPiece(type:
    ChessPieceType.king,
        isWhite:false,
        imagePath: "lib/image/black/king.png"
    );
    newBoard[7][3] = ChessPiece(type:
    ChessPieceType.king,
        isWhite:true,
        imagePath: "lib/image/white/king.png"
    );



    board = newBoard;

  }

  //User selected a piece
  void pieceSelected(int row, int col){
    setState(() {
      // no piece has been selected yet, this is the first selection
      if(selectedPiece == null && board[row][col] != null ){
        if(board[row][col]!.isWhite == isWhiteTurn){
          selectedPiece = board[row][col];
          selectedRow = row ;
          selectedCol = col;

        }
        selectedPiece  = board[row] [col];
        selectedRow = row;
        selectedCol = col;
      }


      //there is a piece already selected, but a user can select another one of thier pieces
      else if( board[row][col] != null && board[row][col] !.isWhite == selectedPiece!.isWhite){
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;

      }


      // if there is a piece selcted and the user taps on a valid move, move there
      else if(selectedPiece != null && validMoves.any((element) => element [0] == row && element[1] == col)){
        movePiece(row, col);

      }

      //if a piece is selected calculate it valid moves
      validMoves = calculateRealValidMoves(selectedRow,selectedCol, selectedPiece,true);

    });
  }


  // calculate raw valid moves
  List<List<int>> calculateRawValidMoves(
      int row, int col, ChessPiece? piece){
      List<List<int>> candidateMoves = [];

      if(piece == null){
        return [];

      }

      // different direction based on thier color
      int direction = piece .isWhite ? -1 : 1;

      switch(piece.type){
        case ChessPieceType.pawn:
          // pawn can move forward if the square is not occupied
        if(isInboard(row + direction, col) &&
            board[row + direction][col] == null){
          candidateMoves.add([row+ direction,col]);
        }

        // pawn can move 2 square forward if key are at their initial  position
          if((row ==1 && !piece.isWhite) || (row ==6 && piece.isWhite)){
            if(isInboard(row + 2 * direction, col) &&
                board[row + 2 * direction][col] == null &&
                board[row + 2 * direction][col] == null){
                candidateMoves.add([row + 2 * direction,col]);
            }
          }
        // pawn can kill diagonally
        if(isInboard(row + direction, col -1 ) &&
            board[row+direction][col - 1] != null &&
            board[row +  direction][col - 1] !.isWhite !=piece.isWhite){
             candidateMoves.add([row + direction, col -1]);
        }


        if(isInboard(row + direction, col +1 ) &&
            board[row+direction][col + 1] != null &&
            board[row +  direction][col + 1] !.isWhite != piece.isWhite){
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
        case ChessPieceType.rook:

          // horizontal and vertical directions

        var directions = [
          [-1,0], //up
          [1,0],  //down
          [0,-1],  //left
          [0,1],  //right
        ];

        for(var direction in directions){
          var i = 1;
          while(true){
            var newRow = row +i *direction[0];
            var newCol =  col + i * direction[1];

            if(!isInboard(newRow, newCol)){
              break;
            }
            if(board [newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMoves.add([newCol,newCol]); // kill it valid move
              }
              break;
            }
            candidateMoves.add([newRow,newCol]);
            i++;

          }
        }
        break;
        case ChessPieceType.knight:
          // all eight possible L shapes the knight can move
        var knightMoves =[
          [-2,-1], // up 2 left 1
          [-2,1],  // up 2 right 1
          [-1,-2], // up 1 left 2
          [-1,2], // up 1 right 2
          [1,-2], // down 1 left 2
          [1,2], // down 1 right 2
          [2,-1], // down 2 left 1
          [2,1], // down 2 right 1
        ];
        for (var move in knightMoves){
          var newRow = row + move[0];
          var newCol = col + move[1];
          if(!isInboard(newRow,newCol)){
            continue;
          }
          if(board[newRow][newCol] != null){
            if(board[newRow][newCol] !.isWhite !=piece.isWhite){
              candidateMoves.add([newRow,newCol]); // capture
            }
            continue;
          }
          candidateMoves.add([newRow,newCol]);

        }
        break;
        case ChessPieceType.bishop:

          // diagonal direction
        var directions = [
          [-1,-1],
          [-1,1],
          [1,-1],
          [1,1],
        ];

        for( var direction in directions){
          var i =1;
          while(true){
            var newRow = row + i * direction[0];
            var newCol = row + i * direction[1];

            if(!isInboard(newRow,newCol)){
              break;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol] !.isWhite !=piece.isWhite){
                candidateMoves.add([newRow,newCol]); //capture
              }
              break; //block
            }
            candidateMoves.add([newRow,newCol]);
            i++;
          }

        }
        break;
        case ChessPieceType.queen:
          // all  eight directions up, down, left, right and 4 diagonals

        var directions =[
          [-1,0],
          [1,0],
          [0,-1],
          [0,1],
          [-1,-1],
          [-1,1],
          [1,-1],
          [1,1],
        ];
        for( var direction in directions){
          var i = 1;
          while(true){
            var newRow = row + i * direction [0];
            var newCol = col + i * direction [1];
            if(isInboard(newRow, newCol)){
              break;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite !=piece.isWhite){
                candidateMoves.add([newRow,newCol]);
              }
              break;
            }
            candidateMoves.add([newRow,newCol]);
            i++;
          }

        }
        break;
        case ChessPieceType.king:

        // all  eight  directions
          var knightMoves =[
            [-1,0],
            [1,0],
            [0,-1],
            [0,1],
            [-1,-1],
            [-1,1],
            [1,-1],
            [1,1],
          ];
          for( var move in knightMoves){
              var newRow = row + move [0];
              var newCol = col + move[1];
              if(isInboard(newRow, newCol)){
                continue;
              }
              if(board[newRow][newCol] != null){
                if(board[newRow][newCol]!.isWhite !=piece.isWhite){
                  candidateMoves.add([newRow,newCol]);
              }
                continue;

            }
              candidateMoves.add([newRow,newCol]);

          }
        break;

      }
      return candidateMoves;
  }

  // calculate real valid moves
  List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation){
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    //after generating all candidate valid moves let filter out any that will result in a king check

    if(checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        //this will simulate the future move to see if it safe
        if (simulatedMoveIsSafe(piece!, row, col , endRow ,endCol )) {
          realValidMoves.add(move);
        }
      }
    }else {
      realValidMoves = candidateMoves;
    }
return realValidMoves;
    }



  // Move piece
  void movePiece(int newRow, int newCol){
    // if the new spot has an enemy piece
    if(board[newRow][newCol] != null){

      // add the captured piece to the appropriate list
      var capturedPiece  = board[newRow][newCol];
      if(capturedPiece!.isWhite){
        whitePieceTaken.add(capturedPiece);

      } else{
        blackPieceTaken.add(capturedPiece);
      }
    }
    // check if the piece being moved is a king
    if(selectedPiece!.type == ChessPieceType.king){

      // update the appropriate  king position

      if(selectedPiece!.isWhite){
        whiteKingPosition = [newRow,newCol];
      }else{
        blackKingPosition = [newRow,newCol];
      }
    }

    // move the piece clear old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow] [selectedCol] = null;

    // see if any kings are under attack

    if(isKingInCheck(!isWhiteTurn)){
      checkStatus = true;
    } else{
      checkStatus = false;
    }

    //clear selection
    setState(() {
      selectedPiece = null;
      selectedRow  = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // check if it's check mate
    if(!isCheckMate(!isWhiteTurn)){
      showDialog(context: context, builder: (context) => AlertDialog(
        title: const Text("CHECK MATE!"),
        actions: [
          // play again button
          TextButton(onPressed: resetGame, child: const Text("Play Again")),
        ],
      ));
    }

    // change turn
   isWhiteTurn = !isWhiteTurn;
  }

// is King in Check?
bool  isKingInCheck(bool isWhiteKing){
    // get the position of the king
  List<int> kingPosition = isWhiteKing ?whiteKingPosition:blackKingPosition;

  // check if any enemy piece can attack the king
    for(int i = 0; i< 8;i++){
      for(int j = 0; j< 8; j++){
        // skip  empty square and piece of same color as the king
        if(board[i][j] == null || board[i][j]!.isWhite == isWhiteKing){
          continue;
        }
        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j,board[i][j],false);

        // check if kings position is in any valid moves
        if(pieceValidMoves.any((move)=> move[0] == kingPosition[0] )){
          return true;
        }
      }
    }
    return false;
}

// simulate a future move to see if it safe (doesn't put your own king under attack)
  bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int staetCol, int endRow, int endCol){
    // save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    // if the piece is the king it's current position snd update to the new one
    List<int>? originalKIngPosition;
    if(piece.type == ChessPieceType.king){
      originalKIngPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;

      // update the king position
      if(piece.isWhite){
        whiteKingPosition = [endRow,endCol];
      } else{
        blackKingPosition = [endRow,endCol];
      }
    }

    // simulate the move
    board [endRow][endCol] = piece;
    board[startRow][staetCol] = null;

    // check if our own king is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);


    // restore board to original state

    board[startRow][staetCol] =piece;
    board[endRow][endCol] = originalDestinationPiece;

    // if the piece was the king, restore it original position
    if(piece.type ==ChessPieceType.king){
      if(piece.isWhite){
        whiteKingPosition = originalKIngPosition!;
      }else{
        blackKingPosition = originalKIngPosition!;
      }
    }
    // if the king is in check = true, mean it's not safe move safe move = false
    return !kingInCheck;
  }


  // is it  check mate

  bool isCheckMate (bool isWhiteKIng){

    // if the king is not in check, then it not checkmate
    if(!isKingInCheck(isWhiteKIng)){
      return false;
    }
    //if there is at least one legal move for any of thr players piece, then it's not checkmate
    for(int i = 0; i< 8; i++ ){
      for(int j = 0; j<8; j++){
        // skip empty sqaure  and piece of the other color
        if(board[i][j] == null || board[i][j]!.isWhite != isWhiteKIng){
          continue;

        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j], true);

        // if this piece has any valid moves, then it's not checkmate
        if(pieceValidMoves.isNotEmpty){
          return false;
        }
      }
    }

    // if none of the above condition are met, then there are no legal move left to make

    // it's check mate!
    return true;
  }

  // reset game

  void resetGame(){
    Navigator.pop(context);
    _intitializeBoard();
    checkStatus = false;
    whitePieceTaken.clear();
    blackKingPosition.clear();
    whiteKingPosition = [7,4];
    blackKingPosition = [0,4];
    isWhiteTurn = true;
    setState(() {


    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // WHITE PIECE TAKEN
          Expanded(child: GridView.builder(
            itemCount: whitePieceTaken.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8),
            itemBuilder:(context,index) => DeadPiece(
              imagePath: whitePieceTaken[index].imagePath,
              isWhite: true,
            ),
          )),

         // GAME STATUS
          Text(checkStatus ? "CHECK!" : ""),
          //CHESS BOARD
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount:8 *  8 ,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) {
                //get the row and column position of this square
              int row = index ~/ 8;
              int col = index % 8;

              // check if this square is selected
              bool isSelected = selectedRow == row && selectedCol == col;

              // check if it is a valid move

              bool isValidMove = false;
              for(var position in validMoves){
                // compare row and col

                if(position[0] == row && position[1] == col){
                  isValidMove = true;
                }
              }
                 return Square(
                   isWhite: isWhite(index),
                   piece: board[row][col],
                   isSelected: isSelected,
                   isValidMove: isValidMove ,
                   onTap:() => pieceSelected(row,col) ,
                 );
              },
            ),
          ),
          // BLACK PIECE TAKEN

          Expanded(child: GridView.builder(
            itemCount: blackPieceTaken.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8),
            itemBuilder:(context,index) => DeadPiece(
              imagePath: blackPieceTaken[index].imagePath,
              isWhite: true,
            ),
          )),


        ],
      ),
    );
  }
}
