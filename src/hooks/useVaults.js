import { useState, useEffect } from 'react';
import { useQuery } from '@apollo/client';
import {GET_PAST_VAULTS} from '../queries/index.js'
import { formatUnits } from 'viem'
import { formatNumber } from '../utils/formattingUtils.jsx';

const useVaults = (initialPage, rowsPerPage) => {
  const [vaults, setVaults] = useState([]);

  const [page, setPage] = useState(initialPage);
  const [isFetching, setIsFetching] = useState(false);

  const { data } = useQuery(GET_PAST_VAULTS, {
    variables: {
      perPage: rowsPerPage,
      skip: (page-1) * rowsPerPage,
    },
    pollInterval: 3000
  });

  const fetchData = ({
    page,
    count
  }) => {
    setIsFetching(true);
    setVaults(null)
    setPage(page)
  }

  useEffect(() => {
    if (data) {

      const objects = data.lpbreakdownSources.map(function(data, index) {
        const vault = data['vault']
        const lpToken = data['lpToken']

        return {
          id: index,
          vaultName: vault != null ? vault['name'] : lpToken['name'],
          vaultByAPI: "0",
          vaultByAPIDays: "0",
          vaultByTVL: "0",
          vaultByDeposited: vault != null ? formatNumber(formatUnits(vault['vaultInfo']['totalAssets'], lpToken['decimals']))  : '0',
          vaultIsExist: lpToken['vaultIsExist'],
          vaultPoolType: lpToken['poolType'],
          symbol: lpToken['symbol']
        }
      })
      setVaults(objects)

    } else {
      setIsFetching(true);
    }
  }, [data, setIsFetching])

  return { vaults, isFetching, page, fetchData,rowsPerPage };
}


export default useVaults