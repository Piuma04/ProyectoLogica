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



%searchIndex(+Index,+AllClueGridStructure,-IndexedClueGridStructure).
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


checkClues([],[],1).
checkClues(Clue,[X|Xs],S):-X\=="#",checkClues(Clue,Xs,S).
checkClues([X|Xs],List,S):-checkFollowing(X,List,[R|Rs]),R\=="#",checkClues(Xs,[R|Rs],S).
checkClues([X|Xs],List,S):-checkFollowing(X,List,[]),checkClues(Xs,[],S).
checkClues(_Clue,_List,0).

checkFollowing(0,Residual,Residual).
checkFollowing(Cant,[Y|Ys],Residual):-Y=="#",NewCant is Cant-1,checkFollowing(NewCant,Ys,Residual).

%searchColumn(+ColumnNumber,+Grid,-Column).
searchColumn(_ColN, [], []).
searchColumn(ColN,[X|Xs],[Y|Ys]):-searchIndex(ColN,X,Y),searchColumn(ColN,Xs,Ys).

markInicialClues(G,RowsClues,ColsClues,Res):-markInicialCluesAux(0,G,RowsClues,ColsClues,Res).
markInicialCluesAux(_P, _G, [], [], [[],[]]).
markInicialCluesAux(P, G, [RC|RCs], [CC|CCs], [[RS|RSs],[CS|CSs]]) :-
    searchColumn(P, G, Column),
	searchIndex(P, G, Row),
    checkClues(CC, Column, CS),
    checkClues(RC, Row, RS),
	NewP is P + 1,
    markInicialCluesAux(NewP, G, RCs, CCs, [RSs,CSs]).
%if there are more columns than rows
markInicialCluesAux(P, G, [], [CC|CCs], [[0|RSs],[CS|CSs]]):-
	searchColumn(P, G, Column),
    checkClues(CC, Column, CS),
	NewP is P + 1,
    markInicialCluesAux(NewP, G, [], CCs, [RSs,CSs]).
%if there are more rows than columns
markInicialCluesAux(P, G, [RC|RCs], [], [[RS|RSs],[0|CSs]]):-
	searchIndex(P, G, Row),
    checkClues(RC, Row, RS),
	NewP is P + 1,
    markInicialCluesAux(NewP, G, RCs, [], [RSs,CSs]).
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
%base succes case
checkWinner(_P,_G,[],[],1).
%if there are more columns than rows
checkWinner(P,G,[],[CC|CCs],W):-

	searchColumn(P,G,NewColumn),
	checkClues(CC, NewColumn,ColSat),
	

	ColSat == 1, NewP  = P+1,
	checkWinner(NewP, G, [], CCs, W).
%if there are more rows than columns
checkWinner(P,G,[RC|RCs],[],W):-
	
	searchIndex(P,G,NewRow),
	checkClues(RC, NewRow,RowSat),

	RowSat == 1, NewP  = P+1,
	checkWinner(NewP, G, RCs, [], W).

checkWinner(P,G,[RC|RCs],[CC|CCs],W):-

	searchColumn(P,G,NewColumn),
	checkClues(CC, NewColumn,ColSat),
	
	searchIndex(P,G,NewRow),
	checkClues(RC, NewRow,RowSat),

	RowSat == 1, ColSat == 1, NewP  = P+1,
	checkWinner(NewP, G, RCs, CCs, W).
	
checkWinner(_P,_G,_R,_C,0).	

%%getGrid no funciona,entra en un ciclo infinito, pero se tendria q poder hacer, REVISAR
completeRow(0,[]).
completeRow(L,[E|R]):-Nl is L-1, completeRow(Nl,R),(E="#";E="_").

completeGrid(_RL,0,[],[]).
completeGrid(RowLength,CantRows,[RC|RCs],[NR|G]):- completeRow(RowLength,NR), checkClues(RC,NR,S),S==1, NCC is CantRows - 1, completeGrid(RowLength,NCC, RCs,G).


completeGridMask(RC,CC,I,NG):-H is I, completeGrid(I,H,RC,NG),checkWinner(0,NG,RC,CC,W),W == 1.

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
