from puzzle import Puzzle

VALID = (((-2, 0), (-1, 0)), ((2, 0), (1, 0)), ((0, -2), (0, -1)), ((0, 2), (0, 1)))


class GridPegSolitairePuzzle(Puzzle):
    """
    Snapshot of peg solitaire on a rectangular grid. May be solved,
    unsolved, or even unsolvable.

     === Attributes ===
    @type marker: str
        The board of the GridPegSolitairePuzzle
    @type marker_set: Location
        The symbol we used in GridPegSolitairePuzzle. "#" for unused, "*" for peg, "." for empty

    """

    def __init__(self, marker, marker_set):
        """
        Create a new GridPegSolitairePuzzle self with
        marker indicating pegs, spaces, and unused
        and marker_set indicating allowed markers.

        @type marker: list[list[str]]
        @type marker_set: set[str]
                          "#" for unused, "*" for peg, "." for empty
        """
        assert isinstance(marker, list)
        assert len(marker) > 0
        assert all([len(x) == len(marker[0]) for x in marker[1:]])
        assert all([all(x in marker_set for x in row) for row in marker])
        assert all([x == "*" or x == "." or x == "#" for x in marker_set])
        self._marker, self._marker_set = marker, marker_set

    # TODO
    # implement __eq__, __str__ methods
    # __repr__ is up to you
    def __eq__(self, other):
        """
        Return if GridPegSolitairePuzzle self is equivalent to other.

        @type self: GridPegSolitairePuzzle
        @type other: GridPegSolitairePuzzle | Any
        @rtype: bool

        >>> grid1 = [["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", ".", "*", "*"], \
            ["*", "*", "*", "*", "*"]]
        >>> gpsp1 = GridPegSolitairePuzzle(grid1, {"*", ".", "#"})
        >>> grid2 = [["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", ".", "*", "*"], \
            ["*", "*", "*", "*", "*"]]
        >>> gpsp2 = GridPegSolitairePuzzle(grid2, {"*", ".", "#"})
        >>> gpsp1.__eq__(gpsp2)
        True
        """
        return (isinstance(other, GridPegSolitairePuzzle) and
                self._marker == other._marker and
                self._marker_set == other._marker_set)

    def __str__(self):
        """
        Return a human-readable string representation of GridPegSolitairePuzzle self.

        @type: self: GridPegSolitairePuzzle
        @rtype: str

        >>> grid = [["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", ".", "*", "*"], \
            ["*", "*", "*", "*", "*"]]
        >>> gpsp = GridPegSolitairePuzzle(grid, {"*", ".", "#"})
        >>> print(gpsp)
        |*|*|*|*|*|
        |*|*|*|*|*|
        |*|*|*|*|*|
        |*|*|.|*|*|
        |*|*|*|*|*|
        """
        string = ''
        for row in self._marker:
            items = ''
            for item in row:
                items += item + '|'
            string += '|' + items + '\n'
        return string.rstrip()
        # TODO
        # override extensions
        # legal extensions consist of all configurations that can be reached by
        # making a single jump from this configuration

    @property
    def extensions(self):
        """
        Return list of extensions of GridPegSolitairePuzzle self.

        @type self: GridPegSolitairePuzzle
        @rtype: list[GridPegSolitairePuzzle]

        >>> grid = [["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", ".", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"]]
        >>> return_1 = [["*", "*", ".", "*", "*"], \
            ["*", "*", ".", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"]]
        >>> return_2 = [["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", ".", "."], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"]]
        >>> return_3 = [["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            [".", ".", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"]]
        >>> return_4 = [["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", ".", "*", "*"], \
            ["*", "*", ".", "*", "*"]]
        >>> r_1 = GridPegSolitairePuzzle(return_1, {"*", ".", "#"})
        >>> r_2 = GridPegSolitairePuzzle(return_2, {"*", ".", "#"})
        >>> r_3 = GridPegSolitairePuzzle(return_3, {"*", ".", "#"})
        >>> r_4 = GridPegSolitairePuzzle(return_4, {"*", ".", "#"})
        >>> gpsp1 = GridPegSolitairePuzzle(grid, {"*", ".", "#"})
        >>> extensions = gpsp1.extensions
        >>> (r_1 and r_2 and r_3 and r_4) in extensions  # four directions
        True
        >>> grid = [["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", ".", "*", "*"]]
        >>> gpsp2 = GridPegSolitairePuzzle(grid, {"*", ".", "#"})
        >>> return_5 = [["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", ".", "*", "*"], \
            ["*", "*", ".", "*", "*"], \
            ["*", "*", "*", "*", "*"]]
        >>> return_6 = [["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", ".", "."]]
        >>> return_7 = [["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            [".", ".", "*", "*", "*"]]
        >>> r_5, r_6, r_7 = (GridPegSolitairePuzzle(return_5, {"*", ".", "#"}),\
        GridPegSolitairePuzzle(return_6, {"*", ".", "#"}), \
        GridPegSolitairePuzzle(return_7, {"*", ".", "#"}))
        >>> r_5 and r_6 and r_7 in gpsp2.extensions # edge peg
        True
        >>> grid = [["#", "#", "#", "#", "#"], \
            ["#", "#", "#", "#", "#"], \
            ["#", "*", "*", "*", "#"], \
            ["#", ".", "*", "*", "#"], \
            ["#", "#", "#", "#", "#"]]
        >>> gpsp_3 = GridPegSolitairePuzzle(grid, {"*", ".", "#"})
        >>> return_8 = [["#", "#", "#", "#", "#"], \
            ["#", "#", "#", "#", "#"], \
            ["#", "*", "*", "*", "#"], \
            ["#", "*", ".", ".", "#"], \
            ["#", "#", "#", "#", "#"]]
        >>> r_8 = GridPegSolitairePuzzle(return_8, {"*", ".", "#"})
        >>> gpsp_3.extensions == [r_8]  # blanked out areas
        True
        """
        marker, marker_set = self._marker, self._marker_set
        steps = []
        peg = [x[:] for x in marker]
        for row in range(len(peg)):
            for column in range(len(peg[row])):
                if peg[row][column] == ".":
                    r, c = row, column
                    for move in VALID:
                        row_to, row_r, col_to, col_r = self.unpack(move, (r, r, c, c))
                        if self.inbounds(row_to, row_r, col_to, col_r):
                            new = [x[:] for x in marker]
                            new[row_to][col_to], new[row_r][col_r], new[r][c] = ".", ".", "*"
                            steps.append(GridPegSolitairePuzzle(new, marker_set))
        return steps
    # Helper functions

    @staticmethod
    def unpack(move, pos):
        """
        Return the new position after make change in the position of row and column in the
        pos according to the order inside the move

        @param move: tuple[tuple[int]]
        @param pos: tuple[int]
        @return: int, int, int, int
        """
        (row_to, row_r, col_to, col_r) = pos
        row_to += move[0][0]
        col_to += move[0][1]
        row_r += move[1][0]
        col_r += move[1][1]
        return row_to, row_r, col_to, col_r

    def inbounds(self, row_to, row_r, col_to, col_r):
        """
        Return True if both of the adjacent position, self._marker[row_r}[col_r] and the one next to the
        adjacent position, self._marker[row_to][row_r] are "*", otherwise return False
        @param row_to: int
        @param row_r: int
        @param col_to: int
        @param col_r: int
        @return: bool
        """
        if 0 <= row_to < len(self._marker) and 0 <= col_to < len(self._marker[0]):
            return self._marker[row_to][col_to] == "*" and self._marker[row_r][col_r] == "*"
        return False

    def is_solved(self):
        """
        Return True or False depending on if the GridPegSolitairePuzzle self is
        solved. True is if there is only one peg left on the board.

        @type self: GridPegSolitairePuzzle
        @rtype: bool

        >>> grid = [["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", "*", "*", "*"], \
            ["*", "*", ".", "*", "*"], \
            ["*", "*", "*", "*", "*"]]  # new puzzle
        >>> gpsp = GridPegSolitairePuzzle(grid, {"*", ".", "#"})
        >>> gpsp.is_solved()
        False
        >>> grid = [[".", ".", ".", ".", "."], \
            [".", ".", ".", ".", "."], \
            [".", ".", ".", ".", "."], \
            [".", ".", ".", "*", "."], \
            [".", ".", ".", ".", "."]]  # solved puzzle
        >>> gpsp = GridPegSolitairePuzzle(grid, {"*", ".", "#"})
        >>> gpsp.is_solved()
        True
        >>> grid = [[".", ".", ".", ".", "."], \
            [".", ".", ".", ".", "."], \
            [".", "*", ".", ".", "."], \
            [".", ".", ".", "*", "."], \
            [".", ".", ".", ".", "."]]  # impossible puzzle
        >>> gpsp = GridPegSolitairePuzzle(grid, {"*", ".", "#"})
        >>> gpsp.is_solved()
        False
        """
        peg = 0
        for row in self._marker:
            for element in row:
                if element == "*":
                    peg += 1
        return peg == 1
        # TODO
        # override is_solved
        # A configuration is solved when there is exactly one "*" left


if __name__ == "__main__":
    import doctest

    doctest.testmod()
    from puzzle_tools import depth_first_solve

    grid = [["*", "*", "*", "*", "*"],
            ["*", "*", "*", "*", "*"],
            ["*", "*", "*", "*", "*"],
            ["*", "*", ".", "*", "*"],
            ["*", "*", "*", "*", "*"]]
    gpsp = GridPegSolitairePuzzle(grid, {"*", ".", "#"})
    import time

    start = time.time()
    solution = depth_first_solve(gpsp)
    end = time.time()
    print("Solved 5x5 peg solitaire in {} seconds.".format(end - start))
    print("Using depth-first: \n{}".format(solution))
