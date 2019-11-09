import 'dart:math';

import '../../../../core/enums/direction.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/tile.dart';
import '../../domain/entities/traversal.dart';
import '../../domain/entities/vector.dart';
import '../../domain/repositories/board_repository.dart';

class LocalBoardRepository implements BoardRepository {
  Board _currentBoard;
  final Random _random;

  LocalBoardRepository() : _random = Random();

  /// Get the starting board with a single random '2' tile in it.
  @override
  Future<Board> getCurrentBoard() async {
    // Initialize the current board if it does not exist yet.
    _currentBoard = _currentBoard ?? initializeBoard();

    return _currentBoard;
  }

  /// Update the [board] by moving the tiles in the given [direction]
  @override
  Future<Board> updateBoard(Board board, Direction direction) async {
    int size = 4;
    var vector = Vector.fromDirection(direction);
    var traversal = Traversal.fromVector(vector, size);
    bool moved = false;

    // traverse the grid
    for (var i = 0; i < size; i++) {
      int x = traversal.x[i];
      for (var j = 0; j < size; j++) {
        int y = traversal.y[j];

        // get the tile at the current position [x][y]
        var currentTile = board.tiles[x][y];

        // skip empty cell
        if (currentTile == null) {
          break;
        }

        // get the tile final destination
        var destination = board.getTileDestination(currentTile, vector);
      }
    }

    return board;
  }

  /// Get the index of an empty tile
  Map<String, int> getRandomEmptyTile(Board board) {
    // get the empty tile indices
    var emptyTiles = board.getEmptyTiles();
    // return a random empty tile index
    return emptyTiles.toList()[_random.nextInt(emptyTiles.length)];
  }

  @override
  Future resetBoard() async {
    _currentBoard = null;
  }

  /// Initialize the board
  Board initializeBoard() {
    // get the random position for each tile
    var randomFirstTiles = _getRandomFirstTiles().toList();

    // generate all the tiles with the first tile at the random position
    var tiles = _generateTiles(
      randomFirstTiles.toList()[0],
      randomFirstTiles.toList()[1],
    );

    // create and return the new board.
    return Board(tiles);
  }

  /// Get random positioned tiles
  Iterable<Tile> _getRandomFirstTiles() sync* {
    // get the length of row and column with the square of max
    int square = 4;

    // generate the first tile
    var firstTile = Tile(
      2,
      x: _random.nextInt(square),
      y: _random.nextInt(square),
    );

    // return the first generated tile
    yield firstTile;

    // generate the second index
    int half = square ~/ 2;

    // get the second tile x position
    int secondTileX = 0;
    if (firstTile.x < half) {
      secondTileX = half + _random.nextInt(half);
    } else {
      secondTileX = _random.nextInt(half);
    }

    // get the second tile y position
    int secondTileY = 0;
    if (firstTile.y < half) {
      secondTileY = half + _random.nextInt(half);
    } else {
      secondTileY = _random.nextInt(half);
    }

    // generate and return the second random tile
    yield Tile(2, x: secondTileX, y: secondTileY);
  }

  /// Generate the board tiles with the first tile positionned at the given index
  List<List<Tile>> _generateTiles(Tile firstRandomTile, Tile secondRandomTile) {
    return List<List<Tile>>.generate(
      4,
      (x) {
        return List<Tile>.generate(
          4,
          (y) {
            if (firstRandomTile.x == x && firstRandomTile.y == y) {
              return firstRandomTile;
            }

            if (secondRandomTile.x == x && secondRandomTile.y == y) {
              return secondRandomTile;
            }

            return null;
          },
          growable: false,
        );
      },
      growable: false,
    );
  }
}