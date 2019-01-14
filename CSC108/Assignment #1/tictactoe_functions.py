import math

EMPTY = '-'

def is_between(value, min_value, max_value):
    """ (number, number, number) -> bool

    Precondition: min_value <= max_value

    Return True if and only if value is between min_value and max_value,
    or equal to one or both of them.

    >>> is_between(1.0, 0.0, 2)
    True
    >>> is_between(0, 1, 2)
    False
    """
    if value >= min_value and value <= max_value:
        return True
    else:
        return False
    
    # This function determines if the value is between minimum value and 
    # maximum value.
    
def game_board_full(game_board):
    """ (str) -> bool
    
    Return True if and only if all of the cells in the game_board have been
    chosen.
    
    >>> game_board_full('XOOX')
    True
    >>> game_board_full('X-OX')
    False
    """
    if '-' not in game_board:
        return True
    else:
        return False
   
   # This function works for checking if there is empty cells in the game board.
   
def get_board_size(game_board):
    """ (str) -> int
    Return the length of each side of the given tic-tac-toe game_board.
    
    >>> get_board_size('XOOXOOXOO')
    3
    >>> get_board_size('XOXO')
    2
    """
    return int(len(game_board) ** 0.5)

    # This function returns the length of the side of game board and transfer 
    # it into type 'string' simultaneosly.

def make_empty_board(empty_board_size):
    """(int) -> str
    
    Procondition empty_board_size >= 1 and <= 9
    
    Return a string for storing information about a tic-tac-toe game board 
    whose size is given by the parameter.
    
    >>> make_empty_board(3)
    '---------'
    >>> make_empty_board(2)
    '----'
    """
    return '-' * (empty_board_size) ** 2
    # Through the formula, '-' is used to compose a empty game board.

def get_position(row_index, col_index, board_size):
    """(int, int, int) -> int
    
    Return the str_index of the cell in the string representation of the game
    board (board_size) corresponding to the given row_index and column_index.
    
    >>> get_position(3,3,3)
    8
    >>> get_position(2,2,2)
    3
    """
    
    str_index = (row_index -1) * board_size + col_index - 1
    return str_index

    # This function transfers the positions of symbol into a string presentation
    # though the fomulara.
    
def make_move(symbol, row_index, col_index, game_board):
    """(str, int, int, str) -> str
    
    return the tic-tac-toe game board that results when the given symbol is
    placed at the given cell position in the given tic-tac-toe game_board.
    
    >>> make_move ('X', 3, 3, 'XXXOOOXX-')
    XXXOOOXXX
    
    >>> make_move ('X', 2, 2, 'XXO-')
    XXOX
    """
    board_size = int(len(game_board) ** 0.5)
    str_index = (row_index -1) * board_size + col_index - 1
    start = (row_index -1) * board_size + col_index
    return game_board[:str_index] + symbol + game_board[start:]

    # Through inserting four parameters, this function returns a new game board 
    # with am extra symbol.

def extract_line(game_board, direction, row_or_col):
    """(str, str, int) -> str
    
    return the characters that make up the specified row (when the second 
    parameter is 'across'), column (when the second parameter is 'down') or 
    diagonal from the given tic-tac-toe game board.
    
    >>> extract_line ('XXOO', 'down', 2)
    XO
    >>>extract_line ('XXXOOOXXX', 'down_diagonal', 3)
    XOX
    """
    board_size = int(len(game_board) ** 0.5)
    if direction == 'down':
        return game_board[row_or_col - 1:row_or_col + board_size * 
                          (board_size - 1):board_size]
    elif direction == 'across':
        return game_board[board_size * row_or_col - board_size : board_size * 
                          row_or_col: 1]
    elif direction == 'down_diagonal':
        return game_board[0:(board_size + 1) * (board_size - 1) + 
                          1:board_size + 1]
    elif direction == 'up_diagonal':
        return game_board[board_size * (board_size - 1):board_size - 
                          2:-(board_size - 1)]
    
    # The function returns a line in the game board, including down, across, 
    # down_diagonal and up_diagonal.
    
    # Students are to complete the body of this function, and then put their
    # solutions for the other required functions below this function.

