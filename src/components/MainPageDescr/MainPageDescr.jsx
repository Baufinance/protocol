import React from "react";
import classes from "./MainPageDescr.module.scss";
import DescriptionItemPlace from "./DescriptionItemsPlace/DescriptionItemPlace";
import { Link } from "react-router-dom";
import CloseIcon from "../../components/MainPageDescr/svg/close-icon";
import { motion } from "framer-motion";

const MainPageDescr = ({
  handlerOpenAuthWallet,
  handlerIsMessageClose,
  isMessage,
}) => {
  return (
    <div className={classes.mainPageDescr}>
      {isMessage && (
        <motion.div
          className={classes.descrPlace}
          animate={{
            opacity: isMessage ? 1 : 0,
          }}
          transition={{ duration: 5, ease: "backInOut" }}
        >
          <div className={classes.descrPlaceText}>
            <div className={classes.descrPlaceTextTitle}>
              BAU uses novel technology and using it involes a variety of risks.
            </div>
            <div className={classes.descrPlaceTextBody}>
              You understand and agree to assume full assume full responsibility
              for all of the risks of accessing <br />
              and using the inteface to interface to interact wirh the protocol.{" "}
              <span>
                <Link href="#">Learn more</Link>
              </span>
            </div>
          </div>
          <button
            className={classes.descrPlaceButton}
            onClick={() => {
              handlerIsMessageClose();
            }}
          >
            <CloseIcon />
          </button>
        </motion.div>
      )}
      <DescriptionItemPlace />
      <div className={classes.DescrPlaceBottom}>
        <div className={classes.MainPageDescrTitle}>
          Low-cost yield aggregator. Lower commissions, higher <br></br>{" "}
          profits. Zap from any token.
        </div>
        <div className={classes.MainPageDescrButton}>
          <a href={"#TableHeaderButtons"} className={classes.LearnMoreButton}>
            Learn More
          </a>
        </div>
      </div>
    </div>
  );
};

export default MainPageDescr;
