:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

%searchIndex(+Index,+List,-IndexedElement). Searches indexed element in list.
searchIndex(0,[X|_Xs],X).
searchIndex(Index,[_X|Xs],Elem):- Index > 0, NewIndex is Index-1, searchIndex(NewIndex,Xs,Elem).

%checkClues(+Clues,+Line,-SatisfiesClues). Given a clue and a line, specifies whether the clues are satisfied or not.
checkClues([],[],1).
checkClues(Clue,[Elem|Elems],Sat):-Elem\=="#",checkClues(Clue,Elems,Sat).
checkClues([Clue|Clues],Line,Sat):-checkFollowing(Clue,Line,[R|Rs]),R\=="#",checkClues(Clues,[R|Rs],Sat).
checkClues([Clue|Clues],Line,Sat):-checkFollowing(Clue,Line,[]),checkClues(Clues,[],Sat).
checkClues(_Clue,_List,0).

%checkFollowing(+CantOfFollowing#,+Line,-Residual). Given an amount of following # and a line, specifies the line without the inicial #.
checkFollowing(0,Residual,Residual).
checkFollowing(Cant,[Elem|Elems],Residual):-Elem=="#",NewCant is Cant-1,checkFollowing(NewCant,Elems,Residual).

%searchColumn(+ColumnIndex,+Grid,-Column). Given a column index and a grid, specifies the indexed column from the grid.
searchColumn(_ColI, [], []).
searchColumn(ColI,[Row|Rows],[Elem|Elems]):-searchIndex(ColI,Row,Elem),searchColumn(ColI,Rows,Elems).

%markInicialClues(+Grid,+AllRowsClues,+AllColsClues,-RowsAndColsSatisfied). Given a grid and all clues, specifies a list of two lists which include the corresponding row and col satisfactions.
markInicialClues(Grid,RowsClues,ColsClues,RowsAndColsSatisfied):-markInicialCluesAux(0,Grid,RowsClues,ColsClues,RowsAndColsSatisfied).

%markInicialCluesAux(+Position,+Grid,+AllRowsClues,+AllColsClues,-RowsAndColsSatisfied)
markInicialCluesAux(_Position, _Grid, [], [], [[],[]]).
markInicialCluesAux(Position, Grid, [RowClue|RowClues], [ColClue|ColClues], [[RowSat|RowSats],[ColSat|ColSats]]) :-
    searchColumn(Position, Grid, Column),
	searchIndex(Position, Grid, Row),
    checkClues(ColClue, Column, ColSat),
    checkClues(RowClue, Row, RowSat),
	NewPosition is Position + 1,
    markInicialCluesAux(NewPosition, Grid, RowClues, ColClues, [RowSats,ColSats]).
%if there are more columns than rows
markInicialCluesAux(Position, Grid, [], [ColClue|ColClues], [RowSats,[ColSat|ColSats]]):-
	searchColumn(Position, Grid, Column),
    checkClues(ColClue, Column, ColSat),
	NewPosition is Position + 1,
    markInicialCluesAux(NewPosition, Grid, [], ColClues, [RowSats,ColSats]).
%if there are more rows than columns
markInicialCluesAux(Position, Grid, [RowClue|RowClues], [], [[RowSat|RowSats],ColSats]):-
	searchIndex(Position, Grid, Row),
    checkClues(RowClue, Row, RowSat),
	NewPosition is Position + 1,
    markInicialCluesAux(NewPosition, Grid, RowClues, [], [RowSats,ColSats]).
%
% put(+Content, +Pos, +RowsClues, +ColsClues, +Grid, -NewGrid, -RowSat, -ColSat).
%
put(Content, [RowN, ColN], RowsClues, ColsClues, Grid, NewGrid, RowSat, ColSat):-
	replace(Row, RowN, NewRow, Grid, NewGrid),	
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(Cell, ColN, Content, Row, NewRow),
        Cell \== Content),
	%check if columns are correct
	searchColumn(ColN,NewGrid,NewColumn),
	searchIndex(ColN, ColsClues, ColsClueList),
	checkClues(ColsClueList, NewColumn,ColSat),
	
	%check if rows are correct
	searchIndex(RowN, RowsClues, RowsClueList),
	checkClues(RowsClueList, NewRow,RowSat).

%checkWinner(+Position, +Grid, +AllRowClues, +AllColumnClues, -isWinner).                              
%base success case
checkWinner(_Position,_Grid,[],[],1).
%if there are more columns than rows
checkWinner(Position,Grid,[],[ColumnClue|ColumnClues],IsWinner):-

	searchColumn(Position,Grid,NewColumn),
	checkClues(ColumnClue, NewColumn,ColSat),
	

	ColSat == 1, NewPosition  = Position+1,
	checkWinner(NewPosition, Grid, [], ColumnClues, IsWinner).
%if there are more rows than columns
checkWinner(Position,Grid,[RowClue|RowClues],[],IsWinner):-
	
	searchIndex(Position,Grid,NewRow),
	checkClues(RowClue, NewRow,RowSat),

	RowSat == 1, NewPosition  = Position+1,
	checkWinner(NewPosition, Grid, RowClues, [], IsWinner).

checkWinner(Position,Grid,[RowClue|RowClues],[ColumnClue|ColumnClues],IsWinner):-

	searchColumn(Position,Grid,NewColumn),
	checkClues(ColumnClue, NewColumn,ColSat),
	
	searchIndex(Position,Grid,NewRow),
	checkClues(RowClue, NewRow,RowSat),

	RowSat == 1, ColSat == 1, NewPosition  = Position+1,
	checkWinner(NewPosition, Grid, RowClues, ColumnClues, IsWinner).
%base failure case
checkWinner(_Position,_Grid,_RowClues,_ColumnClues,0).	