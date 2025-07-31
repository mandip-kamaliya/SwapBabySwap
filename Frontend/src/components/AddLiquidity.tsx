import { useState } from 'react';
import { ethers } from 'ethers';
import { SWAP_BABY_SWAP_CONSTANTS } from '../constants';

export function AddLiquidity() {
  const [tokenA, setTokenA] = useState(SWAP_BABY_SWAP_CONSTANTS.TOKEN_A_ADDRESS);
  const [tokenB, setTokenB] = useState(SWAP_BABY_SWAP_CONSTANTS.TOKEN_B_ADDRESS);
  const [amountA, setAmountA] = useState('');
  const [amountB, setAmountB] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleAddLiquidity = async () => {
    if (!window.ethereum) {
      alert("MetaMask is not installed!");
      return;
    }

    setIsLoading(true);
    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();

      // Create contract instances
      const routerContract = new ethers.Contract(
        SWAP_BABY_SWAP_CONSTANTS.ROUTER_ADDRESS,
        SWAP_BABY_SWAP_CONSTANTS.ROUTER_ABI,
        signer
      );
      const tokenAContract = new ethers.Contract(tokenA, SWAP_BABY_SWAP_CONSTANTS.TOKEN_ABI, signer);
      const tokenBContract = new ethers.Contract(tokenB, SWAP_BABY_SWAP_CONSTANTS.TOKEN_ABI, signer);

      console.log("Approving tokens...");
      
      const amountADesired = ethers.parseUnits(amountA, 18);
      const amountBDesired = ethers.parseUnits(amountB, 18);

      const approveATx = await tokenAContract.approve(SWAP_BABY_SWAP_CONSTANTS.ROUTER_ADDRESS, amountADesired);
      await approveATx.wait(); 
      console.log("Token A approved");

      const approveBTx = await tokenBContract.approve(SWAP_BABY_SWAP_CONSTANTS.ROUTER_ADDRESS, amountBDesired);
      await approveBTx.wait(); 
      console.log("Token B approved");

      console.log("Adding liquidity...");
      const addLiquidityTx = await routerContract.addLiquidity(
        tokenA,
        tokenB,
        amountADesired,
        amountBDesired
      );
      await addLiquidityTx.wait();

      alert("Liquidity added successfully!");

    } catch (error) {
      console.error("Failed to add liquidity:", error);
      alert("Failed to add liquidity. Check the console for details.");
    } finally {
      setIsLoading(false);
    }
  };

  const inputStyle = { marginBottom: '10px', padding: '8px', fontSize: '16px', width: 'calc(100% - 20px)' };
  const buttonStyle = { padding: '10px 20px', fontSize: '16px', cursor: 'pointer' };

  return (
    <div style={{ border: '1px solid #ccc', padding: '20px', borderRadius: '8px', marginTop: '20px' }}>
      <h2>Add Liquidity</h2>
      <input type="text" placeholder="Token A Address" value={tokenA} onChange={(e) => setTokenA(e.target.value)} style={inputStyle} />
      <input type="text" placeholder="Amount of Token A" value={amountA} onChange={(e) => setAmountA(e.target.value)} style={inputStyle} />
      <input type="text" placeholder="Token B Address" value={tokenB} onChange={(e) => setTokenB(e.target.value)} style={inputStyle} />
      <input type="text" placeholder="Amount of Token B" value={amountB} onChange={(e) => setAmountB(e.target.value)} style={inputStyle} />
      <button onClick={handleAddLiquidity} style={buttonStyle} disabled={isLoading}>
        {isLoading ? 'Processing...' : 'Add Liquidity'}
      </button>
    </div>
  );
}