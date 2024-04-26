import React from 'react';
import Square from './Square';
import Clue from './Clue';

function Board({ grid, rowsClues, colsClues, onClick, highlightedClueCoords }) {
    const numOfRows = grid.length;
    const numOfCols = grid[0].length;
    const maxNumbersRow = computeMax(rowsClues)=== 1 ? 60 : computeMax(rowsClues)  * 20;
    const maxNumbersCol = computeMax(colsClues) === 1 ? 60 :  computeMax(colsClues) * 30;
    console.log(maxNumbersCol);
    console.log(maxNumbersRow);
   
    return (
        
        <div className="vertical" >
            <div
                className="colClues"
                style={{
                    gridTemplateRows: `${maxNumbersCol}px`,
                    gridTemplateColumns: `${maxNumbersRow}px repeat(${numOfCols}, 40px)`
                    
                }}
            >
                <div>{/* top-left corner square */}</div>
                {colsClues.map((clue, i) =>
                    <Clue clue={clue} highlight={highlightedClueCoords[1][i]} key={i} />
                )}
            </div>
            <div className="horizontal" >
                <div
                    className="rowClues"
                    style={{
                        gridTemplateRows: `repeat(${numOfRows}, 40px)`,
                        gridTemplateColumns: `${maxNumbersRow}px`
                        /* IDEM column clues above */
                    }}
                >
                    {rowsClues.map((clue, i) =>
                        <Clue clue={clue} highlight={highlightedClueCoords[0][i]} key={i} />
                        
                    )}
                </div>
                <div className="board"
                    style={{
                        gridTemplateRows: `repeat(${numOfRows}, 40px)`,
                        gridTemplateColumns: `repeat(${numOfCols}, 40px)`
                        
                    }}>
                    {grid.map((row, i) =>
                        row.map((cell, j) =>
                            <Square
                                value={cell}
                                onClick={() => onClick(i, j)}
                                key={i + j}
                            />
                        )
                    )}
                </div>
            </div>
        </div>
       );
}

function computeMax(Clue)
{
    var max = 0;
    for(var i = 0;i<Clue.length;i++)
        if(max<Clue[i].length)
            max = Clue[i].length;
        
    return max;
}
export default Board;