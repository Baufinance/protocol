import React from "react";
import classes from "./auth.wallet.module.scss";
import { StatesContext } from "../../App";

const Index = ({ handlerOpenAuthWallet }) => {
  const states = React.useContext(StatesContext);
  
  return (
    <div className={classes.OpenAuthWalletOverview}
    onClick={()=>{states.setIsOpenAuthWallet(false)}}
    >
    <div className={classes.OpenAuthWallet} onClick={(e)=>{
      e.stopPropagation()
      states.handlerAuthed()
    }}>
      <button
        type={classes.button}
        className={classes.closeBtn}
        onClick={(e) => 
          
          {
            e.stopPropagation()
            handlerOpenAuthWallet()}}
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
      <span className={classes.wallet__image} />
    </div>
    </div>
  );
};

export default Index;
