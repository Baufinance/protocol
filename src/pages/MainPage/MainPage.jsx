import React from "react";
import TopPlace from "../../components/TopPlace/TopPlace";
import TableBlock from "../../components/TableBlock/TableBlock";
import VaultsTable from "../Vaults/VaultsTable/VaultsTable";
import HowItWorksPlace from "../../components/HowItWorksPlace/HowItWorksPlace";
import classes from "../../App.module.scss";
import { motion } from "framer-motion";
import { StatesContext } from "../../App";
import { Helmet } from "react-helmet";

const MainPage = ({ handlerAuthed }) => {
  const states = React.useContext(StatesContext);
  const [isMessage, setIsMessage] = React.useState(true);
  const handlerIsMessageClose = () => {
    setIsMessage(false);
  };
  return (
    <>
      <Helmet>
        <title>Main | BAU</title>
      </Helmet>
      <motion.div
        className={classes.App}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1, transition: { duration: 1 } }}
      >
        <div className={classes.appContainer}>
          <TopPlace
          handlerOpenAuthWallet={states.handlerOpenAuthWallet}
          handlerIsMessageClose={handlerIsMessageClose}
          isMessage={isMessage}
          />
          <VaultsTable/>
          <HowItWorksPlace />
        </div>

      </motion.div>
    </>
  );
};

export default MainPage;
