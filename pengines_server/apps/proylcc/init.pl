:- module(init, [ init/3 ]).

/**
 * init(-RowsClues, -ColsClues, Grid).
 * Predicate specifying the initial grid, which will be shown at the beginning of the game,
 * including the rows and columns clues.
 */

init(
[[2], [2], [2], [2],[2],[2],[2],[],[2],[2]],% RowsClues

[[], [], [], [7,2],[7,2],[],[],[]],% ColsClues

[
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_]
]
).