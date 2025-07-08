 bool isWhite( int index){
   int x = index ~/ 8; // this gives us the integer division eg. row
   int y = index % 8; // this gives us the integer division eg. column

   // alternate color for each square
   bool isWhite = (x + y) % 2 == 0;
   return isWhite;

 }

 bool isInboard( int row, int col ){

  return row >=0 && row < 8 && col >= 0 && col <8;
 }