import React from "react";
import classes from "./commision.module.scss";
import { easeIn, motion } from "framer-motion";

const Index = () => {
  const [isIconRotate, setIsIconRotate] = React.useState(false);
  const [isSelectActive, setIsSelectActive] = React.useState(false);
  const [isOption, setIsOption] = React.useState(5);

  const selectOptions = [
    { id: "001", procent: "5" },
    { id: "002", procent: "10" },
    { id: "003", procent: "15" },
    { id: "004", procent: "20" },
  ];

  return (
    <div className={classes.percentDropDown}>
      <p className={classes.percentDropDownTitle}>Commission</p>
      <div
        className={
          !isIconRotate
            ? classes.percentDropDownSelect
            : classes.percentDropDownSelect_active
        }
        onClick={() => {
          setIsIconRotate(!isIconRotate);
          setIsSelectActive(!isSelectActive);
        }}
      >
        <span>{isOption}%</span>
        <motion.svg
          width="24"
          height="24"
          animate={{ rotate: isIconRotate ? -180 : 0 }}
          transition={{ duration: 0.3 }}
          viewBox="0 0 24 24"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M6 9L12 15L18 9"
            stroke="#E5E8DF"
            strokeWidth="2"
            strokeLinecap="round"
          />
        </motion.svg>

        {isSelectActive && (
          <div className={classes.percentDropDownList}>
            {selectOptions.map((opt) => (
              <span 
              key={opt.id} 
              className={classes.percentDropDownListItem}
              onClick={()=>{
                setIsOption(opt.procent)
              }}
              >
                {opt.procent} %
              </span>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Index;
