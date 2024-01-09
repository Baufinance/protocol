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
        states.setIsDepositActiveteMSG(false)
        states.setIsDepositActiveSuccessMSG(true)
        states.setIsActivateBtn(false)
        states.setIsActivateAproveBtn(true)
      }}
    >
      {nameBtn}
    </button>
  );
};

export default Index;
