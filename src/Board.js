import React from 'react';
import Square from './Square';
import Clue from './Clue';
import CenteredContainer from './CenteredContainer';

function Board({ grid, rowsClues, colsClues, onClick, highlightedClueCoords }) {
    const numOfRows = grid.length;
    const numOfCols = grid[0].length;
    return (
        <CenteredContainer>
        <div className="vertical" style={{
            display: 'flex',
            justifyContent: 'center', 
            alignItems: 'center', 
            height: '100vh', 
          }}>
            <div
                className="colClues"
                style={{
                    gridTemplateRows: '60px',
                    gridTemplateColumns: `60px repeat(${numOfCols}, 40px)`
                    
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
                        gridTemplateColumns: '60px'
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
        </CenteredContainer>);
}

export default Board;