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

const VaultsInfoPlace = () => {
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

  return (
    <div className={classes.VaultsInfoPlace}>
      <div className={classes.InfoPlaceLeft}>
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

        {isConnected &&
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
          {toggler__btn.map((btn) => (
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
        {isActiveBtn === 1 && (
          <motion.div
            className={classes.toggler__deposit_items}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.3, ease: "easeIn" }}
          >
            <div className={classes.deposit__item}>
              <div className={classes.item__top}>
                <p className={classes.top__status}>You sell</p>
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
                <p className={classes.top__status}>You buy</p>
                <div className={classes.top__ballance}>
                  <p className={classes.ballance__text}>Balance: 0.678</p>
                </div>
              </div>
              <div className={classes.item__medium}>
                <div className={classes.medium__name_}>
                  <div className={classes.name__icon}>
                    <svg
                      width="32"
                      height="32"
                      viewBox="0 0 32 32"
                      fill="none"
                      xmlns="http://www.w3.org/2000/svg"
                      xmlnsXlink="http://www.w3.org/1999/xlink"
                    >
                      <rect width="32" height="32" rx="16" fill="#E5E8DF" />
                      <rect
                        x="5"
                        y="5"
                        width="22"
                        height="22"
                        fill="url(#pattern0)"
                      />
                      <defs>
                        <pattern
                          id="pattern0"
                          patternContentUnits="objectBoundingBox"
                          width="1"
                          height="1"
                        >
                          <use
                            xlinkHref="#image0_1_4985"
                            transform="scale(0.00444444)"
                          />
                        </pattern>
                        <image
                          id="image0_1_4985"
                          width="225"
                          height="225"
                          xlinkHref="data:image/png;base64,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"
                        />
                      </defs>
                    </svg>
                  </div>
                  <div className={classes.medium__text}>DYDX-ETH</div>
                </div>
                <p
                  // type="text"
                  className={classes.medium__count}
                  // placeholder="21"
                  // value={isCountValue2}
                  // onChange={(e) => setIsCountValue2(e.target.value)}
                >0.21</p>
              </div>
              <div className={classes.item__bottom}>
                <div className={classes.bottom__name}>Curve</div>
                <div className={classes.bottom__cash}>
                  <span className={classes.bottom__cash}>~$</span>
                  <span className={classes.bottom__cash}>1.849,06</span>
                </div>
              </div>
            </div>

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
          </motion.div>
        )}
        {isActiveBtn === 2 && (
          <motion.div
            className={classes.toggler__deposit_items}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.3, ease: "easeIn" }}
          >
            <div className={classes.deposit__item}>
              <div className={classes.item__top}>
                <p className={classes.top__status}>You sell</p>
                <div className={classes.top__ballance}>
                  <p className={classes.ballance__text}>Balance: {ballanceWithdraw}</p>
                  <button type="button"
                   className={classes.ballance__coast}
                    onClick={()=>{
                    setIsCountValueWithdraw(ballanceWithdraw)
                  }}
                   >max</button>
                </div>
              </div>

              <div className={classes.item__medium}>
                <div className={classes.medium__name } onClick={() => states.handlerDepositInfo()}>
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
                  value={isCountValueWithdraw}
                  onChange={(e) => setIsCountValueWithdraw(e.target.value)}
                />
              </div>

              <div className={classes.item__bottom}>
                <div className={classes.bottom__name}>Ethereum</div>
                <div className={classes.bottom__cash}>
                  <span className={classes.bottom__cash}>~$</span>
                  <span className={classes.bottom__cash}>1.849,06</span>
                </div>
                {states.isDepositItemActive && <VaultsDepositList />}
              </div>
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
                <p className={classes.top__status}>You buy</p>
                <div className={classes.top__ballance}>
                  <p className={classes.ballance__text}>Balance: 0.678</p>

                </div>

              </div>
              <div className={classes.item__medium}>
                <div className={classes.medium__name_}>
                  <div className={classes.name__icon}>
                    <svg
                      width="32"
                      height="32"
                      viewBox="0 0 32 32"
                      fill="none"
                      xmlns="http://www.w3.org/2000/svg"
                      xmlnsXlink="http://www.w3.org/1999/xlink"
                    >
                      <rect width="32" height="32" rx="16" fill="#E5E8DF" />
                      <rect
                        x="5"
                        y="5"
                        width="22"
                        height="22"
                        fill="url(#pattern0)"
                      />
                      <defs>
                        <pattern
                          id="pattern0"
                          patternContentUnits="objectBoundingBox"
                          width="1"
                          height="1"
                        >
                          <use
                            xlinkHref="#image0_1_4985"
                            transform="scale(0.00444444)"
                          />
                        </pattern>
                        <image
                          id="image0_1_4985"
                          width="225"
                          height="225"
                          xlinkHref="data:image/png;base64,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"
                        />
                      </defs>
                    </svg>
                  </div>
                  <div className={classes.medium__text}>DYDX-ETH</div>
                </div>
                <p
                  className={classes.medium__count}
                >0.4281</p>
              </div>
              <div className={classes.item__bottom}>
                <div className={classes.bottom__name}>Curve</div>
                <div className={classes.bottom__cash}>
                  <span className={classes.bottom__cash}>~$</span>
                  <span className={classes.bottom__cash}>1.849,06</span>
                </div>
              </div>
            </div>
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
          </motion.div>
        )}
        {isRouteInfo && (
          <motion.div
            className={classes.route__info}
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.3, ease: "linear" }}
          >
            <div className={classes.route__info_string}>
              <p className={classes.route__info_string__name}>1. 1INCH price</p>
              <p className={classes.route__info_string__descr}>
                Price is unknown
              </p>
            </div>
            <div className={classes.route__info_string}>
              <p className={classes.route__info_string__name_}>
                2. 1FIDU price
              </p>
              <p className={classes.route__info_string__descr_}>
                ~$1.849,06 2.828418 1INCH
              </p>
            </div>
            <div className={classes.route__info_string}>
              <p className={classes.route__info_string__name_}>Network Fee</p>
              <p className={classes.route__info_string__descr_}>
                Market ~$1.849
              </p>
            </div>
          </motion.div>
        )}
        {states.isDepositBtn && <DepositButton nameBtn="deposit" />}
        {states.isActivateBtn && <ActivateButton nameBtn="Activate" />}
        {states.isActivateAproveBtn && (
          <ActivateAproveButton nameBtn="Activate approve and deposit" />
        )}
        {states.isAproveBtn && <AproveButton nameBtn="Approve and deposit" />}
      </div>
    </div>
  );
};

export default VaultsInfoPlace;
