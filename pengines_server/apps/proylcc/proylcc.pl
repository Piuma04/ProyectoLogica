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



%searchClueIndex(+Index,+AllClueGridStructure,-IndexedClueGridStructure).
searchClueIndex(0,[X|_Xs],X).
searchClueIndex(Index,[_X|Xs],Elem):- Index > 0, NewIndex is Index-1, searchClueIndex(NewIndex,Xs,Elem).


%checkCluesMask(+GridStrcutureClues,+GridStrcuture,-isSatisfied).
checkCluesMask(X,Y,Sat):-checkClues(X,Y,_,-1,Sat).

%checkClues(+GridStrcutureClues,+GridStrcuture,+CurrentGridStrcutureClue,-isSatisfied).
checkClues([],[],L,0,1).

checkClues(X,[E|R],_L,N,S):- E == "#", N>0, NewN is N-1, checkClues(X, R,E,NewN,S).
checkClues(X,[E|R],_L,0,S):-E\=="#", checkClues(X,R,E,0,S).
checkClues([X|Xr],[E|R],L,0,S):-E== "#",L\=="#", checkClues(Xr,[E|R],L,X,S).


checkClues(X,[E|R],_L,-1,S):-E\=="#", checkClues(X,R,E,-1,S).
checkClues([X|Xr],R,L,-1,S):- checkClues(Xr,R,L,X,S).

checkClues([],[E|R],_L,0,S):-E\=="#", checkClues([],R,E,0,S).
checkClues(_X,_Y,_Z,_W,0).

%searchColumn(+ColumnNumber,+Grid,-Column).
searchColumn(_ColN, [], []).
searchColumn(ColN,[X|Xs],[Y|Ys]):-searchClueIndex(ColN,X,Y),searchColumn(ColN,Xs,Ys).


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
	searchClueIndex(ColN, ColsClues, ColsClueList),
	checkCluesMask(ColsClueList, NewColumn,ColSat),
	
	%check if rows are correct
	searchClueIndex(RowN, RowsClues, RowsClueList),
	checkCluesMask(RowsClueList, NewRow,RowSat).

%checkWinner(+Position, +Grid, +AllRowClues, +AllColumnClues, -isWinner).                              

checkWinner(P,G,[],[],1).
checkWinner(P,G,[RC|RCs],[CC|CCs],W):-

	searchColumn(P,G,NewColumn),
	checkCluesMask(CC, NewColumn,ColSat),
	
	searchClueIndex(P,G,NewRow),
	checkCluesMask(RC, NewRow,RowSat),

	RowSat == 1, ColSat == 1, NewP  = P+1,
	checkWinner(NewP, G, RCs, CCs, W).
	
checkWinner(P,G,R,C,0).	


%%%%%%%%%%%%%%%%%
%%Testing stuff%%
%%%%%%%%%%%%%%%%%
%
%trace, put("#",[0,1],[[3], [1,2], [4], [5], [5]],[[2], [5], [1,3], [5], [4]],[["X","#","#","#","X"],["X","#","X","#","#"],["X","#","#","#","#"],["#","#","#","#","#"],["#","#","#","#","#"]],NG,Rs,Cs).
%
%checkWinner(0,[["X","#","#","#","X"],
%				["X","#","X","#","#"],
%				["X","#","#","#","#"],
%				["#","#","#","#","#"],
%           	["#","#","#","#","#"]],
% 				[[3], [1,2], [4], [5], [5]],
%				[[2], [5], [1,3], [5], [4]],
%				IsWinner).
%
%checkWinner(0,[["X","#","#","X","X"],["X","#","X","#","#"],["X","#","#","#","#"],["#","#","#","#","#"],["#","#","#","#","#"]],[[3], [1,2], [4], [5], [5]],[[2], [5], [1,3], [5], [4]],IsWinner).
