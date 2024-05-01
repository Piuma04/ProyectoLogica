:- module(init, [ init/3 ]).

/**
 * init(-RowsClues, -ColsClues, Grid).
 * Predicate specifying the initial grid, which will be shown at the beginning of the game,
 * including the rows and columns clues.
 */

init(
[[6], [2,2], [2,2], [2],[3],[4],[2],[],[2],[2]],% RowsClues

[[2], [3], [1], [1,2,2],[1,2,2],[1,2],[6],[4]],% ColsClues

[
[_,_,_,_,_,_,"#",_],
["#","#",_,_,_,_,_,_],
[_,_,_,_,_,_,_,"#"],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,"#",_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,"#",_,_,_,_]
]
).