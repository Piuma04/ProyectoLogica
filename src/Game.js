import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import CenteredContainer from './CenteredContainer';
import ModeSelector from './ModeSelector';
let pengine;

function Game() {
  const [grid, setGrid] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
  const [waiting, setWaiting] = useState(false);
  const [isCrossing, setIsCrossing] = useState(false);
  const [GameSatisfaction, setGameSatisfaction] = useState(null);
  const [highlightedClueCoords,setHighLightedClueCoords] = useState(null);
  const [currentLevel,setCurrentLevel] = useState(0);
  const maxLevel = 2;
  //starts the server
  useEffect(() => {
    PengineClient.init(handleServerReady);
  }, []);
  function handleServerReady(instance) {
    pengine = instance;
    const queryS = 'init(RowClues, ColumClues, Grid),markInicialClues(Grid,RowClues,ColumClues,GridSat)'
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['Grid']);
        setRowsClues(response['RowClues']);
        setColsClues(response['ColumClues']);
        setHighLightedClueCoords(response['GridSat']);
      }
    });
  } 
  //tell you if you won
  useEffect(() => {
    if(grid != null){
      const squaresS2 = JSON.stringify(grid).replaceAll('""', '');
      const colClues = JSON.stringify(colsClues);
      const rowClues = JSON.stringify(rowsClues);
      const queryT = `checkWinner(${0}, ${squaresS2}, ${rowClues}, ${colClues}, IsWinner)`
      pengine.query(queryT, (success2, response2) => {
        if (success2) {
          setGameSatisfaction(response2['IsWinner']);
          if(response2['IsWinner']===1)
            setWaiting(true);
        }
        
      });
    }
  }, [grid,rowsClues,colsClues]);
  //handles the click
  function handleClick(i, j) {
    if (!waiting) {
      
    
    const squaresS = JSON.stringify(grid).replaceAll('""', ''); 
    const colClues = JSON.stringify(colsClues);
    const rowClues = JSON.stringify(rowsClues);
    const content = isCrossing?'X':'#';

    const queryS = `put("${content}", [${i},${j}], ${rowClues}, ${colClues},${squaresS}, ResGrid, RowSat, ColSat)`; 
    
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
  }
  if (!grid) {
    return null;
  }

  const handleOkClick = () => {
    setCurrentLevel(currentLevel+1);
    if(waiting && currentLevel+1<=maxLevel)
    {
      const queryS = `level${currentLevel+1}(RowClues, ColumClues, Grid),markInicialClues(Grid,RowClues,ColumClues,GridSat)`;
      setWaiting(true);
      pengine.query(queryS, (success, response) => { 
        if (success) {
          setGrid(response['Grid']);
          setRowsClues(response['RowClues']);
          setColsClues(response['ColumClues']);
          setHighLightedClueCoords(response['GridSat']);
        }
        setWaiting(false);
      });
    }
    else
       window.location.reload();
  };
  return (
  <CenteredContainer>
   
      
      {/*GameSatisfaction === 1 && (
        <div className="alert" >
          <p>¡You Won! Press OK to restart.</p>
          <button onClick={handleOkClick}>OK</button>
        </div>
      )*/}

      
      
      <div><div className="game">
        <Board
          grid={grid}
          rowsClues={rowsClues}
          colsClues={colsClues}
          onClick={(i, j) => handleClick(i, j)}
          highlightedClueCoords={highlightedClueCoords}
        />

        
      </div>
      <div className="container" >
        <div className="game-info">
            <ModeSelector
              value={isCrossing?"X":"#"}
              changeBrush={() => setIsCrossing(!isCrossing)}
          />
          </div>
        <div className="game-info">
            {GameSatisfaction === 0 && (<div className = "KP">Keep Playing!</div>)}
            {GameSatisfaction === 1 && (
              <div className="alert" >
                <p>¡You Won!</p>
                <button className="okButton" onClick={handleOkClick}>OK</button>
              </div>
            )}
        </div>
      </div>
      </div>
    </CenteredContainer>);
}
export default Game;