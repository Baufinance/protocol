import React from "react";
import classes from "./VaultsTable.module.scss";
import VaultsTableItem from "./VaultsTableItem/VaultsTableItem";
import { Link } from "react-router-dom";
import { motion } from "framer-motion";
import { StatesContext } from "../../../App";
import { tab } from "@testing-library/user-event/dist/tab";

const VaultsTable = () => {
  const {
    // myTableItems,
    tableItems,
    // isAllVaults,
    isAllMyVaults,
    // setisAllMyVaults,
    isSortMyArray,
    setIsSortArray,
    isSortByName,
    setIsSortByName,
    // isSortAPI,
    // setIsSortAPI,
    // isSortAPIDays,
    // setIsSortAPIDays,
    // isSortDeposited,
    // setIsSortDeposited,
    // isSortTVL,
    // setIsSortTVL,
  } = React.useContext(StatesContext);

  const sortedArrey = () => {
    const strAscending = [...isAllMyVaults].sort((a, b) =>
      a.vaultName > b.vaultName ? 1 : -1
    );
    setIsSortByName(!isSortByName);
    return setIsSortArray(strAscending);
  };
  const unSortedArrey = () => {
    setIsSortByName(!isSortByName);
    return setIsSortArray(tableItems);
  };

  // const sortedAPIArrey = () => {
  //   const strAscending = [...isAllVaults].sort((a, b) =>
  //     a.vaultByAPI > b.vaultByAPI ? 1 : -1
  //   );
  //   setIsSortAPI(!isSortAPI);
  //   return setIsSortArray(strAscending);
  // };
  // const unSortedAPIArrey = () => {
  //   setIsSortAPI(!isSortAPI);
  //   return setIsSortArray(tableItems);
  // };

  // const sortedAPIDaysArrey = () => {
  //   const strAscending = [...isAllVaults].sort((a, b) =>
  //     a.vaultByAPIDays > b.vaultByAPIDays ? 1 : -1
  //   );
  //   setIsSortAPIDays(!isSortAPIDays);
  //   return setIsSortArray(strAscending);
  // };
  // const unSortedAPIDaysArrey = () => {
  //   setIsSortAPIDays(!isSortAPIDays);
  //   return setIsSortArray(tableItems);
  // };

  // const sortedDepositedArrey = () => {
  //   const strAscending = [...isAllVaults].sort((a, b) =>
  //     a.vaultByDeposited > b.vaultByDeposited ? 1 : -1
  //   );
  //   setIsSortDeposited(!isSortAPIDays);
  //   return setIsSortArray(strAscending);
  // };
  // const unSortedDepositedArrey = () => {
  //   setIsSortDeposited(!isSortDeposited);
  //   return setIsSortArray(tableItems);
  // };

  // const sortedTVLArrey = () => {
  //   const strAscending = [...isAllVaults].sort((a, b) =>
  //     a.vaultByTVL > b.vaultByTVL ? 1 : -1
  //   );
  //   setIsSortTVL(!isSortTVL);
  //   return setIsSortArray(strAscending);
  // };
  // const unSortedTVLArrey = () => {
  //   setIsSortTVL(!isSortTVL);
  //   return setIsSortArray(tableItems);
  // };

  return (
    <div className={classes.VaultsTable}>
      <div className={classes.VaultsTableHeader}>
        <button
          type="button"
          className={classes.TableHeaderItem}
          onClick={() => {
            if (!isSortByName) sortedArrey();
            if (isSortByName) unSortedArrey();
          }}
        >
          <div
            className={
              isSortByName
                ? classes.HeaderItemValue_active
                : classes.HeaderItemValue
            }
          >
            Name
          </div>

          <svg
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M18.5172 13H5.48284C5.30466 13 5.21543 13.2154 5.34142 13.3414L11.8586 19.8586C11.9367 19.9367 12.0633 19.9367 12.1414 19.8586L18.6586 13.3414C18.7846 13.2154 18.6953 13 18.5172 13Z"
              fill={isSortByName ? "#ffffff" : "#737373"}
            />
            <path
              d="M18.5172 11H5.48284C5.30466 11 5.21543 10.7846 5.34142 10.6586L11.8586 4.14142C11.9367 4.06332 12.0633 4.06332 12.1414 4.14142L18.6586 10.6586C18.7846 10.7846 18.6953 11 18.5172 11Z"
              fill={isSortByName ? "#ffffff" : "#737373"}
            />
          </svg>


        </button>
        <button
          type="button"
          className={classes.TableHeaderItem}
          onClick={() => {
            if (!isSortByName) sortedArrey();
            if (isSortByName) unSortedArrey();
          }}
        >
          <span
            className={
              isSortByName
                ? classes.HeaderItemValue_active
                : classes.HeaderItemValue
            }
          >
            API
          </span>
          <svg
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M18.5172 13H5.48284C5.30466 13 5.21543 13.2154 5.34142 13.3414L11.8586 19.8586C11.9367 19.9367 12.0633 19.9367 12.1414 19.8586L18.6586 13.3414C18.7846 13.2154 18.6953 13 18.5172 13Z"
              fill={isSortByName ? "#ffffff" : "#737373"}
            />
            <path
              d="M18.5172 11H5.48284C5.30466 11 5.21543 10.7846 5.34142 10.6586L11.8586 4.14142C11.9367 4.06332 12.0633 4.06332 12.1414 4.14142L18.6586 10.6586C18.7846 10.7846 18.6953 11 18.5172 11Z"
              fill={isSortByName ? "#ffffff" : "#737373"}
            />
          </svg>
        </button>
        <button
          type="button"
          className={classes.TableHeaderItem}
          onClick={() => {
            if (!isSortByName) sortedArrey();
            if (isSortByName) unSortedArrey();
          }}
        >
          <span
            className={
              isSortByName
                ? classes.HeaderItemValue_active
                : classes.HeaderItemValue
            }
          >
            API, 7 Days
          </span>
          <svg
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M18.5172 13H5.48284C5.30466 13 5.21543 13.2154 5.34142 13.3414L11.8586 19.8586C11.9367 19.9367 12.0633 19.9367 12.1414 19.8586L18.6586 13.3414C18.7846 13.2154 18.6953 13 18.5172 13Z"
              fill={isSortByName ? "#ffffff" : "#737373"}
            />
            <path
              d="M18.5172 11H5.48284C5.30466 11 5.21543 10.7846 5.34142 10.6586L11.8586 4.14142C11.9367 4.06332 12.0633 4.06332 12.1414 4.14142L18.6586 10.6586C18.7846 10.7846 18.6953 11 18.5172 11Z"
              fill={isSortByName ? "#ffffff" : "#737373"}
            />
          </svg>
        </button>
        <button
          type="button"
          className={classes.TableHeaderItem}
          onClick={() => {
            if (!isSortByName) sortedArrey();
            if (isSortByName) unSortedArrey();
          }}
        >
          <div
            className={
              isSortByName
                ? classes.HeaderItemValue_active
                : classes.HeaderItemValue
            }
          >
            Deposited
          </div>
          <svg
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M18.5172 13H5.48284C5.30466 13 5.21543 13.2154 5.34142 13.3414L11.8586 19.8586C11.9367 19.9367 12.0633 19.9367 12.1414 19.8586L18.6586 13.3414C18.7846 13.2154 18.6953 13 18.5172 13Z"
              fill={isSortByName ? "#ffffff" : "#737373"}
            />
            <path
              d="M18.5172 11H5.48284C5.30466 11 5.21543 10.7846 5.34142 10.6586L11.8586 4.14142C11.9367 4.06332 12.0633 4.06332 12.1414 4.14142L18.6586 10.6586C18.7846 10.7846 18.6953 11 18.5172 11Z"
              fill={isSortByName ? "#ffffff" : "#737373"}
            />
          </svg>
        </button>
        <button
          type="button"
          className={classes.TableHeaderItem}
          onClick={() => {
            if (!isSortByName) sortedArrey();
            if (isSortByName) unSortedArrey();
          }}
        >
          <div
            className={
              isSortByName
                ? classes.HeaderItemValue_active
                : classes.HeaderItemValue
            }
          >
            TVL
          </div>
          <svg
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M18.5172 13H5.48284C5.30466 13 5.21543 13.2154 5.34142 13.3414L11.8586 19.8586C11.9367 19.9367 12.0633 19.9367 12.1414 19.8586L18.6586 13.3414C18.7846 13.2154 18.6953 13 18.5172 13Z"
              fill={isSortByName ? "#ffffff" : "#737373"}
            />
            <path
              d="M18.5172 11H5.48284C5.30466 11 5.21543 10.7846 5.34142 10.6586L11.8586 4.14142C11.9367 4.06332 12.0633 4.06332 12.1414 4.14142L18.6586 10.6586C18.7846 10.7846 18.6953 11 18.5172 11Z"
              fill={isSortByName ? "#ffffff" : "#737373"}
            />
          </svg>
        </button>
      </div>
      <motion.div
        className={classes.VaultsTableItems}
        initial={{ opacity: 0 }}
        animate={{
          opacity: 1,
          transition: { ease: "easeIn", duration: 0.7 },
        }}
      >
        {isSortMyArray.map((item) => (
          <Link to="/vaultsinfo" key={item.id}>
            <VaultsTableItem item={item}/>
          </Link>
        ))}
      </motion.div>
    </div>
  );
};

export default VaultsTable;
