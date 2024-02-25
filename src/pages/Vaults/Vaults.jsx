import React from "react";
import classes from "./Vaults.module.scss";
import VaultsInput from "../../components/VaultsInput/VaultsInput";
import VaultsTable from "./VaultsTable/VaultsTable";
import MyVaultsTable from "./MyVaultsTable/VaultsTable";
import { motion } from "framer-motion";
import NotFound from "../../components/not-found";
import { StatesContext } from "../../App";

const Vaults = () => {
  const { isNotFound, setIsVaultsToggle, isBtnActive } =
    React.useContext(StatesContext);



  const handlerVaultToggler = (vaultsNamber) => {
    if (vaultsNamber === "all vaults") {
      setIsVaultsToggle("all vaults");
    } else {
      setIsVaultsToggle("my vaults");
    }
  };


  React.useEffect(() => {
    const vaultsinfoId = document.getElementById("vaults");
    if (vaultsinfoId)
      window.scrollTo({
        top: 0,
        left: 0,
        behavior: "smooth",
      });
  }, []);

  return (
    <motion.div
      className={classes.Vaults}
      initial={{ opacity: 0 }}
      animate={{ opacity: 1, transition: { duration: 1 } }}
      id="vaults"
      onClick={() => {}}
    >

      <VaultsInput handlerVaultToggler={handlerVaultToggler} />
      {isBtnActive === "001" && !isNotFound && <VaultsTable />}
      {isBtnActive === "002" && !isNotFound && <MyVaultsTable />}
      {isNotFound && <NotFound />}
    </motion.div>
  );
};

export default Vaults;
