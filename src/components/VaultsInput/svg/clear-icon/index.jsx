import React from "react";
import classes from "./clear.icon.module.scss"

const Index = () => {
  return (
    <svg
      className={classes.clear__btn}
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M8 16L16 7.99997"
        stroke="#E5E8DF"
        strokeWidth="2"
        strokeLinecap="round"
      />
      <path
        d="M16 16L7.99997 7.99997"
        stroke="#E5E8DF"
        strokeWidth="2"
        strokeLinecap="round"
      />
    </svg>
  );
};

export default Index;
