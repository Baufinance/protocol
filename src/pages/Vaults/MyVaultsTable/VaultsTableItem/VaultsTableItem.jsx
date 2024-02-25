import React from "react";
import classes from "./VaultsTableItem.module.scss";
import activevaulst from "../../../../images/activevaults.svg";
import Curve from "../../../../images/logo-coin.svg";
import Velo from "../../../../images/velo-coin.svg";
import { motion } from "framer-motion";

function VaultsTableItem({vaultName}) {
  const [isCheckboxHover, setIsCheckboxHover] = React.useState(false);
  return (
    <motion.div
      className={classes.VaultsTableItem}
      onMouseLeave={() => setIsCheckboxHover(false)}
    >
      <div className={classes.nameVault}>
        <motion.img
          className={classes.vaultStatus}
          src={activevaulst}
          alt=""
          whileHover={() => setIsCheckboxHover(true)}
        />
        <img className={classes.vaultsLogo} src={Velo} alt="" />
        <p className={classes.vaultName}>{vaultName}</p>
      </div>
      <div className={classes.APUYalue}>6.53%</div>
      <div className={classes.APYWeek}>6.53%</div>
      <div className={classes.DepositedValue}>100 LP Tokens</div>
      <div className={classes.TVLValue}>$ 420, 441</div>
      {isCheckboxHover && (
        <motion.div className={classes.hover__block}>
          <svg
            width="54"
            height="39"
            className={classes.arrow__figure}
            viewBox="0 0 54 39"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <g filter="url(#filter0_d_4_4281)">
              <path
                d="M26.6888 6L14.2803 17H39.0973L26.6888 6Z"
                fill="#272726"
              />
              <path
                d="M26.6888 6.66818L37.7796 16.5H15.598L26.6888 6.66818Z"
                stroke="#737373"
              />
            </g>
            <defs>
              <filter
                id="filter0_d_4_4281"
                x="0.280273"
                y="0"
                width="52.8174"
                height="39"
                filterUnits="userSpaceOnUse"
                colorInterpolationFilters="sRGB"
              >
                <feFlood floodOpacity="0" result="BackgroundImageFix" />
                <feColorMatrix
                  in="SourceAlpha"
                  type="matrix"
                  values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
                  result="hardAlpha"
                />
                <feOffset dy="8" />
                <feGaussianBlur stdDeviation="7" />
                <feComposite in2="hardAlpha" operator="out" />
                <feColorMatrix
                  type="matrix"
                  values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.16 0"
                />
                <feBlend
                  mode="normal"
                  in2="BackgroundImageFix"
                  result="effect1_dropShadow_4_4281"
                />
                <feBlend
                  mode="normal"
                  in="SourceGraphic"
                  in2="effect1_dropShadow_4_4281"
                  result="shape"
                />
              </filter>
            </defs>
          </svg>
          Active vault. Read more in <span>documentation</span>.
        </motion.div>
      )}
    </motion.div>
  );
}

export default VaultsTableItem;
