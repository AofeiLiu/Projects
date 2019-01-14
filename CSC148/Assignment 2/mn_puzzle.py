from puzzle import Puzzle
VALID = ((-1, 0), (1, 0), (0, -1), (0, 1))


class MNPuzzle(Puzzle):
    """
    An nxm puzzle, like the 15-puzzle, which may be solved, unsolved,
    or even unsolvable.

     === Attributes ===
    @type from_grid: tuple[tuple[str]]
        The board of the MNPuzzle
    @type to_grid: tuple[tuple[str]]
        The board that is the solution of the MNPuzzle
    @type n: int
        The length of the column of the board
    @type m: int
        The length of the row of the board
    """

    def __init__(self, from_grid, to_grid):
        """
        MNPuzzle in state from_grid, working towards
        state to_grid

        @param MNPuzzle self: this MNPuzzle
        @param tuple[tuple[str]] from_grid: current configuration
        @param tuple[tuple[str]] to_grid: solution configuration
        @rtype: None
        """
        # represent grid symbols with letters or numerals
        # represent the empty space with a "*"
        assert len(from_grid) > 0
        assert all([len(r) == len(from_grid[0]) for r in from_grid])
        assert all([len(r) == len(to_grid[0]) for r in to_grid])
        self.n, self.m = len(from_grid), len(from_grid[0])
        self.from_grid, self.to_grid = from_grid, to_grid

    # TODO
    # implement __eq__ and __str__
    # __repr__ is up to you

    def __eq__(self, other):
        """
        Return whether MNPuzzle self is equivalent to other.

        @type self: MNPuzzle
        @type other: MNPuzzle | Any
        @rtype: bool

        >>> target_grid = (("1", "2", "3"), ("4", "5", "*"))
        >>> start_grid = (("*", "2", "3"), ("1", "4", "5"))
        >>> mn1 = MNPuzzle(start_grid, target_grid)
        >>> target_grid2 = (("1", "2", "3"), ("4", "5", "*"))
        >>> start_grid2 = (("*", "2", "3"), ("1", "4", "5"))
        >>> mn2 = MNPuzzle(start_grid2, target_grid2)
        >>> mn1.__eq__(mn2)
        True
        >>> target_grid3 = (("5", "4", "3"), ("4", "9", "*"))
        >>> start_grid3 = (("*", "8", "3"), ("9", "4", "5"))
        >>> mn3 = MNPuzzle(start_grid3, target_grid3)
        >>> mn1.__eq__(mn3)
        False
        """
        return (self.n == other.n and self.m == other.m and self.from_grid ==
                other.from_grid and self.to_grid == other.to_grid)

    def __str__(self):
        """
        Return a human-readable string representation of MNPuzzle self.

        @type: self: MNPuzzle
        @rtype: str

        >>> target_grid = (("1", "2", "3"), ("4", "5", "*"))
        >>> start_grid = (("*", "2", "3"), ("1", "4", "5"))
        >>> print(MNPuzzle(start_grid, target_grid))
        |*|2|3|
        |1|4|5|
        """
        string = ''
        for i in range(len(self.from_grid)):
            for square in self.from_grid[i]:
                string += '|' + square
            string += '|' + '\n'
        return string.strip()

    def extensions(self):
        """
        Return list of extensions of MNPuzzle self.
        @type self: MNPuzzle
        @rtype: list[MNPuzzle]

        >>> target_grid = (("1", "2", "3"), ("4", "5", "*"))
        >>> start_grid = (("*", "2", "3"), ("1", "4", "5"))
        >>> r_1 = MNPuzzle((("1", "2", "3"), ("*", "4", "5")), target_grid)
        >>> r_2 = MNPuzzle((("2", "*", "3"), ("1", "4", "5")), target_grid)
        >>> mn = MNPuzzle(start_grid, target_grid)
        >>> mn.extensions() == [r_1, r_2]
        True
        >>> start_grid = (("1", "2", "3"), ("4", "*", "5"), ("6", "7", "8"))
        >>> r_1 = MNPuzzle((("1", "2", "3"), ("*", "4", "5"), ("6", "7", "8")), target_grid)
        >>> r_2 = MNPuzzle((("1", "2", "3"), ("4", "5", "*"), ("6", "7", "8")), target_grid)
        >>> r_3 = MNPuzzle((("1", "2", "3"), ("4", "7", "5"), ("6", "*", "8")), target_grid)
        >>> r_4 = MNPuzzle((("1", "*", "3"), ("4", "2", "5"), ("6", "7", "8")), target_grid)
        >>> mn = MNPuzzle(start_grid, target_grid)
        >>> r = [r_1, r_2, r_3, r_4]
        >>> result = mn.extensions()
        >>> [x in r for x in result] == [True, True, True, True]
        True
        >>> mn.from_grid == start_grid # to check original not altered
        True
        """
        # TODO
        # override extensions
        # legal extensions are configurations that can be reached by swapping one
        # symbol to the left, right, above, or below "*" with "*"
        steps = []
        grid = [list(x) for x in self.from_grid]
        for row in range(self.n):
            for col in range(self.m):
                if grid[row][col] == '*':
                    r, c = row, col
        for move in VALID:
            to_row, to_col = self.unpack(move, (r, c))
            if self.inbounds(to_row, to_col):
                new = [list(x) for x in self.from_grid]
                new[r][c], new[to_row][to_col] = new[to_row][to_col], new[r][c]
                steps.append(MNPuzzle(tuple([tuple(x) for x in new]), self.to_grid))
        return steps
    # Helper functions

    @staticmethod
    def unpack(move, pos):
        """
        Return the new position after make change in the position of row and column in the
        pos according to the order inside the move

        @param move: tuple[int]
        @param pos:  tuple(int)
        @return: int，
        """
        (r, c) = pos
        r += move[0]
        c += move[1]
        return r, c

    def inbounds(self, to_row, to_col):
        """
        Return True if the adjacent position is not out of index, otherwise return False

        @param to_row: int
        @param to_col: int
        @return: bool
        """
        return 0 <= to_row < self.n and 0 <= to_col < self.m

    def is_solved(self):
        """
        Return True or False depending on if the MNPuzzle self is
        solved. True is if self.from_grid equals self.to_grid

        @type self: MNPuzzle
        @rtype: bool

        >>> target_grid = (("1", "2", "3"), ("4", "5", "*"))
        >>> r_1 = MNPuzzle((("1", "2", "3"), ("4", "5", "*")), target_grid)
        >>> r_1.is_solved()
        True
        >>> r_2 = MNPuzzle((("1", "2", "5"), ("4", "3", "*")), target_grid)
        >>> r_2.is_solved()
        False
        """
        # TODO
        # override is_solved
        # a configuration is solved when from_grid is the same as to_grid
        if self.from_grid == self.to_grid:
            return True
        return False
if __name__ == "__main__":
    import doctest
    doctest.testmod()
    target_grid = (("1", "2", "3"), ("4", "5", "*"))
    start_grid = (("*", "2", "3"), ("1", "4", "5"))
    from puzzle_tools import breadth_first_solve, depth_first_solve
    from time import time
    start = time()
    solution = breadth_first_solve(MNPuzzle(start_grid, target_grid))
    end = time()
    print("BFS solved: \n\n{} \n\nin {} seconds".format(
        solution, end - start))
    start = time()
    solution = depth_first_solve((MNPuzzle(start_grid, target_grid)))
    end = time()
    print("DFS solved: \n\n{} \n\nin {} seconds".format(
        solution, end - start))
