:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).
:-use_module(library(clpfd)).

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

%generateGridWithHint(+Pos, +RowsClues, +ColsClues, +Grid, +SolvedGrid, -NewGrid, -RowSat, -ColSat).

generateGridWithHint([RowN, ColN], RowsClues, ColsClues, Grid, SolvedGrid, NewGrid, RowSat, ColSat):-

	searchIndex(RowN, SolvedGrid, RowObj),
	searchIndex(ColN, RowObj, Replacement),
	
	replace(Row, RowN, NewRow, Grid, NewGrid),	
	replace(_Cell, ColN, Replacement, Row, NewRow),

	searchColumn(ColN,NewGrid,NewColumn),
	searchIndex(ColN, ColsClues, ColsClueList),
	checkClues(ColsClueList, NewColumn,ColSat),
	
	%check if rows are correct
	searchIndex(RowN, RowsClues, RowsClueList),
	checkClues(RowsClueList, NewRow,RowSat).

%checkWinner(+Position, +Grid, +AllRowClues, +AllColumnClues, -isWinner).                              
%base success case
checkWinner(_Position,_Grid,[],[],1).

checkWinner(Position,Grid,RowClues,ColumnClues,IsWinner):-
	obtainLineClue(ColumnClues,ColumnClue,RestColumnClues),
	checkWinnerCondInCol(Position, Grid, ColumnClue, RestColumnClues),
	
	obtainLineClue(RowClues,RowClue,RestRowClues),
	checkWinnerCondInRow(Position, Grid, RowClue, RestRowClues),

	NewPosition  is Position+1,
	checkWinner(NewPosition, Grid, RestRowClues, RestColumnClues, IsWinner).
%base failure case
checkWinner(_Position,_Grid,_RowClues,_ColumnClues,0).	

%obtainLineClue(+AllColumnClues, -ColumnClue, -RestColumnClues).
obtainLineClue([],[],[]).
obtainLineClue([ColumnClue|RestColumnClues],ColumnClue,RestColumnClues).

%checkWinnerCondInCol(+Position, +Grid, +ColumnClue, +ColumnLength, -ColSat)
checkWinnerCondInCol(_Position, _Grid, [], []).
checkWinnerCondInCol(Position, Grid, ColumnClue, _ColumnClues):-
	searchColumn(Position,Grid,NewColumn), 
	checkClues(ColumnClue, NewColumn,1).

%checkWinnerCondInRow(+Position, +Grid, +RowClue, +RowLength, -RowSat)
checkWinnerCondInRow(_Position, _Grid, [],[]).
checkWinnerCondInRow(Position, Grid, RowClue,_RowClues):-
	searchIndex(Position,Grid,NewRow),
	checkClues(RowClue, NewRow,1).

%Complete Grid

%fillClues(+Clue,+PartialLine,-PossibleLine).
fillClues([],PartialLine,PossibleLine):-
	fillClues([0],PartialLine,PossibleLine).
fillClues([Clue|Clues],PartialLine,PossibleLine):-
	copy_term(PartialLine, PossibleLine),
	sumNumbers([Clue|Clues],Sum),
	length(PossibleLine, Length),
	Blanks is Length-Sum,
	fillCluesAux([Clue|Clues],Blanks,PossibleLine).			

%fillCluesAux(+Clue,+Blanks,-PossibleLine).
fillCluesAux([],0,[]).
fillCluesAux([Clue|Clues],Blanks,PossibleLine):-
	fillFollowing(Clue,"#",FilledLine),
	append(FilledLine,Rest,PossibleLine),
	fillCluesAux(Clues,Blanks,Rest),
	( Rest =["X"|_];Rest =[]).
fillCluesAux(Clues,Blanks,["X"|Rest]):-
	Blanks>0,
	NewBlanks is Blanks-1,
	fillCluesAux(Clues,NewBlanks,Rest).

%sumNumbers(+Numbers,-Sum).
sumNumbers([],0).
sumNumbers([N|Ns],Sum):-
	sumNumbers(Ns,PastSum),Sum is PastSum + N.

%fillFollowing(+Cant,+Symbol,-FilledLine).
fillFollowing(0,_Symbol,[]).
fillFollowing(Cant,Symbol,[Symbol|Elems]):-Cant>=0,NewCant is Cant-1,fillFollowing(NewCant,Symbol,Elems).

%findCoincidences(+Clues,+PartialLine,-Coincidences).
findCoincidences(Clues,PartialLine,Coincidences):-
	findall(PossibleLine, fillClues(Clues, PartialLine, PossibleLine), PossibleLines),
	transpose(PossibleLines,T),
	findCoincidencesAux(T,Coincidences).

%findCoincidencesAux(+PossibleLinesT,-Coincidences).
findCoincidencesAux([],[]).
findCoincidencesAux([T|Ts],["#"|Is]):-
	forall(member(X,T),X=="#"),!,
	findCoincidencesAux(Ts,Is).
findCoincidencesAux([T|Ts],["X"|Is]):-
	forall(member(X,T),X=="X"),!,
	findCoincidencesAux(Ts,Is).
findCoincidencesAux([_T|Ts],[_|Is]):-
	findCoincidencesAux(Ts,Is).

%fillColumns(+ColumnClues,+Grid,-FilledColumns).
fillColumns(ColumnClues,Grid,FilledC):-
	transpose(Grid, GT),
	fillRows(ColumnClues,GT,FilledCT),
	transpose(FilledCT,FilledC).

%fillColumns(+RowClues,+Grid,-FilledRows).
fillRows([],[],[]).
fillRows([RC|RCs],[R|Rs],[FilledR|FilledRs]):-
	findCoincidences(RC,R,FilledR),
	fillRows(RCs,Rs,FilledRs).

%solve(+Grid,+RowClues,+ColumnClues,-SolvedGrid).
solve(Grid,RowClues,ColumnClues,SolvedGrid):-
	advanceGrid(Grid,RowClues,ColumnClues,AdvancedGrid),
	solveAux(AdvancedGrid,RowClues,ColumnClues,SolvedGrid).

%solveAux(+Grid,+RowClues,+ColumnClues,-SolvedGrid).
solveAux(Grid,_RowClues,ColumnClues,Grid):-
	forall(member(Row,Grid),isFinished(Row)),!,
	checkColumns(0,Grid,[],ColumnClues,1).
solveAux(Grid,RowClues,ColumnClues,SolvedGrid):-
	fillUnfinished(Grid,RowClues,RanGrid),
	solve(RanGrid,RowClues,ColumnClues,SolvedGrid).

%advanceGrid(+Grid,+RowClues,+ColumnClues,-AdvancedGrid)
advanceGrid(Grid,RowClues,ColumnClues,AdvancedGrid):-
	fillColumns(ColumnClues,Grid,PartialRows),
	fillRows(RowClues,PartialRows,PartialGrid),
	countElements(Grid,N),
	countElements(PartialGrid,NN),
	N=\=NN,!,
	advanceGrid(PartialGrid,RowClues,ColumnClues,AdvancedGrid).
advanceGrid(Grid,_RowClues,_ColumnClues,AdvancedGrid):-copy_term(Grid, AdvancedGrid).

%countElements(+Elems,-Sum).
countElements([],0).
countElements([E|Es],Sum):-countElements(Es,LastSum),findall(X, (member(X, E),(X=="#";X=="X")), Sumable),length(Sumable, SumX),Sum is SumX+LastSum.


%checkColumns(+Position,+Grid,+RowClues,+ColumnsClues,IsWinner).
checkColumns(_Position,_Grid,[],[],1).
checkColumns(Position,Grid,[],[ColumnClue|ColumnClues],IsWinner):-
	searchColumn(Position,Grid,NewColumn),
	checkClues(ColumnClue, NewColumn,ColSat),
	ColSat == 1, NewPosition  = Position+1,
	checkColumns(NewPosition, Grid, [], ColumnClues, IsWinner).
checkColumns(_Position,_Grid,_RowClues,_ColumnClues,0).	

%fillUnfinished(+Grid,+RowClues,-RanGrid)
fillUnfinished([],[],[]).
fillUnfinished([Row|Rows],[_RC|RCs],[CRow|NRows]):-copy_term(Row, CRow),isFinished(Row),!,fillUnfinished(Rows,RCs,NRows).
fillUnfinished([Row|Rows],[RC|RCs],[NRow|NRows]):-fillClues(RC,Row,NRow),fillUnfinishedAux(Rows,RCs,NRows).
fillUnfinishedAux([],[],[]).
fillUnfinishedAux([Row|Rows],[_RC|RCs],[CRow|NRows]):-copy_term(Row, CRow),fillUnfinishedAux(Rows,RCs,NRows).

%isFinished(+Line).
isFinished([]).
isFinished([Elem|Elems]):-Elem\='_',isFinished(Elems).

%levelX(-RowsClues, -ColsClues, Grid).
% X hace referencia al numero
level1(
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

level2(
    [[1], [1,1], [1,1], [4,1,1,4],[1,1,1,1],[1,1],[1,1],[1,3,1],[1,1,1,1],[3,3]],% RowsClues
    
    [[1], [2,2], [1,1,1,1], [1,1,1],[1,1],[1,2,1],[1,1],[1,2,1],[1,1],[1,1,1],[1,1,1,1],[2,2],[1]],% ColsClues
    
	[
		[_,_, _, _, _, _, "#", _, _, _, _, _, _],
        [_,_, _, _, _, "#", _, "#", _, _, _, _, _],
        [_,_, "X", _, _, _, _, _, _, _, _, _, _],
        [_,_, _, _, _, _, _, _, _, _, _, _, "#"],
        [_,"#", _, _, _, _, _, _, _, _, _, "#", _],
        [_,_, _, _, _, _, _, _, _, _, "#", _, _],
        [_,_, _, "#", _, _, _, "X", _, _, _, _, _],
        [_,_, _, _, _, _,_,_, _, _, _, _, _],
        [_,_, _, _, "#", _, "X", _, _, _, _, "#", _],
        ["X",_, "#", _, _, _, "X", _, _, _,_,_, _]
		]
    ).

level3(
    [[6],[6,2],[1,4,1],[1,6,1],[1,2,2,1],[4,6],[4,2,2],[1,2,1,1],[1,2,2,1],[1,9,2],[1,14],[3,1,1,3],[1,1,1,1],[1,1],[1,1],[8]], % PistasFilas
    [[6],[4,1],[1,3,4],[1,8,1],[1,2,3,1],[4,2,1],[4,4,1],[4,2,1],[4,2,1],[1,2,5,1],[1,7,1],[1,2,2,1],[1,1,2,1],[1,1,4],[4,3],[6]], % PistasColumnas
    [
    ["X",_,_,_,_,"#","#","#","#","#","#",_,"X",_,_,"X"],
    [_,_,_,_,_,_,_,_,_,_,_,"#","#",_,_,_],
    [_,_,_,_,_,_,_,_,_,_,_,_,"X","#",_,_],
    [_,_,_,_,_,_,_,_,_,_,_,_,_,_,"#",_],
    [_,_,_,_,_,_,_,_,_,_,_,_,_,_,"#",_],
    [_,_,_,_,_,_,_,"X","X",_,_,_,_,_,_,_],
    [_,_,_,_,"X",_,_,"X","X",_,_,_,_,_,_,_],
    [_,_,_,_,_,_,_,"X","X",_,_,_,_,_,_,_],
    ["#",_,_,_,_,_,_,_,_,_,_,_,"X","X",_,_],
    ["#","X",_,_,_,_,_,_,_,_,_,_,_,"X",_,_],
    ["#",_,_,_,_,_,_,_,_,"#","#","#",_,_,_,_],
    [_,_,_,_,_,_,_,_,_,"#",_,_,"#","#","#",_],
    [_,"X",_,_,_,_,_,_,_,_,_,_,"X","#","X","X"],
    [_,_,_,_,_,_,_,_,_,_,_,_,"X","#",_,_],
    [_,_,_,_,_,_,_,_,_,_,_,_,"#",_,_,_],
    ["X","X",_,_,_,_,"#","#","#","#","#","#",_,_,"X","X"]
    ]
    ).

level4(
	
	[[5],[7],[9],[2,1,2],[3,3],[1,1,1,1,1,1],[2,2,2,2],[1,1],[1,1],[2,2],[3,1],[5,1],[5,2],[8],[2,1,2]],
	[[2],[1,1],[5],[2,1],[2,1,1,2],[3,2,1,4],[3,4],[4,5],[3,4],[3,1,1,4],[2,2,1,2],[2,1,2],[5,3],[1,1],[2]],
	
	[[_, _, _,_, _, _, _, _, _, _, _, "X", _, _,_], 
	["X", _, "X", "X", _, _, _, _, _, _, _, "X", _, _, "X"], 
	["X", _, _, _, _, _, _, _, _, _, _, _,_, "X", "X"], 
	["X", _, _, _, "X", _, "X", _, "X", _, _, _, _, "X", "X"], 
	[_, _, _, _, _, _, "X", "X", _, _, _, "X", _, _, _], 
	[_, "X", _, "X", "X", _, _, "X", _, _, _, "X", _, "X", _], 
	[_, _, _, "X", _, _, "X", _, _, _, _, "X", _, _, "X"], 
	[_, "X", _, _, "X", _,_, "X", _, _, "X", "X", _, "X", "X"], 
	[_, _, "X", _, "X", _, _, _, _, "X", "X", _, _, "X", "X"], 
	[_, _, "X", _, _, _, _, _, "X", _, _, _, _, "X", "X"], 
	[_, _, "X", "X", _, _, _, _, _, _, "X", "X", _, "X", "X"], 
	[_, _, _, _, _, _, _, _, _, _, _, "X", _, _, "X"],
	 ["X", _, "X", "X", "X", _, _, _, _, _, "X", _, _, "X", "X"], 
	 [_, _, "X", "X", _, _, _, _, _, _, _, _, "X", "X", "X"], 
	 ["X", _, _, "X", _, _, "X", _, "X", _, _, "X", _, _, _]]
	).