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
        states.hanlerSubmitedInfo();
        states.setIsDepositBtn(false)
        states.setIsActivateBtn(true)
      }}
    >
      {nameBtn}
    </button>
  );
};

export default Index;
