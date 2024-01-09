import React from "react";
import { Link } from "react-router-dom";
import classes from "./TableBlock.module.scss";
import "./Button.scss";
import TableBlockItem from "./TableBlockItem/TableBlockItem";
import arrowButton from "../../images/menu-arrow.svg";
import ProcentSelect from "./commision-select"

const yearButtons = [
  { id: "001", buttonName: "1 year", isActiveYear: true },
  { id: "002", buttonName: "5 year", isActiveYear: false },
  { id: "003", buttonName: "10 year", isActiveYear: false },
];

function TableBlock() {
  const [isToggleYear, setIsToggleYear] = React.useState("001");
  const [isYourDeposit, setIsYourDeposit] = React.useState("");

  const handlerTogglerYears = (buttonId) => {
    if (buttonId) {
      setIsToggleYear(buttonId);
    }
  };
  return (
    <div className={classes.TableBlock}>
      <div className={classes.TableBlockTitle}>
        Other portocols charge you <br /> <span>5-30% </span> performance fee{" "}
      </div>
      <div className={classes.TableBlockDescr}>
        See how fees can impact ROI for yield farmers
      </div>
      <div className={classes.TableHeader}>

        <div className={classes.inputBlock}>
          <label className={classes.inputBlockTitle}>Your deposit</label>
          <input
            className={classes.depositInput}
            value={isYourDeposit}
            onChange={(e) => setIsYourDeposit(e.target.value)}
            placeholder="$ 1000"
          />
        </div>

        <div className={classes.TableHeaderButtons} id="TableHeaderButtons">
          <label className={classes.inputBlockTitle}>Years</label>
          <div className={classes.TableheaderButtonsPlace}>
            {yearButtons.map((btn) => (
              <button
                type="button"
                className={btn.id === isToggleYear ? "Button-active" : "Button"}
                key={btn.id}
                onClick={() => handlerTogglerYears(btn.id)}
              >
                {btn.buttonName}
              </button>
            ))}
          </div>
        </div>

        <ProcentSelect />

      </div>
      <div className={classes.TableHeaderRow}>
        <div className={classes.TableHeaderName}>Name</div>
        <div className={classes.bauApy}>BAU APY</div>
        <div className={classes.apyPercent}>APY 5% fee</div>
        <div className={classes.bauFees}>
          BAU<span>&nbsp;FEES</span>
        </div>
        <div className={classes.feesValue}>Fees = 5%</div>
      </div>
      <div className={classes.TableBody}>
        <Link to={"/vaultsInfo"}>
          <TableBlockItem />
        </Link>
      </div>
      <Link className={classes.moreVaults} to="/vaults">
        <div className={classes.moreVaultsValue}>More vaults</div>
        <img src={arrowButton} alt="" />
      </Link>
    </div>
  );
}

export default TableBlock;
