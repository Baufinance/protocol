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


export const GET_USER_VAULTS = gql`
  query GetUserVaults($account:String!, $perPage: Int!, $skip: Int!) {
    userDeposits(first:$perPage, skip:$skip, where:{user:$account}) {
      id
      vault {
        lpBreakDownSource {
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
      user {
        id
      }
      lastUserDepositState {
        state {
          lpTokenAmount
        }
      }
    }
  }
`;