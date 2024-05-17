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
%checkWinner(0,[["_","_"],["_","_"],["_","_"]],[[],[],[]],[[],[]],W)

checkWinner(Position,Grid,RowClues,ColumnClues,IsWinner):-

	

	obtainLineClue(ColumnClues,ColumnClue,RestColumnClues),
	checkWinnerCondInCol(Position, Grid, ColumnClue, RestColumnClues, ColSat),
	
	obtainLineClue(RowClues,RowClue,RestRowClues),
	checkWinnerCondInRow(Position, Grid, RowClue, RestRowClues,RowSat),

	RowSat == 1, ColSat == 1, NewPosition  is Position+1,
	checkWinner(NewPosition, Grid, RestRowClues, RestColumnClues, IsWinner).
%base failure case
checkWinner(_Position,_Grid,_RowClues,_ColumnClues,0).	

%obtainLineClue(+AllColumnClues, -ColumnClue, -RestColumnClues).
obtainLineClue([],[],[]).
obtainLineClue([ColumnClue|RestColumnClues],ColumnClue,RestColumnClues).

%checkWinnerCondInCol(+Position, +Grid, +ColumnClue, +ColumnLength, -ColSat)
checkWinnerCondInCol(_Position, _Grid, [], [], 1).
checkWinnerCondInCol(Position, Grid, ColumnClue, _ColumnClues,ColSat):-
	searchColumn(Position,Grid,NewColumn), 
	checkClues(ColumnClue, NewColumn,ColSat).

%checkWinnerCondInRow(+Position, +Grid, +RowClue, +RowLength, -RowSat)
checkWinnerCondInRow(_Position, _Grid, [],[], 1).
checkWinnerCondInRow(Position, Grid, RowClue,_RowClues, RowSat):-
	searchIndex(Position,Grid,NewRow),
	checkClues(RowClue, NewRow,RowSat).












%%
%
%Aca esta todo lo que completa el tablero
%
%%
% Predicado para generar todas las permutaciones posibles de una grilla de X por Y con elementos "X" y "#"
generate_grid_permutations(_CantRow, CantCol,RC, Grid) :-
	% La longitud de la grilla debe ser Y
generate_rows(CantCol, CantCol,RC, Grid).         % Generar las filas de la grilla

% Generar las filas de la grilla
generate_rows(_, 0,[], []).              % Caso base: Cuando se han generado todas las filas
generate_rows(CantRow, CantCol,[RC|RCs], [Row|RestRows]) :-
CantCol > 0,                            % Asegurarse de que Y sea mayor que 0
NewCantCol is CantCol - 1,                      % Decrementar Y en 1 para la siguiente fila
length(Row, CantRow),                   % La longitud de cada fila debe ser X
fillClues(RC, CantRow,Row), 

  % Generar la fila
generate_rows(CantRow, NewCantCol,RCs, RestRows).   % Generar las filas restantes


fillClues([],_X,_Y).
fillClues([Clue|Clues],Length,PossibleLine):-
sumElems([Clue|Clues],Sum),
Blanks is Length-Sum,
fillCluesAux([Clue|Clues],Blanks,PossibleLine).
fillCluesAux([],0,[]).
fillCluesAux([Clue|Clues],Blanks,God):-
fillFollowing(Clue,"#",Linea),
append(Linea,Bs,God),
fillCluesAux(Clues,Blanks,Bs),
( Bs =["X"|_];Bs =[]).
fillCluesAux(Clues,Blanks,["X"|Bs]):-
Blanks>0,
NewBlanks is Blanks-1,
fillCluesAux(Clues,NewBlanks,Bs).
sumElems([],0).
sumElems([Clue|Clues],ClueSum):-sumElems(Clues,PastSum),ClueSum is PastSum + Clue.
fillFollowing(0,_Symbol,[]).
fillFollowing(Cant,Symbol,[Symbol|Elems]):-Cant>=0,NewCant is Cant-1,fillFollowing(NewCant,Symbol,Elems).
checkColumns(_Position,_Grid,[],[],1).
checkColumns(Position,Grid,[],[ColumnClue|ColumnClues],IsWinner):-

searchColumn(Position,Grid,NewColumn),
checkClues(ColumnClue, NewColumn,ColSat),


ColSat == 1, NewPosition  = Position+1,
checkColumns(NewPosition, Grid, [], ColumnClues, IsWinner).

checkColumns(_Position,_Grid,_RowClues,_ColumnClues,0).	
generateTrueAnswer(CantRow,CantCol,RC,CC,Grid):-generate_grid_permutations(CantRow, CantCol,RC, Grid),checkColumns(0,Grid,[],CC,1).








%aca se ponen los nuevos niveles

level1(
    [[7], [2,2], [2,2], [2],[3],[4],[2],[],[2],[2]],% RowsClues
    
    [[3], [3], [1], [1,2,2],[1,2,2],[1,2],[6],[4]],% ColsClues
    
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
level2(
    [[8], [2,2], [2,2], [2],[3],[4],[2],[],[2],[2]],% RowsClues
    
    [[3], [3], [1], [1,2,2],[1,2,2],[1,2],[6],[5]],% ColsClues
    
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
piuma(0).