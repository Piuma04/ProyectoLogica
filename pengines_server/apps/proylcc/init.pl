:- module(init, [ init/3 ]).

/**
 * init(-RowsClues, -ColsClues, Grid).
 * Predicate specifying the initial grid, which will be shown at the beginning of the game,
 * including the rows and columns clues.
 */

init(
[[2], [3], [2,1], [3],[2]],% RowsClues

[[1,1], [5], [3], [1,1],[1]],% ColsClues

[
[_,_,_,_,_],
[_,_,_,"#",_],
[_,_,_,"X",_],
["X",_,_,_,_],
[_,"#",_,_,_]
]
).