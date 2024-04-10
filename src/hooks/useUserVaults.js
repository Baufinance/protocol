import { useState, useEffect } from 'react';
import { useQuery } from '@apollo/client';
import {GET_USER_VAULTS} from '../queries/index.js'
import { formatUnits } from 'viem'
import { formatNumber } from '../utils/formattingUtils.jsx';

const useUserVaults = (account, initialPage, rowsPerPage) => {
  const [userVaults, setUserVaults] = useState([]);

  const [page, setPage] = useState(initialPage);
  const [isFetching, setIsFetching] = useState(false);

  const { data } = useQuery(GET_USER_VAULTS, {
    variables: {
      account:account,
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
    setUserVaults(null)
    setPage(page)
  }

  useEffect(() => {
    if (data) {
      const objects = data.userDeposits.map(function(data, index) {

        const vaultArr = data.vault
        const lpBreakDownSource = vaultArr.lpBreakDownSource

        const vault = lpBreakDownSource["vault"]
        const lpToken = lpBreakDownSource["lpToken"]

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
      setUserVaults(objects)
    } else {
      setIsFetching(true);
    }
  }, [data, setIsFetching])

  return { userVaults, isFetching, page, fetchData,rowsPerPage };
}


export default useUserVaults