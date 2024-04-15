import React from "react";
import classes from "./VaultsInfo.module.scss";
import VaultsInfoHeader from "../../components/VaultsInfoHeader/VaultsInfoHeader";
import VaultsInfoPlace from "../../components/VaultsInfoPlace/VaultsInfoPlace";
import { motion } from "framer-motion";
import { StatesContext } from "../../App";
import NoActiveMsg from "../../components/noactive-msg";
import ActiveMsg from "../../components/active-msg";
import {useParams} from 'react-router-dom';
import useVault from "../../hooks/useVault";
import {Helmet} from "react-helmet";

const VaultsInfo = () => {
  const states = React.useContext(StatesContext);

  const {address} = useParams()

  let {vault} = useVault(address)

  console.log(vault)
  React.useEffect(() => {
    const vaultsinfoId = document.getElementById("vaultsinfo");
    if (vaultsinfoId)
      window.scrollTo({
        top: 0,
        left: 0,
        behavior: "smooth",
      });
  }, []);

  return (
    <>
        <Helmet>
        <title> {vault.length > 0 ? vault[0]['vaultName'] : ''} | BAU</title>
    </Helmet>
    <motion.div
      className={classes.VaultsInfo}
      initial={{ opacity: 0 }}
      animate={{ opacity: 1, transition: { duration: 1 } }}
      onClick={() => states.handlerCloseOutsideDepositInfo()}
      id="vaultsinfo"
    >
      <VaultsInfoHeader  item={vault.length > 0 ? vault[0] : []}/>
      <VaultsInfoPlace item={vault.length > 0 ? vault[0] : []}/>
    </motion.div>
    </>
  );
};

export default VaultsInfo;
