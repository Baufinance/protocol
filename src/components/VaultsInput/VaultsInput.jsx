import React from "react";
import classes from "./VaultsInput.module.scss";
import InputSearchIcon from "./svg/input-search";
import ClearInput from "./svg/clear-icon";
import { StatesContext } from "../../App";

const VaultsInput = () => {
  const {
    handleClearInput,
    handleClearMyInput,
    inputValue,
    inputValueMy,
    handleFilter,
    handleFilterMy,
    isBtnActive,
    setIsBtnActive,
    vaultsBtns,
  } = React.useContext(StatesContext);

  return (
    <div className={classes.VaultsInput}>
      <h4 className={classes.VaultsTitle}>Vaults</h4>
        <form
          className={classes.VaultsForm}
          onSubmit={(e) => e.preventDefault()}
        >
          <InputSearchIcon />
          <input
            type="text"
            placeholder="Vault name / Token name / Pool name / Volt address / Token address"
            value={isBtnActive === "001" ? inputValue : inputValueMy}
            onChange={isBtnActive === "001" ? handleFilter : handleFilterMy}
          />

          {inputValue.length | (inputValueMy.length > 0) && (
            <button
              type="button"
              onClick={() => {
                if(isBtnActive === "001") handleClearInput()
                if(isBtnActive === "002") handleClearMyInput()
                }}
            >
              <ClearInput />
            </button>
          )}
        </form>

      <div className={classes.ButtonPlace}>
        {vaultsBtns.map((vb) => (
          <button
            key={vb.id}
            className={
              isBtnActive === vb.id ? classes.button__active : classes.button
            }
            onClick={() => {
              if (vb.id) {
                setIsBtnActive(vb.id);
              }
            }}
          >
            {vb.btn__name} {vb.vaults__length ? `(${vb.vaults__length})` : null}
          </button>
        ))}
      </div>
    </div>
  );
};

export default VaultsInput;
