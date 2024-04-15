import React from "react";
import classes from "./noactive.msg.module.scss";

const Index = () => {
  return (
    <p className={classes.vault__notactive}>
      This vault has not been activated yet
    </p>
  );
};

export default Index;
