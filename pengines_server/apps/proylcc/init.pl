:- module(init, [ init/3 ]).

/**
 * init(-RowsClues, -ColsClues, Grid).
 * Predicate specifying the initial grid, which will be shown at the beginning of the game,
 * including the rows and columns clues.
 */

init(
[[3], [1,2], [3], [5], [5]],	% RowsClues

[[3], [5], [1,3], [2,2], [1,2]], 	% ColsClues

[
[_,_,_,_,_], 		
[_,_,_,_,_],
[_,_,_,_,_],		
[_,_,_,_,_],
[_,_,_,_,_]

]
).

 %["X","X","#","#","X"], 		
 %["X","#","X","#","#"],
 %["X","#","#","#","#"],		
 %["#","#","#","#","#"],
 %["#","#","#","#","#"]
 