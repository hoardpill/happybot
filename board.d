module board;

import std.stdio;
import std.string;
import std.conv;

import piecemovement;


int fromCol;
int fromRow;
int toCol;
int toRow;
bool captureLegal;
int capturingColor = 0;
int capturedColor = 1;
string fenString = "";
bool turn = false;
int row;
int col;
int pieceVal;
int ply = -1;
int turnInt = 1;

int abs(int value) {
    if (value >= 0) {
        return value;
    } else {
        return -value;
    }
}


ubyte[8][8] chessBoard = [            // a             h
    [ 7,  3,  5,  9, 11,  5,  3,  7], // R N B Q K B N R 1
    [ 1,  1,  1,  1,  1,  1,  1,  1], // P P P P P P P P  White's pieces
    [ 0,  0,  0,  0,  0,  0,  0,  0], // . . . . . . . .
    [ 0,  0,  0,  0,  0,  0,  0,  0], // . . . . . . . .
    [ 0,  0,  0,  0,  0,  0,  0,  0], // . . . . . . . .
    [ 0,  0,  0,  0,  0,  0,  0,  0], // . . . . . . . .
    [ 2,  2,  2,  2,  2,  2,  2,  2], // P P P P P P P P  Black's pieces
    [ 8,  4,  6, 10, 12,  6,  4,  8]  // R N B Q K B N R 8
]; 

// Display the board
void displayBoard() {
    foreach_reverse(i; 0 .. 8) { //flip board
        foreach(j; 0 .. 8) {
            char piece;

            switch (chessBoard[i][j]) {
                case 1: piece = 'P'; break; // White Pawn
                case 3: piece = 'N'; break; // White Knight
                case 5: piece = 'B'; break; // White Bishop
                case 7: piece = 'R'; break; // White Rook
                case 9: piece = 'Q'; break; // White Queen
                case 11: piece = 'K'; break; // White King
                case 2: piece = 'p'; break; // Black Pawn
                case 4: piece = 'n'; break; // Black Knight
                case 6: piece = 'b'; break; // Black Bishop
                case 8: piece = 'r'; break; // Black Rook
                case 10: piece = 'q'; break; // Black Queen
                case 12: piece = 'k'; break; // Black King
                default: piece = '.'; // Unoccupied square
            }
            writef("%s ", piece);
        }
        writeln();
    }
    turns();
}

// Translate algebraic notation to array indices
void movePiece(string move) {
    fromCol = move[0] - 'a';
    fromRow = move[1] - '1';
    toCol = move[2] - 'a';
    toRow = move[3] - '1';
    int rowDiff = (toRow - fromRow);
    int colDiff = (toCol - fromCol);
    bool isValidKnightMove(int fromRow, int fromCol, int toRow, int toCol){
        // Check if move is in L shape in any direction
        if ((rowDiff == 2 || rowDiff == -2) && (colDiff == 1 || colDiff == -1)){
            return true;
        }
        else if((rowDiff == 1 || rowDiff == -1) && (colDiff == 2 || colDiff == -2)){
            return true;
        }
        return false;
    }
    bool isValidKingMove(int fromRow, int fromCol, int toRow, int toCol) {
        // Check if the move is one square in any direction
        if ((rowDiff <= 1) && (colDiff <= 1)) {
            return true;
        }
        return false;
    }
    bool isValidBishopMove(int fromRow, int fromCol, int toRow, int toCol){
        // Check if the move is diagonal
        if (colDiff == rowDiff || -colDiff == rowDiff || -colDiff == -rowDiff || colDiff == -rowDiff){
            return true;
		}
        return false;
	}
	bool isValidRookMove(int fromRow, int fromCol, int toRow, int toCol){
        // Check if the move is straight
        if (rowDiff == 0 || colDiff == 0){
            return true;
		}
        return false;
	}   
    bool isValidQueenMove(int fromRow, int fromCol, int toRow, int toCol){
        if (isValidRookMove(fromRow, fromCol, toRow, toCol) || (isValidBishopMove(fromRow, fromCol, toRow, toCol))){
            return true;
		}
        return false;
	}
    bool isValidPawnMove(int fromRow, int fromCol, int toRow, int toCol){
        
        if (chessBoard[fromRow][fromCol] == 1) { // White pawn
			if (fromRow == 1) { // Check if on the starting row
				if (rowDiff == 1 || rowDiff == 2) {
					if (colDiff == 0 && chessBoard[toRow][toCol] == 0) { // Check if destination of move is empty
						return true;
					} else if (rowDiff == 2 && chessBoard[toRow - 1][toCol] == 0) { // Check two squares
						return true;
					}
				}
			} else {
				if (rowDiff == 1 && colDiff == 0 && chessBoard[toRow][toCol] == 0) { // Check if one square ahead is empty
					return true;
				}
			}
		} else if (chessBoard[fromRow][fromCol] == 2) { // Black pawn
			if (fromRow == 6) { // Check if on the starting row
				if (rowDiff == -1 || rowDiff == -2) {
					if (colDiff == 0 && chessBoard[toRow][toCol] == 0) { // Check if destination of move is empty
						return true;
					} else if (rowDiff == -2 && chessBoard[toRow + 1][toCol] == 0) { // Check two squares
						return true;
					}
				}
			} else {
				if (rowDiff == -1 && colDiff == 0 && chessBoard[toRow][toCol] == 0) { // Check if one square ahead is empty
					return true;
				}
			}
		}
        if (abs(colDiff) == 1 && abs(rowDiff) == 1 && chessBoard[toRow][toCol] != 0) {
			if (chessBoard[fromRow][fromCol] == 1 && rowDiff == 1) { // pawn capture for white EXPERIMENTAL 
				return true;
			} else if (chessBoard[fromRow][fromCol] == 2 && rowDiff == -1) { // pawn for black capture
				return true;
			}
		}
        return false;
	}
    bool isWhiteTurn(){
        if (ply % 2 == 0){
            return true;
		}
        return false;
	}
    bool turnAffirm(int fromRow, int fromCol, int toRow, int toCol){
        if (isWhiteTurn == chessBoard[fromRow][fromCol] % 2){
            return true;
		}
        return false;
    }
    bool isCapture(int fromRow, int fromCol, int toRow, int toCol){
        // Check white captures white or black captures black
        capturingColor = chessBoard[fromRow][fromCol] % 2; // Gets attacking piece color
        capturedColor = chessBoard[toRow][toCol] % 2; // Gets defending piece color
        if((capturingColor == capturedColor) && (chessBoard[toRow][toCol] != 0)){
            // Note: ensures that piece is not just moving to an empty square
            return false;
        }
        else {
            return true;
        }
    }
    // Perform the move
    if (isCapture(fromRow, fromCol, toRow, toCol) && turnAffirm(fromRow, fromCol, toRow, toCol)){
        if (chessBoard[fromRow][fromCol] == 11 || chessBoard[fromRow][fromCol] == 12) {
            // Check if the move is valid for the king
            if (isValidKingMove(fromRow, fromCol, toRow, toCol)) {
                // Perform the move
                chessBoard[toRow][toCol] = chessBoard[fromRow][fromCol];
                chessBoard[fromRow][fromCol] = 0;
                displayBoard();// Display the updated board				
            }
        } else if (chessBoard[fromRow][fromCol] == 3 || chessBoard[fromRow][fromCol] == 4) {
            // Check if the move is valid for the king
            if (isValidKnightMove(fromRow, fromCol, toRow, toCol)) {
                // Perform the move
                chessBoard[toRow][toCol] = chessBoard[fromRow][fromCol];
                chessBoard[fromRow][fromCol] = 0;
                displayBoard();// Display the updated 
            }
        } else if (chessBoard[fromRow][fromCol] == 5 || chessBoard[fromRow][fromCol] == 6) {
            // Check if the move is valid for the bishop
            if (isValidBishopMove(fromRow, fromCol, toRow, toCol)) {
                // Perform the move
                chessBoard[toRow][toCol] = chessBoard[fromRow][fromCol];
                chessBoard[fromRow][fromCol] = 0;
                displayBoard();// Display the updated board
            }
        } else if (chessBoard[fromRow][fromCol] == 7 || chessBoard[fromRow][fromCol] == 8){
            // Check if the move is valid for the rook
            if (isValidRookMove(fromRow, fromCol, toRow, toCol)){
                // Perform the move
                chessBoard[toRow][toCol] = chessBoard[fromRow][fromCol];
                chessBoard[fromRow][fromCol] = 0;
                displayBoard();// Display the updated board
			}
		} else if(chessBoard[fromRow][fromCol] == 9 || chessBoard[fromRow][fromCol] == 10){
            // Check if the move is valid for the queen
            if (isValidQueenMove(fromRow, fromCol, toRow, toCol)){
                chessBoard[toRow][toCol] = chessBoard[fromRow][fromCol];
                chessBoard[fromRow][fromCol] = 0;
                displayBoard();// Display the updated board
            }
        } else if (chessBoard[fromRow][fromCol] == 1 || chessBoard[fromRow][fromCol] == 2){
            // Check if the move is valid for the pawn
            if (isValidPawnMove(fromRow, fromCol, toRow, toCol)){
                chessBoard[toRow][toCol] = chessBoard[fromRow][fromCol];
			    chessBoard[fromRow][fromCol] = 0;
			    displayBoard();// Display the updated board
		    }
		} else {
             // do nothing
        }
    }   
    string rowString = to!string(toRow);
    string colString = to!string(toCol);
}

string userInput;
void turns(){
    ply = ++ply;
    string plyString = to!string(ply);
    writeln("\nPly:      " ~ plyString);
    turnInt = (ply / 2) + 1;
    string turnString = to!string(turnInt);
    writeln("\nTurn:     " ~ turnString);
}

void writeFen(){
    // Flip the board
    foreach_reverse (row; chessBoard) {
        int emptyCount = 0;
        foreach (piece; row) {
            if (piece != 0) {
                if (emptyCount > 0) {
                    fenString ~= cast(char)(emptyCount + '0');
                    emptyCount = 0;
                } 
                // Add pieces to FEN
                int index = cast(ubyte)(piece - 1);
                char pieceName = ['P', 'p', 'N', 'n', 'B', 'b',
                                  'R', 'r', 'Q', 'q', 'K', 'k'][index];
                fenString ~= pieceName;
            } else {
                emptyCount++;
            }
        }
        // Fill empty squares in FEN
        if (emptyCount > 0) {
            fenString ~= cast(char)(emptyCount + '0');
        }
        fenString ~= "/"; // Add linebreaks
    }
    fenString = fenString[0 .. $-1]; // Remove the last break
    writeln(fenString);
    fenString = ""; // Reset the string
}

void gameLoop() {
    displayBoard(); // Display the initial board
    writeFen(); // Initial FEN
    // Main game loop
    while (true) {
        write("Enter your move: ");
        userInput = readln(); // Get user input
        if(userInput == ""){
            break;
		}
        movePiece(userInput);// Perform the move
        writeFen(); // Display FEN string
        
    }
 }

void main() {
    gameLoop();  
    writeln("\n");
}
