import React from "react";
import classes from "./VaultsInfoPlace.module.scss";
import strategy from "../../images/strategy.svg";
import { motion } from "framer-motion";
import { Link } from "react-router-dom";
import { StatesContext } from "../../App.jsx";
import DepositButton from "../../components/vaults-deposite-button";
import ActivateButton from "../../components/vaults-activate-button";
import ActivateAproveButton from "../../components/vaults-activate-aprove-button";
import AproveButton from "../../components/vaults-aprove-button";
import VaultsDepositList from "./vaults-deposit-list";
import { useAccount } from "wagmi";
import Curve from "../../images/logo-coin.svg";
import Velo from "../../images/velo-coin.svg";

import ActiveMsg from "../../components/active-msg";

const VaultsInfoPlace = ({item}) => {
  const states = React.useContext(StatesContext);

  const {isConnected, address} = useAccount()

  const [isActiveBtn, setIaActiveBtn] = React.useState(1);
  const [isRouteInfo, setIsRouteInfo] = React.useState(false);
  const [isCountValue, setIsCountValue] = React.useState("");
  const [isCountValueWithdraw, setIsCountValueWithdraw] = React.useState("");

  const toggler__btn = [
    { id: 1, name__btn: "Deposit", isActive: 1 },
    { id: 2, name__btn: "Withdraw", isActive: 2 },
  ];

  const handlerTogglerBtn = (btnId) => {
    switch (btnId) {
      case btnId:
        return setIaActiveBtn(btnId);
      default:
        return;
    }
  };
  const handlerTogglerRouteInfo = () => setIsRouteInfo(!isRouteInfo);

  const ballance = states.isBallance;
  const ballanceWithdraw = states.isBallanceWithdraw;


  console.log(item.vaultIsExist)

  return (
    <div className={classes.VaultsInfoPlace}>
      <div className={classes.InfoPlaceLeft}>
        {item.vaultIsExist &&
        <div className={classes.APYwidget}>
          {states.isDepositItemActive && (
            <div className={classes.vaults__info_place__shadow}></div>
          )}
          <div className={classes.APYwidgetTitle}>APY</div>
          <div className={classes.APYwidgetBody}>
            <div className={classes.APYwidgetBodyItem}>
              <div className={classes.BodyItemTitle}>Last harvest APY</div>
              <div className={classes.BodyItemValue}>7%</div>
            </div>
            <div className={classes.APYwidgetBodyItem}>
              <div className={classes.BodyItemTitle}>Weeky</div>
              <div className={classes.BodyItemValue}>5%</div>
            </div>
            <div className={classes.APYwidgetBodyItem}>
              <div className={classes.BodyItemTitle}>Monthly</div>
              <div className={classes.BodyItemValue}>9%</div>
            </div>
          </div>
        </div>
        }

        {isConnected && item.vaultIsExist &&
          <>
        <div className={classes.PositionWidget}>
          {states.isDepositItemActive && (
            <div className={classes.vaults__info_place__shadow}></div>
          )}
          <div className={classes.PositionWidgetHeader}>
            <div className={classes.PositionWidgetHeaderTitle}>
              Your position
            </div>
            <div className={classes.countShares}>Vault shares - 8 </div>
          </div>
          <div className={classes.PositionWidgetBody}>
            <div className={classes.WidgetBodyRow}>
              <div className={classes.WidgetBodyRowTitle}>Curve COILFRAX-f</div>
              <div className={classes.WidgetCoinName}>12.865 LP</div>
              <div className={classes.WidgetPrice}>$568</div>
              <div className={classes.growPercent}>&nbsp;</div>
            </div>
            <div className={classes.WidgetBodyRow}>
              <div className={classes.WidgetBodyRowTitle}>Earned</div>
              <div className={classes.WidgetCoinName}>1.325 LP</div>
              <div className={classes.WidgetPrice}>$25</div>
              <div className={classes.growPercent}> +5%;</div>
            </div>
            <div className={classes.WidgetBodyRow}>
              <div className={classes.WidgetBodyRowTitle}>
                Last harvest earnings
              </div>
              <div className={classes.WidgetCoinName}>0.015 LP</div>
              <div className={classes.WidgetPrice}>$3</div>
              <div className={classes.growPercent}>+0.03%</div>
            </div>
            <div className={classes.WidgetBodyRow}>
              <div className={classes.WidgetBodyRowTitle}>Underlying</div>
              <div className={classes.WidgetCoinName}>67 DYDX</div>
              <div className={classes.WidgetPrice}>0,2 ETH</div>
              <div className={classes.growPercent}>&nbsp;</div>
            </div>
          </div>
        </div>
        </>
        }

        {item.vaultIsExist &&
        <div className={classes.widgetBreakDown}>
          {states.isDepositItemActive && (
            <div className={classes.vaults__info_place__shadow}></div>
          )}
          <div className={classes.BreackDownTitle}>LP Breakdown</div>
          <div className={classes.BreackDownBody}>
            <div className={classes.BreackDownRow}>
              <div className={classes.BreackDownRowTitle}>Price per 1LP</div>
              <div className={classes.BreackDownRowPrice}>$ 568</div>
              <div className={classes.BreackDownCount}></div>
            </div>
            <div className={classes.BreackDownRow}>
              <div className={classes.BreackDownRowTitle}>Tokens per 1 LPP</div>
              <div className={classes.BreackDownRowPrice}>3 DYDX</div>
              <div className={classes.BreackDownCount}>0.001 ETH</div>
            </div>
            <div className={classes.BreackDownRow}>
              <div className={classes.BreackDownRowTitle}>Total pool TVL</div>
              <div className={classes.BreackDownRowPrice}>$ 20 M.</div>
              <div className={classes.BreackDownCount}></div>
            </div>
          </div>
        </div>
        }
        <div className={classes.StrategyWidget}>
          {states.isDepositItemActive && (
            <div className={classes.vaults__info_place__shadow}></div>
          )}
          <img src={strategy} alt="" />
        </div>
      </div>


      <div className={classes.InfoPlaceRight}>
        {states.isDepositItemActive && (
          <div className={classes.vaults__info_place__shadow}></div>
        )}


        <div className={classes.toggler__top}>
          {item.vaultIsExist && toggler__btn.map((btn) => (
            <button
              key={btn.id}
              type="button"
              className={
                isActiveBtn === btn.isActive
                  ? classes.toggler__top_button__active
                  : classes.toggler__top_button
              }
              onClick={() => handlerTogglerBtn(btn.id)}
            >
              {btn.name__btn}
            </button>
          ))}
        </div>

        {!item.vaultIsExist &&
          <ActiveMsg/>
        }
        {item.vaultIsExist && isActiveBtn === 1 && (
          <motion.div
            className={classes.toggler__deposit_items}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.3, ease: "easeIn" }}
          >
            <div className={classes.deposit__item}>
              <div className={classes.item__top}>
                <p className={classes.top__status}>You deposit</p>
                <div className={classes.top__ballance}>
                  <p className={classes.ballance__text}>Balance: {ballance}</p>
                  <button type="button" className={classes.ballance__coast}
                  onClick={()=>{
                    setIsCountValue(ballance)
                  }}
                  >
                    max
                  </button>
                </div>
              </div>

              <div className={classes.item__medium}>
                <div
                  className={classes.medium__name}
                  onClick={() => states.handlerDepositInfo()}
                >
                  <div className={classes.name__icon}>
                    <svg
                      width="32"
                      height="32"
                      viewBox="0 0 32 32"
                      fill="none"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <rect width="32" height="32" rx="16" fill="white" />
                      <path
                        d="M15.998 2.00012L15.8086 2.6382V21.1522L15.998 21.3396L24.6619 16.2598L15.998 2.00012Z"
                        fill="#343434"
                      />
                      <path
                        d="M15.9981 2.00012L7.33398 16.2598L15.9981 21.3396V12.3535V2.00012Z"
                        fill="#8C8C8C"
                      />
                      <path
                        d="M15.9974 22.9667L15.8906 23.0958V29.6908L15.9974 29.9999L24.6666 17.8895L15.9974 22.9667Z"
                        fill="#3C3C3B"
                      />
                      <path
                        d="M15.9981 29.9999V22.9667L7.33398 17.8895L15.9981 29.9999Z"
                        fill="#8C8C8C"
                      />
                      <path
                        d="M15.998 21.3397L24.662 16.2598L15.998 12.3535V21.3397Z"
                        fill="#141414"
                      />
                      <path
                        d="M7.33398 16.2598L15.9981 21.3397V12.3535L7.33398 16.2598Z"
                        fill="#393939"
                      />
                    </svg>
                  </div>
                  <div className={classes.medium__text}>ETH</div>
                  <div className={classes.medium__arr_toggler}>
                    <svg
                      width="24"
                      height="24"
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
                    </svg>
                  </div>
                </div>
                <input
                  type="text"
                  className={classes.medium__count}
                  placeholder="1"
                  value={isCountValue}
                  onChange={(e) => setIsCountValue(e.target.value)}
                />
              </div>
              <div className={classes.item__bottom}>
                <div className={classes.bottom__name}>Ethereum</div>
                <div className={classes.bottom__cash}>
                  <span className={classes.bottom__cash}>~$</span>
                  <span className={classes.bottom__cash}>1.849,06</span>
                </div>
              </div>
              {states.isDepositItemActive && <VaultsDepositList />}
            </div>

            <span className={classes.item__arrow_between}>
              <svg
                width="16"
                height="16"
                viewBox="0 0 16 16"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M9 2C9 1.44772 8.55228 1 8 1C7.44772 1 7 1.44772 7 2L9 2ZM7.29289 14.7071C7.68342 15.0976 8.31658 15.0976 8.70711 14.7071L15.0711 8.34315C15.4616 7.95262 15.4616 7.31946 15.0711 6.92893C14.6805 6.53841 14.0474 6.53841 13.6569 6.92893L8 12.5858L2.34315 6.92893C1.95262 6.53841 1.31946 6.53841 0.928932 6.92893C0.538408 7.31946 0.538408 7.95262 0.928932 8.34315L7.29289 14.7071ZM7 2L7 14L9 14L9 2L7 2Z"
                  fill="#737373"
                />
              </svg>
            </span>


            <div className={classes.deposit__item}>


              <div className={classes.item__top}>
                <p className={classes.top__status}>You zap</p>
                {/*
                <div className={classes.top__ballance}>
                  <p className={classes.ballance__text}>Balance: 0.678</p>
                </div>
                */}
              </div>
              <div className={classes.item__medium}>
                <div className={classes.medium__name_}>
                  <div className={classes.name__icon}>
                  <img src={item.vaultPoolType == 'Curve'? Curve : Velo} className={classes.Curve} alt="" />
                  </div>
                  <div className={classes.medium__text}>{item.vaultName}</div>
                </div>
                <p
                  // type="text"
                  className={classes.medium__count}
                  // placeholder="21"
                  // value={isCountValue2}
                  // onChange={(e) => setIsCountValue2(e.target.value)}
                >0.21</p>
              </div>
              {/*
              <div className={classes.item__bottom}>
                <div className={classes.bottom__name}>Curve</div>
                <div className={classes.bottom__cash}>
                  <span className={classes.bottom__cash}>~$</span>
                  <span className={classes.bottom__cash}>1.849,06</span>
                </div>
              </div>
              */}
            </div>


            {/*
            <div
              className={classes.route__item}
              onClick={handlerTogglerRouteInfo}
            >
              <p className={classes.route__item_text}>Route</p>
              <motion.svg
                width="24"
                height="24"
                animate={{ rotate: isRouteInfo ? "-180deg" : "0deg" }}
                transition={{ duration: 0.2, ease: "easeInOut" }}
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
            </div>
            */}
          </motion.div>
        )}



        {/*states.isDepositBtn && <DepositButton nameBtn="deposit" />*/}
        {!item.vaultIsExist && <ActivateButton nameBtn="Activate" />}

        {/*states.isActivateAproveBtn && (
          <ActivateAproveButton nameBtn="Activate approve and deposit" />
        )*/}
        {item.vaultIsExist && <AproveButton nameBtn="Approve and deposit" />}
      </div>
    </div>
  );
};

export default VaultsInfoPlace;
