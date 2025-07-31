/* eslint-disable @typescript-eslint/no-unused-vars */
import { useState } from 'react';
import { ethers } from 'ethers';
import type { Eip1193Provider } from "ethers";
import { AddLiquidity } from './components/AddLiquidity';


declare global {
  interface Window {
    ethereum?: Eip1193Provider;
  }
}

function App() {
  // Create a state variable to store the user's wallet address.
  // It starts as null because we aren't connected yet.
  const [userAddress, setUserAddress] = useState<string | null>(null);

  // This function is called when the user clicks the "Connect Wallet" button.
  const connectWallet = async () => {
    // Check if MetaMask is installed in the browser.
    if (window.ethereum) {
      try {
        // Request access to the user's accounts.
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        // Create an ethers provider.
        const provider = new ethers.BrowserProvider(window.ethereum);
        // Get the signer (the user's account).
        const signer = await provider.getSigner();
        // Set the user's address in our state variable.
        setUserAddress(await signer.getAddress());
      } catch (error) {
        console.error("Error connecting to MetaMask", error);
      }
    } else {
      // If MetaMask is not installed, alert the user.
      alert("Please install MetaMask to use this dApp.");
    }
  };

  return (
    <div style={{ padding: '20px', fontFamily: 'sans-serif' }}>
      <h1>SwapBabySwap DEX</h1>

      {/* This is a conditional render.
        - If userAddress is null (we are not connected), it shows the "Connect Wallet" button.
        - If userAddress has a value (we are connected), it shows the connected address.
      */}
      {userAddress ? (
        <div>
          <p><strong>Connected:</strong> {userAddress}</p>
          <AddLiquidity></AddLiquidity>
        </div>
      ) : (
        <button onClick={connectWallet} style={{ padding: '10px', fontSize: '16px' }}>
          Connect Wallet
        </button>
      )}
    </div>
  );
}

export default App;