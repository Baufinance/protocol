import React from "react";
import classes from "./submited.info.module.scss";
import { StatesContext } from "../../App";
import submitedTimer from "../../images/issubmited-timer-image.png";

const Index = () => {
  const states = React.useContext(StatesContext);

  return (
    <div
      className={classes.submitedInfo__overflow}
      onClick={() => states.hanlerSubmitedInfo()}
    >
      <div
        className={classes.submitedInfo__wrapper}
        onClick={(e) => e.stopPropagation()}
      >
        <button
          type="button"
          className={classes.submitedInfo__close_tr}
          onClick={() => {
            states.hanlerSubmitedInfo();
          }}
        >
          <svg
            width="24"
            height="24"
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
        </button>
        <img
          src={submitedTimer}
          className={classes.submitedInfo__timer}
          alt="submited timer"
        />
        <h4 className={classes.submitedInfo__title}>Transaction submitted</h4>
        <p className={classes.submitedInfo__subtitle}>
          View on <span> Etherscan</span>
        </p>
        <button
          type="button"
          className={classes.submitedInfo__close}
          onClick={() => {
            states.hanlerSubmitedInfo();
           states.setIsDepositActiveteMSG(true)
          }}
        >
          Close
        </button>
      </div>
    </div>
  );
};

export default Index;
