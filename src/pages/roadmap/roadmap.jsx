import React from "react";
import styles from "./roadmap.module.scss";
import Slider from "./slider-2";
import { motion } from "framer-motion";

const Roadmap = () => {
  React.useEffect(() => {
    const appWrapperSelector = document.querySelector(".app-wrapper");
    appWrapperSelector.style.overflow = "hidden";
  });

  return (
    <motion.div
      className={styles.roadmap__wrapper}
      initial={{ opacity: 0 }}
      animate={{ opacity: 1, transition: { duration: 1 } }}
      id="roadmap"
    >
      <h4 className={styles.roadmap__title}>roadmap</h4>
      <p className={styles.roadmap__text}>
        We continue to develop and therefore here you can see what we have in
        our plans for the near future
      </p>
      <Slider />
    </motion.div>
  );
};

export default Roadmap;
