import 'dart:math';

import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:chess/components/piece.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;

  const Square({super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.onTap,
    required this.isValidMove,
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    // if selected, square is green

    if(isSelected){
      squareColor = Colors.green;
    }

   else if(isValidMove){
     squareColor = Colors.green[200];

    }
    // otherwise, it's white or black
    else{
      squareColor = isWhite ? foregroundColor :backgroundColor;
    }

    return GestureDetector(
       onTap: onTap ,
      child: Container(
        margin: EdgeInsets.all(isValidMove ? 8 : 0),
        color: squareColor,
        child: piece != null ? Image.asset(piece!.imagePath): null,
      ),
    );
  }
}
