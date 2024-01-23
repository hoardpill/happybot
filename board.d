module board;

import std.stdio;
import std.string;
import std.conv;

import piecemovement;

ubyte[8][8] chessBoard = [
    [ 7,  3,  5,  9, 11,  5,  3,  7], // R N B Q K B N R
    [ 1,  1,  1,  1,  1,  1,  1,  1], // P P P P P P P P
    [ 0,  0,  0,  0,  0,  0,  0,  0], // . . . . . . . .
    [ 0,  0,  0,  0,  0,  0,  0,  0], // . . . . . . . .
    [ 0,  0,  0,  0,  0,  0,  0,  0], // . . . . . . . .
    [ 0,  0,  0,  0,  0,  0,  0,  0], // . . . . . . . .
    [ 2,  2,  2,  2,  2,  2,  2,  2], // P P P P P P P P
    [ 8,  4,  6, 10, 12,  6,  4,  8]  // R N B Q K B N R
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
}
int fromCol;
int fromRow;
int toCol;
int toRow;
bool captureLegal;
int capturingColor = 0;
int capturedColor = 1;
// Translate algebraic notation to array indices
void movePiece(string move) {
    fromCol = move[0] - 'a';
    fromRow = move[1] - '1';
    toCol = move[2] - 'a';
    toRow = move[3] - '1';
	bool isValidKingMove(int fromRow, int fromCol, int toRow, int toCol) {
		int rowDiff = (toRow - fromRow);
		int colDiff = (toCol - fromCol);
        // Check if the move is one square in any direction
		if ((rowDiff <= 1) && (colDiff <= 1)) {
			return true;
		}
		return false;
	}
        bool isCapture(int fromRow, int fromCol, int toRow, int toCol){
        
			capturingColor = chessBoard[fromRow][fromCol] % 2;
			capturedColor = chessBoard[toRow][toCol] % 2;
            if((capturingColor == capturedColor) && (chessBoard[toRow][toCol] != 0)){
                return false;

			}
            else{
                return true;
			}
        }
    // Perform the move
    if (isCapture(fromRow, fromCol, toRow, toCol)){
    if (chessBoard[fromRow][fromCol] == 11 || chessBoard[fromRow][fromCol] == 12) {
        // Check if the move is valid for the king
        if (isValidKingMove(fromRow, fromCol, toRow, toCol)) {
            // Perform the move
            chessBoard[toRow][toCol] = chessBoard[fromRow][fromCol];
            chessBoard[fromRow][fromCol] = 0;
            
            displayBoard();// Display the updated board
			writeln(generateFEN());// Generate and output FEN string
        }
    } else if(chessBoard[fromRow][fromCol] != 11 || chessBoard[fromRow][fromCol] != 12){
	        chessBoard[toRow][toCol] = chessBoard[fromRow][fromCol];
	        chessBoard[fromRow][fromCol] = 0;
            displayBoard();// Display the updated board
			writeln(generateFEN());// Generate and output FEN string
    } else {
        // Do nothing
    } }   
    string rowString = to!string(toRow);
	string colString = to!string(toCol);
	writeln(rowString ~ colString);


}
string fenString = "";

bool turn = false;
// Function to generate FEN string from the chess board
string generateFEN() {
    fenString = "";

    foreach_reverse (row; chessBoard) {
        int emptyCount = 0;
        foreach (piece; row) {
            if (piece != 0) {
                if (emptyCount > 0) {
                    fenString ~= cast(char)(emptyCount + '0');
                    emptyCount = 0;
                }
                char pieceName = ['P', 'N', 'B', 'R', 'Q', 'K', 'p', 'n', 'b', 'r', 'q', 'k'][((piece + 1) / 2) - 1];
                fenString ~= pieceName;
            } else {
                emptyCount++;
            }
        }
        if (emptyCount > 0) {
            fenString ~= cast(char)(emptyCount + '0');
        }
        fenString ~= "/";
    }

    fenString = fenString[0 .. $-1]; // Remove the trailing '/'

    // FEN turns
    if (turn == true) {
        fenString = fenString ~ " b ";
    } else {
        fenString = fenString ~ " w ";
    }

    ply = ++ply;
    string plyString = to!string(ply);
    fenString = fenString ~ "\nPly:      " ~ plyString;
    turnInt = (ply / 2) + 1;
    string turnString = to!string(turnInt);
    fenString = fenString ~ "\nTurn:     " ~ turnString;

    return fenString;
}


int row;
int col;
int pieceVal;
int ply = -1;
int turnInt = 1;
// Function to update the chess board from FEN string
void updateBoardFromFEN(string fenString) {
    row = 0;
    col = 0;
    foreach (char c; fenString) {
        if (c >= '1' && c <= '8') {
            col += c - '0';
        } else if (c == '/') {
            row++;
            col = 0;
        } else {
            pieceVal = (c >= 'a' && c <= 'h') ? c - 'a' + 1 : c - 'A' + 7;
            chessBoard[row][col++] = cast(ubyte)pieceVal; 
        }
    }
    
} //update the board
ubyte getPiece(ubyte[][] board, int row, int col) {
    return board[row][col];
}

string userInput;
void gameLoop() {
    
    displayBoard(); // Display the initial board
    writeln("Initial FEN: ", generateFEN());
    // Main game loop
    while (true) {
        write("Enter your move: ");
        userInput = readln(); // Get user input
		turn = !turn;// Toggle turn
        movePiece(userInput);// Perform the move
        
    }
    
}

void main() {
    
    gameLoop();  
    writeln("\n");
    
}
