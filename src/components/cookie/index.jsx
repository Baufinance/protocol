import React from "react";
import classes from "./cookie.module.scss";
import { motion } from "framer-motion";

const Index = ({ handlerCookieToggler }) => {
  return (
    <motion.div
      className={classes.cookie}
      initial={{ opacity: 0, right: -50 }}
      animate={{ opacity: 1, right: 24 }}
      exit={{ opacity: 0, right: -50 , transitionDuration:1}}
      transition={{ duration: 1, type: "tween" }}
    >
      <div className={classes.cookie__wrapper}>
        <div className={classes.cookie__up_block}>
          <svg
            width="50"
            height="50"
            viewBox="0 0 50 50"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <rect
              x="4.5"
              y="3.01758"
              width="45"
              height="46.4825"
              rx="22.5"
              fill="#292828"
              fillOpacity="0.6"
              stroke="#C4975E"
            />
            <path
              d="M44 22.1298C45.1046 22.1298 46.009 23.0559 45.9131 24.1917C45.6031 27.8623 44.4686 31.4182 42.5883 34.5723C40.3577 38.314 37.1649 41.3434 33.3654 43.3234C29.5659 45.3034 25.3086 46.1563 21.0674 45.7871C16.8262 45.418 12.7674 43.8412 9.34273 41.2324C5.91807 38.6236 3.26188 35.0851 1.66976 31.0106C0.0776347 26.9361 -0.387959 22.4855 0.324791 18.1541C1.03754 13.8228 2.90068 9.78046 5.70685 6.47714C8.07228 3.69264 11.0296 1.52529 14.3361 0.137374C15.3593 -0.292112 16.4832 0.326997 16.8089 1.41649C22.8437 21.607 23.231 22.1298 44 22.1298Z"
              fill="url(#paint0_radial_1237_13818)"
            />
            <ellipse
              cx="28.5"
              cy="6.13037"
              rx="1.5"
              ry="1.54834"
              fill="#EAD0AE"
            />
            <ellipse cx="29" cy="13.8721" rx="1" ry="1.03223" fill="#EAD0AE" />
            <ellipse cx="35" cy="27.291" rx="1" ry="1.03223" fill="#531F0F" />
            <ellipse cx="6" cy="22.1299" rx="1" ry="1.03223" fill="#531F0F" />
            <ellipse cx="21" cy="37.6133" rx="1" ry="1.03223" fill="#531F0F" />
            <ellipse cx="38" cy="10.7754" rx="1" ry="1.03223" fill="#EAD0AE" />
            <ellipse cx="41" cy="19.0332" rx="2" ry="2.06446" fill="#EAD0AE" />
            <ellipse cx="17" cy="27.291" rx="2" ry="2.06446" fill="#531F0F" />
            <ellipse cx="32" cy="34.5166" rx="2" ry="2.06446" fill="#531F0F" />
            <ellipse cx="12" cy="11.8076" rx="2" ry="2.06446" fill="#531F0F" />
            <defs>
              <radialGradient
                id="paint0_radial_1237_13818"
                cx="0"
                cy="0"
                r="1"
                gradientUnits="userSpaceOnUse"
                gradientTransform="translate(14 13.356) rotate(57.4884) scale(46.5142 45.9145)"
              >
                <stop stopColor="#EABA7D" />
                <stop offset="1" stopColor="#D39A50" />
              </radialGradient>
            </defs>
          </svg>
          <p className={classes.down__block_text}>
            We use cookies to ensure that we
            <br />
            give you the besy experience on
            <br />
            your website
          </p>
          <button
            type="button"
            className={classes.cookie__top_close}
            onClick={() => handlerCookieToggler()}
          >
            <svg
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="#31312f"
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
        </div>
        <div className={classes.cookie__down_block}>
          <button
            type="button"
            className={classes.down__block_left__btn}
            onClick={() => handlerCookieToggler()}
          >
            I agree
          </button>
          <button type="button" className={classes.down__block_right__btn}
          onClick={() => handlerCookieToggler()}
          >
            Decline
          </button>
        </div>
      </div>
    </motion.div>
  );
};

export default Index;
