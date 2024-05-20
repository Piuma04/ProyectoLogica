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
  //este de aca abajo te dice si esta en hint o no, configurar, podria optimizarse
  const [seeHint, setSeeHint] = useState(false);
  const [seeSolutionGrid,setSeeSolutionGrid] = useState(0);
  const [GameSatisfaction, setGameSatisfaction] = useState(null);
  const [highlightedClueCoords,setHighLightedClueCoords] = useState(null);
  const [currentLevel,setCurrentLevel] = useState(0);
  const maxLevel = 3;
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
      if(winnerGrid == null){
        //momentaneo
        setWinnerGrid([
          ["X","#","#","#","#","#","#","_"],
          ["#","#","_","_","_","_","#","#"],
          ["#","#","_","_","_","_","#","#"],
          ["_","_","_","_","_","_","#","#"],
          ["_","_","_","_","_","#","#","#"],
          ["_","_","_","#","#","#","#","_"],
          ["_","_","_","#","#","_","_","_"],
          ["_","_","_","_","_","_","_","_"],
          ["_","_","_","#","#","_","_","_"],
          ["_","_","_","#","#","_","_","_"]

          ]);
       /* const rowLength = length(rowClues);
        const colLength = length(colClues);
        const queryU = `generateTrueAnswer(${rowLength},${colLength},${rowClues},${colClues},WinGrid)`
        pengine.query(queryU, (success2, response2) => {
          if (success2) { setWinnerGrid(response2['WinGrid']); }
        });*/
        /*
        cuando ande el generateTrueAnswer descomentar esto
        */
      }
    }
    
  }, [grid,rowsClues,colsClues]);
  //handles the click
  function handleClick(i, j) {
    if (!waiting && seeSolutionGrid === 0) {
    const squaresS = JSON.stringify(grid).replaceAll('""', ''); 
    const colClues = JSON.stringify(colsClues);
    const rowClues = JSON.stringify(rowsClues);
    const content = isCrossing?'X':'#';
    let queryS;
    if(!seeHint){
     queryS = `put("${content}", [${i},${j}], ${rowClues}, ${colClues},${squaresS}, ResGrid, RowSat, ColSat)`; 
    }
    else{
      const winGrid = JSON.stringify(winnerGrid).replaceAll('""', ''); 
    
       queryS = `generateGridWithHint([${i},${j}], ${rowClues}, ${colClues}, ${squaresS}, ${winGrid}, ResGrid, RowSat, ColSat)`;
       
    }
      setWaiting(true);
      pengine.query(queryS, (success, response) => {
      
        if (success) {
          console.log(response['ResGrid']);
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

  const handleHintClick= () => {
    setSeeHint(!seeHint);

  };
  const handleSolutionClick= () => {
    setSeeSolutionGrid(seeSolutionGrid ? 0 : 1);
  };
  let g = 0;
  const goToLevel = (i) => {
    if(!waiting)
    {
          setCurrentLevel(i);
      if(i===0)
        {
          const queryT = `init(RowClues, ColumClues, Grid),markInicialClues(Grid,RowClues,ColumClues,GridSat)`;
          setWaiting(true);
          pengine.query(queryT, (success, response) => { 
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
      {
        const queryS = `level${i}(RowClues, ColumClues, Grid),markInicialClues(Grid,RowClues,ColumClues,GridSat)`;
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
    }
    };
    const beatedGameText = currentLevel === maxLevel ? "You beated the game. Press OK to reload it." : "You WON! Press OK to load the next level.";


  return (
  <CenteredContainer>
      <p className='levelLabel'>Level {currentLevel}</p>
      <div>
        <div className="game">
          {/*solucion temporal, encontar algo mejor*/}
          
          <Board
            grid = {g = seeSolutionGrid === 1 ? winnerGrid : grid}
            rowsClues={rowsClues}
            colsClues={colsClues}
            onClick={(i, j) => handleClick(i, j)}
            highlightedClueCoords={highlightedClueCoords}
          />
          <div className="levelsGrid">
        {Array.from({ length: maxLevel+1 }, (_, index) => (
          <div key={index} className="levelLabel">
            <button onClick={() => goToLevel(index)}>Level {index}</button>
          </div>
        ))}
      </div>

        </div>
        <div className="container" >
          <div className="game-info">
            <ModeSelector
              value={isCrossing?"X":"#"}
              changeBrush={() => setIsCrossing(!isCrossing)}
            />
          </div>
          <div className="fx-block">
	          <div className="toggle">
		          <div>
			          < input type="checkbox"
                  id="toggles"
                  onChange={handleHintClick}
                  />
			          <div data-unchecked="Hint" data-checked="No Hint">
			        </div>
		        </div>
	        </div>
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
        {seeSolutionGrid === 0 && (<button className="seeSolutionButton" onClick={handleSolutionClick}>SEE SOLUTION</button>)}
        {seeSolutionGrid === 1 && (<button className="seeSolutionButton" onClick={handleSolutionClick}>SEE NORMAL GRID</button>)}
      </div>
    </CenteredContainer>);
}
export default Game;