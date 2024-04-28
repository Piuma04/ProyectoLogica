import React from 'react';

function Square({ value, onClick }) {
   let elem;
   if(value === "#"){
    elem = (
        <button className="coloredSquare" onClick={onClick}>
        </button>
    );
   }
   else{
    elem = (
        <button className="square" onClick={onClick}>
            {value !== '_' ? value : null}
        </button>
    );
   }
   
    return elem;
}
export default Square;