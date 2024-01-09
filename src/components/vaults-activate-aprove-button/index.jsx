import React from "react";
import classes from "./vaults.deposite.button.module.scss";
import { StatesContext } from "../../App";

const Index = ({ nameBtn }) => {
  const states = React.useContext(StatesContext);
  return (
    <button
      type="button"
      className={classes.approve__btn}
      onClick={() => {
        states.setIsDepositActiveSuccessMSG(false)
        states.setIsActivateAproveBtn(false)
        states.setIsAproveBtn(true)
      }}
    >
      {nameBtn}
    </button>
  );
};

export default Index;
