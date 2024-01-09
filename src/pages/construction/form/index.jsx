import React from "react";
import styles from "./form.module.scss";
import { Link } from "react-router-dom";
import { motion } from "framer-motion";

const Index = () => {
  const [isSend, setIsSend] = React.useState(false);
  const [isSendError, setIsSendError] = React.useState(false);
  const [isEmailValue, setIsEmailValue] = React.useState("");
  const users = []
console.log(users);
  const handlerOnsubmit = (e) => {
    e.preventDefault();
    if (isEmailValue.length <= 1) {
      setIsSend(!isSend);
      setIsSendError(true);
    }
  };
  return (
    <div className={styles.construction__navigation}>
      <form
        className={styles.navigation__form}
        onSubmit={(e) => handlerOnsubmit(e)}
      >
        <div className={styles.form__wrapper}>
          <input
            type="email"
            className={styles.form__input}
            placeholder="Your mail"
            value={isEmailValue}
            onChange={(e) => {
              setIsSendError(false);
              setIsEmailValue(e.target.value)}}
          />
          <button type="submit" className={styles.form__button}>
            Learn about opening
          </button>
        </div>
        {isSendError && (
          <motion.span
            className={styles.error__text}
            initial={{ opacity: 0, left: -150 }}
            animate={{ opacity: 1, left: 0 }}
            transition={{ duration: 1 }}
          >
            Learn about opening
          </motion.span>
        )}
      </form>
      <Link href="#" className={styles.github__wrapper}>
        <span className={styles.github__link}>
          <span className={styles.link__text}>Github</span>
          <svg
            width="32"
            height="32"
            className={styles.link__arrow}
            viewBox="0 0 32 32"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M9.79387 20.792C9.40335 21.1825 9.40335 21.8157 9.79387 22.2062C10.1844 22.5967 10.8176 22.5967 11.2081 22.2062L9.79387 20.792ZM22.4992 10.5009C22.4992 9.9486 22.0515 9.50089 21.4992 9.50088L12.4992 9.50089C11.9469 9.50089 11.4992 9.9486 11.4992 10.5009C11.4992 11.0532 11.9469 11.5009 12.4992 11.5009L20.4992 11.5009L20.4992 19.5009C20.4992 20.0532 20.9469 20.5009 21.4992 20.5009C22.0515 20.5009 22.4992 20.0532 22.4992 19.5009L22.4992 10.5009ZM11.2081 22.2062L22.2063 11.208L20.7921 9.79378L9.79387 20.792L11.2081 22.2062Z"
              fill="#E5E8DF"
            />
          </svg>
        </span>
        <span className={styles.github__text}>More</span>
      </Link>
    </div>
  );
};

export default Index;
