import React from "react";
import TopLeftDecor from "../../components/construction/top-left-decor";
import BottomRightDecor from "../../components/construction/bottom-right-decor";
import LogoSVG from "../../components/construction/logo";
import ConstrSVG from "../../components/construction/constr-svg";
import styles from "./construction.module.scss";
import Form from "./form";
import { motion } from "framer-motion";

const Roadmap = () => {
  return (
    <motion.div
      className={styles.constraction}
      id="construction"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1, transition: { duration: 1 } }}
    >
      <TopLeftDecor />
      <BottomRightDecor />

      <div className={styles.constraction__wrapper}>
        <LogoSVG />
        <h4 className={styles.constraction__title}>
          Low-cost yield aggregator.
          <br />
          Reduced commissions, higher profits.
          <br />
          Zap from any token.
        </h4>
        <p className={styles.construction__text}>
          The website is under construction. In the meantime, you can subscribe
          to us or learn more
          <br /> about our service
        </p>
        <Form />
      </div>
      <ConstrSVG />
    </motion.div>
  );
};

export default Roadmap;
