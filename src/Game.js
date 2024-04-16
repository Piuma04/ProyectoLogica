import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';

let pengine;

function Game() {
  const [grid, setGrid] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
  const [waiting, setWaiting] = useState(false);
  const [RS, setRs] = useState(null);
  useEffect(() => {
    PengineClient.init(handleServerReady);
  }, []);
  function handleServerReady(instance) {
    pengine = instance;
    const queryS = 'init(RowClues, ColumClues, Grid)';
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['Grid']);
        setRowsClues(response['RowClues']);
        setColsClues(response['ColumClues']);
        setRs(0);
      }
    });
  }
  function handleClick(i, j) {
    if (waiting) {
      return;
    }
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); 
    const colClues = JSON.stringify(colsClues);
    const rowClues = JSON.stringify(rowsClues);
    const content = '#'; 
    const queryS = `put("${content}", [${i},${j}], ${rowClues}, ${colClues},${squaresS}, ResGrid, RowSat, ColSat)`; 
    
    setWaiting(true);
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['ResGrid']);
        
       console.log(response['RowSat']);
        console.log(response['ColSat']);
        setRs(response['RowSat']);
       
      }
      setWaiting(false);
    });
  }
  if (!grid) {
    return null;
  }
  console.log(RS)
  const statusText = RS === 0 ? 'Keep playing!' : 'You won!';
  return (
    <div className="game">
      <Board
        grid={grid}
        rowsClues={rowsClues}
        colsClues={colsClues}
        onClick={(i, j) => handleClick(i, j)}
      />
      <div className="game-info">
        {statusText}
      </div>
    </div>
  );
}

export default Game;