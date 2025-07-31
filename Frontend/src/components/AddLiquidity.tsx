import { useState } from 'react';

export function AddLiquidity() {
  // We use useState to store the values from the input fields
  const [tokenA, setTokenA] = useState('');
  const [tokenB, setTokenB] = useState('');
  const [amountA, setAmountA] = useState('');
  const [amountB, setAmountB] = useState('');

  const handleAddLiquidity = () => {
    // We'll add the blockchain logic here in the next step
    console.log("Adding liquidity:", { tokenA, tokenB, amountA, amountB });
    alert("Check the console for the values!");
  };

  // Basic styling to make the form look decent
  const inputStyle = {
    marginBottom: '10px',
    padding: '8px',
    fontSize: '16px',
    width: 'calc(100% - 20px)' // Adjust width to account for padding
  };

  const buttonStyle = {
    padding: '10px 20px',
    fontSize: '16px',
    cursor: 'pointer'
  };

  return (
    <div style={{ border: '1px solid #ccc', padding: '20px', borderRadius: '8px', marginTop: '20px' }}>
      <h2>Add Liquidity</h2>
      <input
        type="text"
        placeholder="Token A Address"
        value={tokenA}
        onChange={(e) => setTokenA(e.target.value)}
        style={inputStyle}
      />
      <input
        type="text"
        placeholder="Amount of Token A"
        value={amountA}
        onChange={(e) => setAmountA(e.target.value)}
        style={inputStyle}
      />
      <input
        type="text"
        placeholder="Token B Address"
        value={tokenB}
        onChange={(e) => setTokenB(e.target.value)}
        style={inputStyle}
      />
      <input
        type="text"
        placeholder="Amount of Token B"
        value={amountB}
        onChange={(e) => setAmountB(e.target.value)}
        style={inputStyle}
      />
      <button onClick={handleAddLiquidity} style={buttonStyle}>
        Add Liquidity
      </button>
    </div>
  );
}