import React from "react";
import TopPlace from "../../components/TopPlace/TopPlace";
import TableBlock from "../../components/TableBlock/TableBlock";
import HowItWorksPlace from "../../components/HowItWorksPlace/HowItWorksPlace";
import classes from "../../App.module.scss";
import { motion } from "framer-motion";
import { StatesContext } from "../../App";

const MainPage = ({ handlerAuthed }) => {
  const states = React.useContext(StatesContext);
  const [isMessage, setIsMessage] = React.useState(true);
  const handlerIsMessageClose = () => {
    setIsMessage(false);
  };
  return (
    <>
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
          <TableBlock />
          <HowItWorksPlace />
        </div>
      </motion.div>
    </>
  );
};

export default MainPage;
