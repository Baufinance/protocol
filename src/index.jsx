import React from "react";
import ReactDOM from "react-dom/client";
import "./index.module.scss";
import App from "./App.jsx";

import '@rainbow-me/rainbowkit/styles.css';
import merge from 'lodash.merge';

import {
  getDefaultWallets,
  RainbowKitProvider,
  darkTheme
} from '@rainbow-me/rainbowkit';
import { configureChains, createConfig, WagmiConfig } from 'wagmi';
import {
  arbitrum,
  base,
  mainnet,
  optimism,
  polygon,
  zora,
  goerli
} from 'wagmi/chains';
import { alchemyProvider } from 'wagmi/providers/alchemy';
import { publicProvider } from 'wagmi/providers/public';

const root = ReactDOM.createRoot(document.getElementById("root"));

const { chains, publicClient } = configureChains(

  [ goerli,
    arbitrum,
    base,
    mainnet,
    optimism,
    polygon,
    zora],
  [
    alchemyProvider({ apiKey: import.meta.env.VITE_ALCHEMY_ID}),
    publicProvider()
  ]
);

const { connectors } = getDefaultWallets({
  appName: 'My RainbowKit App',
  projectId:  import.meta.env.VITE_WALLET_CONNECT_PROJECT_ID,
  chains
});

const wagmiConfig = createConfig({
  autoConnect: true,
  connectors,
  publicClient
})


const myTheme = merge(darkTheme(), {
  colors: {
    accentColor: '#07296d',
    connectButtonBackground: 'transparent',
  },
  fonts: {
    body: 'Unbounded',
  },
  shadows: {
    connectButton: 'none',
  },
});

root.render(
  <React.StrictMode>
    <WagmiConfig config={wagmiConfig}>
      <RainbowKitProvider chains={chains} locale="en-US"   theme={myTheme}>
     <App />
    </RainbowKitProvider>
    </WagmiConfig>
  </React.StrictMode>
);
