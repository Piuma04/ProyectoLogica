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



%searchClueIndex(+Index,+AllClueGridStructure,-IndexedClueGridStructure).
searchClueIndex(0,[X|_Xs],X).
searchClueIndex(Index,[_X|Xs],Elem):- Index > 0, NewIndex is Index-1, searchClueIndex(NewIndex,Xs,Elem).


%checkClues(+RowClues,+Row,+CurrentRowClue).

checkCluesMask(X,Y):-checkClues(X,Y,0).

checkClues([],[],0).
checkClues(X,["#"|R],N):- N>0, NewN is N-1, checkClues(X, R, NewN).

checkClues(X,[E|R],0):-E\="#", checkClues(X,R,0).

checkClues([X|Xr],R,0):-checkClues(Xr,R,X).

checkClues([],[E|R],0):-E\="#", checkClues([],R,0).

%searchColumn(+ColumnNumber,+Grid,-Column).
searchColumn(_ColN, [], []).
searchColumn(ColN,[X|Xs],[Y|Ys]):-searchClueIndex(ColN,X,Y),searchColumn(ColN,Xs,Ys).

%
% put(+Content, +Pos, +RowsClues, +ColsClues, +Grid, -NewGrid, -RowSat, -ColSat).
%
put(Content, [RowN, ColN], RowsClues, ColsClues, Grid, NewGrid, 1, 1):-
	
	replace(Row, RowN, NewRow, Grid, NewGrid),

	% NewRow is the result of replacing the cell Cell in position ColN of Row by _,
	% if Cell matches Content (Cell is instantiated in the call to replace/5).	
	% Otherwise (;)
	% NewRow is the result of replacing the cell in position ColN of Row by Content (no matter its content: _Cell).			
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)),
	
	%check if columns are correct
	searchColumn(ColN,NewGrid,NewColumn),
	searchClueIndex(ColN, ColsClues, ColsClueList),
	checkCluesMask(ColsClueList, NewColumn),
	
	%check if rows are correct
	searchClueIndex(RowN, RowsClues, RowsClueList),
	checkCluesMask(RowsClueList, NewRow).
put(Content, [RowN, ColN], RowsClues, _ColsClues, Grid, NewGrid, 1, 0):-
	
	replace(Row, RowN, NewRow, Grid, NewGrid),
	
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)),

	searchClueIndex(RowN, RowsClues, RowsClueList),
	checkCluesMask(RowsClueList, NewRow).

put(Content, [RowN, ColN], _RowsClues, ColsClues, Grid, NewGrid, 0, 1):-
   replace(Row, RowN, NewRow, Grid, NewGrid),
	
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)),

	searchColumn(ColN,NewGrid,NewColumn),
	searchClueIndex(ColN, ColsClues, ColsClueList),
	checkCluesMask(ColsClueList, NewColumn).


put(Content, [RowN, ColN], _RowsClues, _ColsClues, Grid, NewGrid, 0, 0):-
	% NewGrid is the result of replacing the row Row in position RowN of Grid by a new row NewRow (not yet instantiated).
	replace(Row, RowN, NewRow, Grid, NewGrid),

	% NewRow is the result of replacing the cell Cell in position ColN of Row by _,
	% if Cell matches Content (Cell is instantiated in the call to replace/5).	
	% Otherwise (;)
	% NewRow is the result of replacing the cell in position ColN of Row by Content (no matter its content: _Cell).			
	(replace(Cell, ColN,_, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)).

%calculateWinner(+Grid, +,-isWinner).
calculateWinner(_H,_G,_Rc,_Cc,0,1).
calculateWinner([Row|Xs], Grid,RowsClues, ColsClues,N,W):-

	searchColumn(N,Grid,NewColumn),
	searchClueIndex(N, ColsClues, ColsClueList),
	checkClues(ColsClueList, NewColumn,0),
	
	%check if rows are correct
	searchClueIndex(N, RowsClues, RowsClueList),
	checkClues(RowsClueList, Row,0),
	
	NewN is N-1,
	calculateWinner(Xs,Grid,RowsClues,ColsClues,NewN,W).




%put("#",[0,1],[[3], [1,2], [4], [5], [5]],[[2], [5], [1,3], [5], [4]],[["X","X","#","#","X"],["X","#","X","#","#"],["X","#","#","#","#"],["#","#","#","#","#"],["#","#","#","#","#"]],NG,Rs,Cs).

%calculateWinner([["X", _ , _ , _ , - ], ["X", _ ,"X", _ , _ ],["X", _ , _ , _ , _ ],["#","#","#", _ , _ ],[ _ , _ ,"#","#","#"]],[[3], [1,2], [4], [5], [5]],[[2], [5], [1,3], [5], [4]],4,W).
%calculateWinner([["X","#","#","#","X"],["X","#","X","#","#"],["X","#","#","#","#"],["#","#","#","#","#"],["#","#","#","#","#"]],[["X","#","#","#","X"],["X","#","X","#","#"],["X","#","#","#","#"],["#","#","#","#","#"],["#","#","#","#","#"]],[[3], [1,2], [4], [5], [5]],[[2], [5], [1,3], [5], [4]],4,W).