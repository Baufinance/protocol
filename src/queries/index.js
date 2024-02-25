import { gql } from '@apollo/client';


export const GET_PAST_VAULTS = gql`
  query GetVaults($perPage: Int!, $skip: Int!) {
    lpbreakdownSources(first:$perPage, skip:$skip) {
      lpToken {
        poolType
        name
        symbol
        decimals
        vaultIsExist
      }

      vault {
         vaultAddress
         name
         symbol
         vaultInfo {
          totalAssets
         }
      }
    }
  }
`;