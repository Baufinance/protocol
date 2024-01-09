import React from "react";
import classes from "./VaultsInfo.module.scss";
import VaultsInfoHeader from "../../components/VaultsInfoHeader/VaultsInfoHeader";
import VaultsInfoPlace from "../../components/VaultsInfoPlace/VaultsInfoPlace";
import { motion } from "framer-motion";
import { StatesContext } from "../../App";
import NoActiveMsg from "../../components/noactive-msg";
import ActiveMsg from "../../components/active-msg";

const VaultsInfo = () => {
  const states = React.useContext(StatesContext);

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
    <motion.div
      className={classes.VaultsInfo}
      initial={{ opacity: 0 }}
      animate={{ opacity: 1, transition: { duration: 1 } }}
      onClick={() => states.handlerCloseOutsideDepositInfo()}
      id="vaultsinfo"
    >
      <VaultsInfoHeader />
      {states.isDepositActiveteMSG && <NoActiveMsg />}
      {states.isDepositActiveteSuccessMSG && <ActiveMsg />}

      <VaultsInfoPlace />
    </motion.div>
  );
};

export default VaultsInfo;
