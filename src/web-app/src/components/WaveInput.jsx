import React, { useState } from 'react';

function WaveInput(props) {
    const [waveMessage, setWaveMessage] = useState("");
    const [loading, setLoading] = useState(false);


  function handleChange(event) {
    setWaveMessage(event.target.value);
  }
  
  function handleButtonClick() {
    props.onButtonClick(waveMessage);  
  }
  
  return (
    <div>
      <label htmlFor="WaveInput">Enter your message:</label>
      <input type="text" id="WaveInput" value={waveMessage} onChange={handleChange} />
      <button className="waveButton" disabled={loading} onClick={handleButtonClick}>
          Wave at Me
        </button>
    </div>
  );
}

export default WaveInput;