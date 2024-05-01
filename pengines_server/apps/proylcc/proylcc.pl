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


%checkCluesMask(+GridStrcutureClues,+GridStrcuture,-isSatisfied).
%checkClues(X,Y,Sat):-checkClues(X,Y,Sat).

%
%checkClues(+GridStrcutureClues,+GridStrcuture,+CurrentGridStrcutureClue,-isSatisfied).
%
%checkClues(+GridStrcutureClues,+GridStrcuture,-isSatisfied).
%checkClues(X,Y,Sat):-checkClues(X,Y,_,-1,Sat).

%
%checkClues(+GridStrcutureClues,+GridStrcuture,+CurrentGridStrcutureClue,-isSatisfied).
%

%si se llega a este caso base significa que la estructura se corresponde con las pistas
%checkClues([],[],_L,0,1).
%casos para cuando se encontro un # y se empieza a veirficicar si se corresponde con las pistas
%checkClues(X,[E|R],_L,N,S):- E == "#", N>0, NewN is N-1, checkClues(X, R,E,NewN,S).
%checkClues(X,[E|R],_L,0,S):-E\=="#", checkClues(X,R,E,0,S).
%checkClues([X|Xr],[E|R],L,0,S):-E== "#",L\=="#", checkClues(Xr,[E|R],L,X,S).
%casos para cuando recien se comienza y todavia no se encontro con ningun #
%checkClues(X,[E|R],_L,-1,S):-E\=="#", checkClues(X,R,E,-1,S).
%checkClues([X|Xr],R,L,-1,S):- checkClues(Xr,R,L,X,S).
%caso para cuando ya se completaron todas las pistas
%checkClues([],[E|R],_L,0,S):-E\=="#", checkClues([],R,E,0,S).
%si alguno de esos casos falla, se llega a este que devuelve 0 (significa que no esta completo)
%checkClues(_X,_Y,_Z,_W,0).
%

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

%%getGrid no funciona,entra en un ciclo infinito, pero se tendria q poder hacer, REVISAR
completeRow(0,[]).
completeRow(L,[E|R]):-Nl is L-1, completeRow(Nl,R),(E="#";E="_").
completeGrid(_RL,0,[],[]).
completeGrid(RowLength,CantRows,[RC|RCs],[NR|G]):- completeRow(RowLength,NR), checkClues(RC,NR,S),S==1, NCC is CantRows - 1, completeGrid(RowLength,NCC, RCs,G).

% Predicado para generar todas las permutaciones posibles de una grilla de X por Y con elementos "X" y "#"
generate_grid_permutations(X, Y,RC, Grid) :-
    length(Grid, Y),                   % La longitud de la grilla debe ser Y
    generate_rows(X, Y,RC, Grid).         % Generar las filas de la grilla

% Generar las filas de la grilla
generate_rows(_, 0,[], []).              % Caso base: Cuando se han generado todas las filas
generate_rows(X, Y,[RC|RCs], [Row|RestRows]) :-
    Y > 0,                            % Asegurarse de que Y sea mayor que 0
    Y1 is Y - 1,                      % Decrementar Y en 1 para la siguiente fila
    length(Row, X),                   % La longitud de cada fila debe ser X
    generate_row(X, Row), 
	checkClues(RC,Row,Sat),
	Sat==1,            % Generar la fila
    generate_rows(X, Y1,RCs, RestRows).   % Generar las filas restantes

% Generar una fila con elementos "X" y "#"
generate_row(0, []).                  % Caso base: Cuando se han generado todos los elementos de la fila
generate_row(X, [Element|Rest]) :-
    X > 0,                            % Asegurarse de que X sea mayor que 0
    X1 is X - 1,                      % Decrementar X en 1 para el siguiente elemento
    (Element = "X" ; Element = "#"), % El elemento puede ser 'X' o '#'
    generate_row(X1, Rest).           % Generar los elementos restantes de la fila
generateTrueAnswer(X,Y,RC,CC,Grid):-generate_grid_permutations(X, Y,RC, Grid),checkWinner(0,Grid,[],CC,1).
getGrid(RC,CC, NG):-length(RC,I),completeGridMask(RC,CC,I,NG).


%%%%%%%%%%%%%%%%%
%%Testing stuff%%
%%%%%%%%%%%%%%%%%
%
%getGrid([[1],[2]],[[2],[1]],G).
%trace, put("#",[0,1],[[3], [1,2], [4], [5], [5]],[[2], [5], [1,3], [5], [4]],[["X","#","#","#","X"],["X","#","X","#","#"],["X","#","#","#","#"],["#","#","#","#","#"],["#","#","#","#","#"]],NG,Rs,Cs).
%
%checkWinner(0,[["X","#","#","#","X"],
%				["X","#","X","#","#"],
%				["X","#","#","#","#"],
%				["#","#","#","#","#"],
% 			 	["#","#","#","#","#"]],
% 				[[3], [1,2], [4], [5], [5]],
%				[[2], [5], [1,3], [5], [4]],
%				IsWinner).
%
%checkWinner(0,[["X","#","#","X","X"],["X","#","X","#","#"],["X","#","#","#","#"],["#","#","#","#","#"],["#","#","#","#","#"]],[[3], [1,2], [4], [5], [5]],[[2], [5], [1,3], [5], [4]],IsWinner).
