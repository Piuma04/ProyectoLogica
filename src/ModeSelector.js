import React from "react";
function ModeSelector({ value, changeBrush }) {
    const brushType = value==="#"? "Hbrush":"Xbrush";
    return (
      <label className='switch'>
        <input type="checkbox" onChange={changeBrush} />
        <span className="slider"></span>
        <span className={brushType}></span>
      </label>
    );
  }
export default ModeSelector;