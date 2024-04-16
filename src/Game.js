import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';

let pengine;

function Game() {
  const [grid, setGrid] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
  const [waiting, setWaiting] = useState(false);
  const [isCrossing, setIsCrossing] = useState(false);
  const [RS, setRS] = useState(null);
  //starts the server
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
        // de donde verga aparecio esto?? SVGAnimatedPreserveAspectRatio(0);
      }
    });
  } 
  //tell you if you won
  useEffect(() => {
    if(grid != null){
      const squaresS2 = JSON.stringify(grid).replaceAll('"_"', '_');
      const colClues = JSON.stringify(colsClues);
      const rowClues = JSON.stringify(rowsClues);
      const queryT = `checkWinner(${0}, ${squaresS2}, ${rowClues}, ${colClues}, IsWinner)`;
      pengine.query(queryT, (success2, response2) => {
        if (success2) {
          setRS(response2['IsWinner']);
        }
        setWaiting(false);
      });
    }
  }, [grid,rowsClues,colsClues]);
  //handles the click
  function handleClick(i, j) {
    if (waiting) {
      return;
    }
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); 
    const colClues = JSON.stringify(colsClues);
    const rowClues = JSON.stringify(rowsClues);
    const content = isCrossing?'X':'#';
    const queryS = `put("${content}", [${i},${j}], ${rowClues}, ${colClues},${squaresS}, ResGrid, RowSat, ColSat)`; 
    
    setWaiting(true);
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['ResGrid']);
        
        console.log(response['RowSat']);
        console.log(response['ColSat']);
        setRS(response['RowSat']);
       
      }
      setWaiting(false);
    });
  }
  if (!grid) {
    return null;
  }
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
    <ModeSelector
        value={isCrossing?"X":"#"}
        changeBrush={() => setIsCrossing(!isCrossing)}
      />
    </div>
      <div className="game-info">
        {statusText}
      </div>
    </div>
  );
}

function ModeSelector({value,changeBrush})
{
  return(
  <button 
    className='brush' onClick={changeBrush}>
    {value}
  </button>)
}
export default Game;