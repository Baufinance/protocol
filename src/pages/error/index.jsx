import React from "react";
import TopLeftDecor from "./top-left-decor";
import BottomRightDecor from "./bottom-right-decor";
import ConstrSVG from "./constr-svg";
import styles from "./error.module.scss";
import { motion } from "framer-motion";
// import Header from "../../components/Header/Header";
// import Footer from "../../components/Footer/Footer";
import { Link } from "react-router-dom";

const ErrorPage = () => {
  return (
    <motion.div
      className={styles.constraction}
      // id="construction"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1, transition: { duration: 1 } }}
    >
      <TopLeftDecor />
      <BottomRightDecor />
      <ConstrSVG />
      <div className={styles.constraction__wrapper}>
        <h4 className={styles.constraction__title}>
        Page not found
        </h4>
        <p className={styles.construction__text}>
        We can’t find the page that you’re looking for
        </p>
        <Link to="/vaults">View all Vaults</Link>
      </div>
      
    </motion.div>
  );
};

export default ErrorPage;
