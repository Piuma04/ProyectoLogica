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

put(Content, [RowN, ColN], _RowsClues, _ColsClues, Grid, NewGrid, 1, 1):-
	
	put(Content, [RowN, ColN], _RowsClues, _ColsClues, Grid, NewGrid, 0, 1),

	put(Content, [RowN, ColN], _RowsClues, _ColsClues, Grid, NewGrid, 1, 0).

	
checkClue([0],[Y|Ys])
checkClue([X|Xs],[Y|Ys]):-

%searchRightRowList(3,[[1,2],[3],[4,5,6],[7],[8]],X).
searchRightRowList(0,[X|_Xs],X).
searchRightRowList(Index,[_X|Xs],Elem):- Index > 0, NewIndex is Index-1, searchRightRowList(NewIndex,Xs,Elem).

put(Content, [RowN, ColN], RowsClues, _ColsClues, Grid, NewGrid, 1, 0):-
	
	replace(Row, RowN, NewRow, Grid, NewGrid),
	
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)),

	searchRightRowList(RowN, RowClues, RowClueList),

	checkClue(newRow).	
	
put(Content, [RowN, ColN], _RowsClues, _ColsClues, Grid, NewGrid, 0, 1).

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


