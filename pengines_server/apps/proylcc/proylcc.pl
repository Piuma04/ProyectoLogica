:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
% XsY is the result of replacing the occurrence of X in position XIndex of Xs by Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Content, +Pos, +RowsClues, +ColsClues, +Grid, -NewGrid, -RowSat, -ColSat).
%
searchClueIndex(0,[X|_Xs],X).
searchClueIndex(Index,[_X|Xs],Elem):- Index > 0, NewIndex is Index-1, searchClueIndex(NewIndex,Xs,Elem).
%checkClues(+RowClues,+Row,+CurrentRowClue).
checkClues([],[],0).

checkClues(X,["#"|R],N):- N>0, NewN is N-1, checkClues(X, R, NewN).
checkClues(X,[E|R],0):-E\="#", checkClues(X,R,0).

checkClues([X|Xr],R,0):-checkClues(Xr,R,X).
checkClues([],[E|R],0):-E\="#", checkClues([],R,0).

searchColumn(_ColN, [], []).
searchColumn(ColN,[X|Xs],[Y|Ys]):-searchClueIndex(ColN,X,Y),searchColumn(ColN,Xs,Ys).

put(Content, [RowN, ColN], _RowsClues, _ColsClues, Grid, NewGrid, 0, 0):-
	% NewGrid is the result of replacing the row Row in position RowN of Grid by a new row NewRow (not yet instantiated).
	replace(Row, RowN, NewRow, Grid, NewGrid),

	% NewRow is the result of replacing the cell Cell in position ColN of Row by _,
	% if Cell matches Content (Cell is instantiated in the call to replace/5).	
	% Otherwise (;)
	% NewRow is the result of replacing the cell in position ColN of Row by Content (no matter its content: _Cell).			
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)).
put(Content, [RowN, ColN], RowsClues, _ColsClues, Grid, NewGrid, 1, 0):-
	
	replace(Row, RowN, NewRow, Grid, NewGrid),
	
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)),

	searchClueIndex(RowN, RowsClues, RowsClueList),
	checkClues(RowsClueList, NewRow,0).
put(Content, [RowN, ColN], _RowsClues, ColsClues, Grid, NewGrid, 0, 1):-
replace(Row, RowN, NewRow, Grid, NewGrid),
	
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)),
	searchColumn(ColN,NewGrid,NewColumn),
	searchClueIndex(ColN, ColsClues, ColsClueList),
	checkClues(ColsClueList, NewColumn,0).
put(Content, [RowN, ColN], RowsClues, ColsClues, Grid, NewGrid, 1, 1):-
	
	put(Content, [RowN, ColN], RowsClues, ColsClues, Grid, NewGrid, 0, 1),

	put(Content, [RowN, ColN], RowsClues, ColsClues, Grid, NewGrid, 1, 0).