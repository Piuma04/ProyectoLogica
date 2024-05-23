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

%Completar tablero metodos

fillClues([],PartialLine,PossibleLine):-
	fillClues([0],PartialLine,PossibleLine).
fillClues([Clue|Clues],PartialLine,PossibleLine):-
	sumElems([Clue|Clues],Sum),
	length(PartialLine, Length),
	Blanks is Length-Sum,
	fillCluesAux([Clue|Clues],Blanks,PossibleLine),
	PossibleLine = PartialLine.

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
sumElems([Clue|Clues],ClueSum):-
	sumElems(Clues,PastSum),ClueSum is PastSum + Clue.

fillFollowing(0,_Symbol,[]).
fillFollowing(Cant,Symbol,[Symbol|Elems]):-Cant>=0,NewCant is Cant-1,fillFollowing(NewCant,Symbol,Elems).

findCoincidences(Clues,PartialLine,Coincidences):-
	findall(PossibleLine, fillClues(Clues, PartialLine, PossibleLine), AllPossibleLines),
	transpose(AllPossibleLines,T),
	findCoincidencesAux(T,Coincidences).

findCoincidencesAux([],[]).
findCoincidencesAux([T|Ts],[I|Is]):-
	(forall(member(X,T),X=="#"), I="#"),!,
	findCoincidencesAux(Ts,Is).
findCoincidencesAux([T|Ts],[I|Is]):-
	(forall(member(X,T),X=="X"), I="X"),!,
	findCoincidencesAux(Ts,Is).
findCoincidencesAux([_T|Ts],[I|Is]):-
	I=_,
	findCoincidencesAux(Ts,Is).

fillColumns(ColumnClues,Grid,FilledC):-
	transpose(Grid, GT),
	fillColumnsAux(ColumnClues,GT,FilledCT),
	transpose(FilledCT,FilledC).

fillColumnsAux([],[],[]).
fillColumnsAux([CC|CCs],[Col|Cols],[FilledC|FilledCs]):-
	findCoincidences(CC,Col,FilledC),
	fillColumnsAux(CCs,Cols,FilledCs).

fillRows([],[],[]).
fillRows([RC|RCs],[Row|Rows],[FilledR|FilledRs]):-
	fillClues(RC,Row,FilledR),
	fillRows(RCs,Rows,FilledRs).

solve(Grid,RowClues,ColumnClues,SolvedGrid):-
	copy_term(Grid, GridCopy),solveAux(GridCopy,RowClues,ColumnClues,SolvedGrid).
	
solveAux(Grid,RowClues,ColumnClues,SolvedGrid):-
	fillColumns(ColumnClues,Grid,PartialRows),
	fillColumnsAux(RowClues,PartialRows,PartialGrid),
	countElement(Grid,N),countElement(PartialGrid,NN),N=\=NN,!,
	solveAux(PartialGrid,RowClues,ColumnClues,SolvedGrid).
solveAux(Grid,RowClues,ColumnClues,PosGrid):-generateTrueAnswer(Grid,RowClues,ColumnClues,PosGrid).

countElement([],0):-!.
countElement([R|Rs],Sum):-countElement(Rs,LastSum),findall(X, (member(X, R),(X=="#";X=="X")), Sumable),length(Sumable, SumX),Sum is SumX+LastSum.



copyGrid([],[]).
copyGrid([Row|Rows],[RCopy|RCopies]):-
	copyList(Row,RCopy),copyGrid(Rows,RCopies).
copyList([],[]).
copyList([E|Es],[ECopy|ECopies]):-
	copy_term(E, ECopy),copyList(Es,ECopies).

checkColumns(_Position,_Grid,[],[],1).
checkColumns(Position,Grid,[],[ColumnClue|ColumnClues],IsWinner):-
	searchColumn(Position,Grid,NewColumn),
	checkClues(ColumnClue, NewColumn,ColSat),
	ColSat == 1, NewPosition  = Position+1,
	checkColumns(NewPosition, Grid, [], ColumnClues, IsWinner).
checkColumns(_Position,_Grid,_RowClues,_ColumnClues,0).	

generateTrueAnswer(Grid,RC,CC,PosGrid):-fillRows(RC,Grid,PosGrid),checkColumns(0,PosGrid,[],CC,1).

fillUnfinished([],[],[]).
fillUnfinished([Row|Rows],[_RC|RCs],[Row|NRows]):-isFinished(Row),!,fillUnfinished(Rows,RCs,NRows).
fillUnfinished([Row|Rows],[RC|RCs],[NRow|NRows]):-fillClues(RC,Row,NRow),fillUnfinishedAux(Rows,RCs,NRows).
fillUnfinishedAux([],[],[]).
fillUnfinishedAux([Row|Rows],[_RC|RCs],[Row|NRows]):-fillUnfinishedAux(Rows,RCs,NRows).

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