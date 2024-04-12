import { useState, useEffect } from 'react';
import { useQuery } from '@apollo/client';
import {GET_VAULT_BY_ID} from '../queries/index.js'
import { formatUnits } from 'viem'
import { formatNumber } from '../utils/formattingUtils.jsx';

const useVault = (vaultAddress) => {
  const [vault, setVault] = useState([]);

  const [isFetching, setIsFetching] = useState(false);

  const { data } = useQuery(GET_VAULT_BY_ID, {
    variables: {
      vaultAddress: vaultAddress
    },
    pollInterval: 3000
  });


  const fetchData = () => {
    setIsFetching(true);
    setVault(null)
  }

  useEffect(() => {

    if (data) {

      const objects = data.lpbreakdownSources.map(function(data, index) {
        const vault = data['vault']
        const lpToken = data['lpToken']

        return {
          id: index,
          vaultAddress: vault != null ?vault['vaultAddress'] : '',
          vaultName: vault != null ? vault['name'] : lpToken['name'],
          vaultByAPI: "0",
          vaultByAPIDays: "0",
          vaultByTVL: "0",
          vaultByDeposited: vault != null ? formatNumber(formatUnits(vault['vaultInfo']['totalAssets'], lpToken['decimals']))  : '0',
          vaultIsExist: lpToken['vaultIsExist'],
          vaultPoolType: lpToken['poolType'],
          symbol: lpToken['symbol'],
          lastHarvest: vault != null ? vault['vaultInfo']['lastHarvest'] : '0',
          pricePerOneShare: vault != null ? vault['vaultInfo']['pricePerOneShare'] : '0'
        }
      })

      setVault(objects)

    } else {
      setIsFetching(true);
    }
  }, [data, setIsFetching])

  return { vault, isFetching, fetchData };
}


export default useVault