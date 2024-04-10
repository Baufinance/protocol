import React from "react";
import ReactDOM from "react-dom/client";
import "./index.module.scss";
import App from "./App.jsx";

import '@rainbow-me/rainbowkit/styles.css';
import merge from 'lodash.merge';
import { ApolloClient, ApolloProvider, InMemoryCache } from '@apollo/client';
import {
  getDefaultWallets,
  RainbowKitProvider,
  darkTheme,
  midnightTheme
} from '@rainbow-me/rainbowkit';
import { configureChains, createConfig, sepolia, WagmiConfig } from 'wagmi';
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
    sepolia,
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


const myTheme = merge(midnightTheme(), {
  colors: {
    accentColor: 'rgb(142, 195, 0)',
    connectButtonBackground: 'transparent',
  },
  fonts: {
    body: 'Unbounded',
  },
  shadows: {
    connectButton: 'none',
  },
});

const client = new ApolloClient({
  uri: import.meta.env.VITE_GRAPHQL_URL,
  cache: new InMemoryCache()
});

root.render(
  <React.StrictMode>
    <ApolloProvider client={client}>
      <WagmiConfig config={wagmiConfig}>
        <RainbowKitProvider chains={chains} locale="en-US"   theme={myTheme}>
      <App />
      </RainbowKitProvider>
      </WagmiConfig>
    </ApolloProvider>
  </React.StrictMode>
);
