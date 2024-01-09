import React from "react";
import classes from "./active.msg.module.scss";

const Index = () => {
  return (
    <p className={classes.vault__active}>
      This vault has not been activated yet, make a deposit to this vault to
      activate it
    </p>
  );
};

export default Index;
