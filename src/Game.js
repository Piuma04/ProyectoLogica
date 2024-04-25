import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import CenteredContainer from './CenteredContainer';

let pengine;

function Game() {
  const [grid, setGrid] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
  const [waiting, setWaiting] = useState(false);
  const [isCrossing, setIsCrossing] = useState(false);
  const [RS, setRS] = useState(null);
  const [highlightedClueCoords,setHighLightedClueCoords] = useState(null);
  //starts the server
  useEffect(() => {
    PengineClient.init(handleServerReady);
  }, []);
  function handleServerReady(instance) {
    pengine = instance;
    const queryS = 'init(RowClues, ColumClues, Grid),markInicialClues(Grid,RowClues,ColumClues,GridSat)';
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['Grid']);
        setRowsClues(response['RowClues']);
        setColsClues(response['ColumClues']);
        setHighLightedClueCoords(response['GridSat']);
       //que verga es esto?? SVGAnimatedPreserveAspectRatio(0);
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
    //console.log(highlightedClueCoords);
    if (waiting) {
      return;
    }
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); 
    const colClues = JSON.stringify(colsClues);
    const rowClues = JSON.stringify(rowsClues);
    const content = isCrossing?'X':'#';

    const queryS = `put("${content}", [${i},${j}], ${rowClues}, ${colClues},${squaresS}, ResGrid, RowSat, ColSat)`; 
    console.log(highlightedClueCoords);
    setWaiting(true);
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['ResGrid']);
        highlightedClueCoords[0][i] = response['RowSat'];
        highlightedClueCoords[1][j] = response['ColSat'];
      }
      setWaiting(false);
    });
  }
  if (!grid) {
    return null;
  }
  const statusText = RS === 0 ? 'Keep playing!' : 'You won!';
  return (<CenteredContainer>
   
    <div className="game">
      <Board
        grid={grid}
        rowsClues={rowsClues}
        colsClues={colsClues}
        onClick={(i, j) => handleClick(i, j)}
        highlightedClueCoords={highlightedClueCoords}
      />

      
    </div>
    <div className="container" style={{
      display: 'flex',
      flexDirection: 'row',
      
    }}>
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

    </CenteredContainer>);
}

function ModeSelector({value,changeBrush})
{
  let elem;
  if(value === "#") {
  elem = (
  <button 
    className='Hbrush' onClick={changeBrush}>
    {value}
  </button>);
  }else{
    elem = (
      <button 
        className='Xbrush' onClick={changeBrush}>
        {value}
      </button>);
  }
  return elem;
}
export default Game;