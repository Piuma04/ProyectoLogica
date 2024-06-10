
import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import CenteredContainer from './CenteredContainer';
import ModeSelector from './ModeSelector';
let pengine;

function Game() {

  const [grid, setGrid] = useState(null);
  const [winnerGrid, setWinnerGrid] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
 
  const [waiting, setWaiting] = useState(false);
  const [isCrossing, setIsCrossing] = useState(false);
  const [seeHint, setSeeHint] = useState(false);
  const [seeSolutionGrid,setSeeSolutionGrid] = useState(0);
  const [GameSatisfaction, setGameSatisfaction] = useState(0);
  const [highlightedClueCoords,setHighLightedClueCoords] = useState(null);
  const [currentLevel,setCurrentLevel] = useState(0);
  const [time, setTime] = useState(0);
  const [isRunning, setIsRunning] = useState(false);
  const maxLevel = 4;
  //starts the server
  useEffect(() => {
    PengineClient.init(handleServerReady);
  }, []);
  function handleServerReady(instance) {
    pengine = instance;
    const queryS = 'init(RowClues, ColumClues, Grid),markInicialClues(Grid,RowClues,ColumClues,GridSat),solve(Grid,RowClues,ColumClues,SolvedGrid)'
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['Grid']);
        setWinnerGrid(response['SolvedGrid']);
        setRowsClues(response['RowClues']);
        setColsClues(response['ColumClues']);
        setHighLightedClueCoords(response['GridSat']);
      }
    });
  } 
  //tell you if you won
  useEffect(() => {
    if(grid != null && seeSolutionGrid === 0){
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
    
  }, [grid,rowsClues,colsClues,seeSolutionGrid]);

  //updates timer
  useEffect(() => {
    let intervalId;
    if (isRunning  && GameSatisfaction === 0) {
      intervalId = setInterval(() => setTime(time + 1), 10);
    }else{
      setIsRunning(false);
    }
  
    return () => clearInterval(intervalId);
  }, [isRunning, time, GameSatisfaction]);

  //handles the click on a square
  function handleClick(i, j) {
    if (!waiting && isRunning & seeSolutionGrid === 0) {
    const squaresS = JSON.stringify(grid).replaceAll('""', ''); 
    const colClues = JSON.stringify(colsClues);
    const rowClues = JSON.stringify(rowsClues);
    const content = isCrossing?'X':'#';
    let queryS;
    setWaiting(true);
    if(!seeHint){
     queryS = `put("${content}", [${i},${j}], ${rowClues}, ${colClues},${squaresS}, ResGrid, RowSat, ColSat)`; 
    }
    else{
      const winGrid = JSON.stringify(winnerGrid).replaceAll('""', ''); 
    
       queryS = `generateGridWithHint([${i},${j}], ${rowClues}, ${colClues}, ${squaresS}, ${winGrid}, ResGrid, RowSat, ColSat)`;
       
    }
     
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
    setIsRunning(true);
    if(waiting && currentLevel+1<=maxLevel)
    {
      const queryS = `level${currentLevel+1}(RowClues, ColumClues, Grid),markInicialClues(Grid,RowClues,ColumClues,GridSat),solve(Grid,RowClues,ColumClues,SolvedGrid)`;
      
      pengine.query(queryS, (success, response) => { 
        if (success) {
          setGrid(response['Grid']);
          setWinnerGrid(response['SolvedGrid'])
          setGameSatisfaction(0)
          setRowsClues(response['RowClues']);
          setColsClues(response['ColumClues']);
          setHighLightedClueCoords(response['GridSat']);
          setTime(0);
        }
        
      });
      setWaiting(false);
    }
    else
       window.location.reload();
  };

  const handleHintClick= () => {
    setSeeHint(!seeHint);

  };
  
  const handleSolutionClick= () => {
    setSeeSolutionGrid(seeSolutionGrid ? 0 : 1);
  };
  const handleSolveClick= () => {
    if(!waiting && seeSolutionGrid === 0){
      setGrid(winnerGrid);
      const squaresS2 = JSON.stringify(winnerGrid).replaceAll('""', '');
      const colClues = JSON.stringify(colsClues);
      const rowClues = JSON.stringify(rowsClues);   
      const queryT = `markInicialClues( ${squaresS2}, ${rowClues}, ${colClues},GridSat)`;
      
          pengine.query(queryT, (success, response) => { 
          if (success) { setHighLightedClueCoords(response['GridSat']); } 
        });
    }
  };
  
  const goToLevel = (i) => {
    if(!waiting){
          setCurrentLevel(i);
          setWaiting(true);
          setIsRunning(false);
          let queryT; 
      if(i===0) { queryT = `init(RowClues, ColumClues, Grid),markInicialClues(Grid,RowClues,ColumClues,GridSat),solve(Grid,RowClues,ColumClues,SolvedGrid)`;}
      else { queryT = `level${i}(RowClues, ColumClues, Grid),markInicialClues(Grid,RowClues,ColumClues,GridSat),solve(Grid,RowClues,ColumClues,SolvedGrid)`;}
          pengine.query(queryT, (success, response) => { 
          if (success) {
            setGrid(response['Grid']);
            setWinnerGrid(response['SolvedGrid'])
            setRowsClues(response['RowClues']);
            setColsClues(response['ColumClues']);
            setHighLightedClueCoords(response['GridSat']);
            
          }
          
        });
        
      setWaiting(false);
      setTime(0);
    }
    };


    //sets the time corectly
    const hours = Math.floor(time / 360000);
    const minutes = Math.floor((time % 360000) / 6000);
    const seconds = Math.floor((time % 6000) / 100);
    const milliseconds = time % 100;

    //starts and stops the timer
    const startAndStop = () => {
      if(!waiting){
      setIsRunning(!isRunning);
      }
    };

    const beatedGameText = currentLevel === maxLevel ? "You beated the game. Press OK to reload it." : "You WON! Press OK to load the next level.";
   
    const solutionButtonText = seeSolutionGrid === 0 ? "SEE SOLUTION" : "SEE NORMAL GRID";

  return (
  <CenteredContainer>
          <p className='warning'>AVISO! PARA MODIFICAR EL TABLERO, ES NECESARIO ARRANCAR EL CRONOMETRO</p>
         <p className='levelIndicator'><span className='spanLI'>Level {currentLevel}</span></p>
         <div className="stopwatch-container">
            <p className="stopwatch-time">
              {hours}:{minutes.toString().padStart(2, "0")}:
              {seconds.toString().padStart(2, "0")}:
              {milliseconds.toString().padStart(2, "0")}
            </p>
           <div className="stopwatch-buttons">
          <button className="stopwatch-button" onClick={startAndStop}>
              {isRunning ? "Stop" : "Start"}
          </button>
          </div>
        </div>

      <div>
        <div className="game">
          
          
          <Board
            grid = {seeSolutionGrid === 1 ? winnerGrid : grid}
            rowsClues={rowsClues}
            colsClues={colsClues}
            onClick={(i, j) => handleClick(i, j)}
            highlightedClueCoords={highlightedClueCoords}
          />
          <div className="levelsGrid">
             {Array.from({ length: maxLevel+1 }, (_, index) => (
             <div key={index} className="levelLabel">
              <button className='buttonA' onClick={() => goToLevel(index)}>Level {index}</button>
             </div>
              ))}
           </div>
            

        </div>
         <div className="container" >
            <div className="toggleH" onClick={handleHintClick}>
              <input type="checkbox"/>
              <span className="button"></span>
              <span className="label">☼</span>
            </div>
            
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
                
                <p>{beatedGameText}</p>
                <button className="okButton" onClick={handleOkClick}>OK</button>
              </div>
            )}
          </div>
          
        </div>
        
        
      </div>
      
      <button type="solutionButton" className="solutionButton" onClick={handleSolutionClick}>
        <div className="solutionButton-top">{solutionButtonText}</div>
        <div className="solutionButton-bottom"></div>
        <div className="solutionButton-base"></div>
      </button>

      <button className="btn" onClick={handleSolveClick}> SOLVE GRID
      </button>
    </CenteredContainer>);
}
export default Game;