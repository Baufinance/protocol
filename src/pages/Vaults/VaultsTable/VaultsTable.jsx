/* eslint-disable react-hooks/exhaustive-deps */
import React from "react";
import classes from "./VaultsTable.module.scss";
import VaultsTableItem from "./VaultsTableItem/VaultsTableItem";
import { Link } from "react-router-dom";
import { motion } from "framer-motion";
import { StatesContext } from "../../../App";


const VaultsTable = () => {
  const {
    tableItems,
    isAllVaults,
    isSortArray,
    setIsSortArray,
    isSortByName,
    setIsSortByName,
    isSortAPI,
    setIsSortAPI,
    isSortAPIDays,
    setIsSortAPIDays,
    isSortDeposited,
    setIsSortDeposited,
    isSortTVL,
    setIsSortTVL,
  } = React.useContext(StatesContext);



  const sortedArrey = () => {
    const strAscending = [...isAllVaults].sort((a, b) =>
      a.vaultName > b.vaultName ? 1 : -1
    );
    setIsSortByName(!isSortByName);
    return setIsSortArray(strAscending);
  };
  const unSortedArrey = () => {
    setIsSortByName(!isSortByName);
    return setIsSortArray(tableItems);
  };

  const sortedAPIArrey = () => {
    const strAscending = [...isAllVaults].sort((a, b) =>
      a.vaultByAPI > b.vaultByAPI ? 1 : -1
    );
    setIsSortAPI(!isSortAPI);
    return setIsSortArray(strAscending);
  };
  const unSortedAPIArrey = () => {
    setIsSortAPI(!isSortAPI);
    return setIsSortArray(tableItems);
  };

  const sortedAPIDaysArrey = () => {
    const strAscending = [...isAllVaults].sort((a, b) =>
      a.vaultByAPIDays > b.vaultByAPIDays ? 1 : -1
    );
    setIsSortAPIDays(!isSortAPIDays);
    return setIsSortArray(strAscending);
  };
  const unSortedAPIDaysArrey = () => {
    setIsSortAPIDays(!isSortAPIDays);
    return setIsSortArray(tableItems);
  };

  const sortedDepositedArrey = () => {
    const strAscending = [...isAllVaults].sort((a, b) =>
      a.vaultByDeposited > b.vaultByDeposited ? 1 : -1
    );
    setIsSortDeposited(!isSortAPIDays);
    return setIsSortArray(strAscending);
  };
  const unSortedDepositedArrey = () => {
    setIsSortDeposited(!isSortDeposited);
    return setIsSortArray(tableItems);
  };

  const sortedTVLArrey = () => {
    const strAscending = [...isAllVaults].sort((a, b) =>
      a.vaultByTVL > b.vaultByTVL ? 1 : -1
    );
    setIsSortTVL(!isSortTVL);
    return setIsSortArray(strAscending);
  };
  const unSortedTVLArrey = () => {
    setIsSortTVL(!isSortTVL);
    return setIsSortArray(tableItems);
  };

  React.useEffect(() => {
    if (isSortByName) {
      setIsSortAPI(false);
      setIsSortAPIDays(false);
      setIsSortDeposited(false);
      setIsSortTVL(false);
    }
  }, [isSortByName]);
  React.useEffect(() => {
    if (isSortAPI) {
      setIsSortByName(false);
      setIsSortAPIDays(false);
      setIsSortDeposited(false);
      setIsSortTVL(false);
    }
  }, [isSortAPI]);
  React.useEffect(() => {
    if (isSortAPIDays) {
      setIsSortByName(false);
      setIsSortAPI(false);
      setIsSortDeposited(false);
      setIsSortTVL(false);
    }
  }, [isSortAPIDays]);
  React.useEffect(() => {
    if (isSortDeposited) {
      setIsSortByName(false);
      setIsSortAPI(false);
      setIsSortAPIDays(false);
      setIsSortTVL(false);
    }
  }, [isSortDeposited]);
  React.useEffect(() => {
    if (isSortTVL) {
      setIsSortByName(false);
      setIsSortAPI(false);
      setIsSortAPIDays(false);
      setIsSortDeposited(false);
    }
  }, [isSortTVL]);

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
            if (!isSortAPI) sortedAPIArrey();
            if (isSortAPI) unSortedAPIArrey();
          }}
        >
          <span
            className={
              isSortAPI
                ? classes.HeaderItemValue_active
                : classes.HeaderItemValue
            }
          >
            APY
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
              fill={isSortAPI ? "#ffffff" : "#737373"}
            />
            <path
              d="M18.5172 11H5.48284C5.30466 11 5.21543 10.7846 5.34142 10.6586L11.8586 4.14142C11.9367 4.06332 12.0633 4.06332 12.1414 4.14142L18.6586 10.6586C18.7846 10.7846 18.6953 11 18.5172 11Z"
              fill={isSortAPI ? "#ffffff" : "#737373"}
            />
          </svg>
        </button>
        <button
          type="button"
          className={classes.TableHeaderItem}
          onClick={() => {
            if (!isSortAPIDays) sortedAPIDaysArrey();
            if (isSortAPIDays) unSortedAPIDaysArrey();
          }}
        >
          <span
            className={
              isSortAPIDays
                ? classes.HeaderItemValue_active
                : classes.HeaderItemValue
            }
          >
            APY, 7 Days
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
              fill={isSortAPIDays ? "#ffffff" : "#737373"}
            />
            <path
              d="M18.5172 11H5.48284C5.30466 11 5.21543 10.7846 5.34142 10.6586L11.8586 4.14142C11.9367 4.06332 12.0633 4.06332 12.1414 4.14142L18.6586 10.6586C18.7846 10.7846 18.6953 11 18.5172 11Z"
              fill={isSortAPIDays ? "#ffffff" : "#737373"}
            />
          </svg>
        </button>
        <button
          type="button"
          className={classes.TableHeaderItem}
          onClick={() => {
            if (!isSortDeposited) sortedDepositedArrey();
            if (isSortDeposited) unSortedDepositedArrey();
          }}
        >
          <span
            className={
              isSortDeposited
                ? classes.HeaderItemValue_active
                : classes.HeaderItemValue
            }
          >
            Deposited
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
              fill={isSortDeposited ? "#ffffff" : "#737373"}
            />
            <path
              d="M18.5172 11H5.48284C5.30466 11 5.21543 10.7846 5.34142 10.6586L11.8586 4.14142C11.9367 4.06332 12.0633 4.06332 12.1414 4.14142L18.6586 10.6586C18.7846 10.7846 18.6953 11 18.5172 11Z"
              fill={isSortDeposited ? "#ffffff" : "#737373"}
            />
          </svg>
        </button>
        <button
          type="button"
          className={classes.TableHeaderItem}
          onClick={() => {
            if (!isSortTVL) sortedTVLArrey();
            if (isSortTVL) unSortedTVLArrey();
          }}
        >
          <span
            className={
              isSortTVL
                ? classes.HeaderItemValue_active
                : classes.HeaderItemValue
            }
          >
            TVL
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
              fill={isSortTVL ? "#ffffff" : "#737373"}
            />
            <path
              d="M18.5172 11H5.48284C5.30466 11 5.21543 10.7846 5.34142 10.6586L11.8586 4.14142C11.9367 4.06332 12.0633 4.06332 12.1414 4.14142L18.6586 10.6586C18.7846 10.7846 18.6953 11 18.5172 11Z"
              fill={isSortTVL ? "#ffffff" : "#737373"}
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
        {isSortArray.map((item) => (
          <Link to={"/vaultsinfo/"+item.vaultAddress}  key={item.id}>
            <VaultsTableItem item={item} />
          </Link>
        ))}
      </motion.div>
    </div>
  );
};

export default VaultsTable;

//   const sortedAPIDaysArrey = () => {
//   const strAscending = [...isAllVaults].sort((a, b) =>
//     a.vaultByAPIDays > b.vaultByAPIDays ? 1 : -1
//   );
//   setIsActiveSortAPI7Days(!isActiveSortAPI7Days);
//   setSortByName(false)
//   setIsActiveSortAPI7Days(false)
//   return setSortByName(strAscending);
// };
// const unSortedAPIDaysArrey = () => {
//   setIsActiveSortAPI7Days(!isActiveSortAPI7Days);
//   return setSortByName(isAllVaults);
// };

// const sortedAPI7DaysArrey = () => {
//   const strAscending = [...filteredUsers].sort((a, b) =>
//     a.vaultName > b.vaultName ? 1 : -1
//   );
//   setIsActiveSortAPI7Days(!isActiveSortAPI7Days);
//   return setSortByAPI7Days(strAscending);
// };
// const unSortedAPI7DaysArrey = () => {
//   setIsActiveSortAPI7Days(!isActiveSortAPI7Days);
//   return setSortByAPI(filteredUsers);
// };

// const sortedDepositedArrey = () => {
//   const strAscending = [...filteredUsers].sort((a, b) =>
//     a.vaultName > b.vaultName ? 1 : -1
//   );
//   setIsActiveSortDeposited(!isActiveSortDeposited);
//   return setSortByDeposited(strAscending);
// };
// const unSortedDepositedArrey = () => {
//   setIsActiveSortDeposited(!isActiveSortDeposited);
//   return setSortByDeposited(filteredUsers);
// };

// const [isActiveSortTVL, setIsActiveSortTVL] = React.useState(false);
// const [sortByTVL, setSortByTVL] = React.useState(isAllVaults);

// const sortedTVLArrey = () => {
//   const strAscending = [...filtereisAllVaultsdUsers].sort((a, b) =>
//     a.vaultName > b.vaultName ? 1 : -1
//   );
//   setIsActiveSortTVL(!isActiveSortTVL);
//   return setSortByTVL(strAscending);
// };
// const unSortedTVLArrey = () => {
//   setIsActiveSortTVL(!isActiveSortTVL);
//   return setSortByTVL(isAllVaults);
// };

// import React from "react";
// import classes from "./VaultsTable.module.scss";
// import VaultsTableItem from "./VaultsTableItem/VaultsTableItem";
// import { Link } from "react-router-dom";
// import { motion } from "framer-motion";
// import { StatesContext } from "../../../App";

// const sortBnts = [
//   { id: "001", name__btn: "Name" },
//   { id: "002", name__btn: "APY" },
//   { id: "003", name__btn: "APY, 7 Days" },
//   { id: "004", name__btn: "Deposited" },
//   { id: "005", name__btn: "TVL" },
// ];

// const VaultsTable = () => {
//   const { isAllVaults } = React.useContext(StatesContext);

//   const [isActiveBtn, setIsActiveBtn] = React.useState(false);
//   const [sortedItems, setSortedItems] = React.useState([...isAllVaults]);
//   const [sortType, setSortType] = React.useState(null);

//     const sortedArrey = (type) => {
//     const strAscending = [...isAllVaults].sort((a, b) =>
//       a.vaultName > b.vaultName ? 1 : -1
//     );
//     return setSortedItems(strAscending);
//   };

//   const unSortedArrey = () => {
//     return setSortedItems(isAllVaults);
//   };

//   return (
//     <div className={classes.VaultsTable}>
//       <div className={classes.VaultsTableHeader}>

//         {/* {sortBnts.map((btn) => (
//           <button
//             key={btn.id}
//             className={classes.TableHeaderItem}
//             onClick={() => {
//               if (!isActiveBtn) sortedArrey(btn.id);
//                   if (isActiveBtn) unSortedArrey();
//               switch (btn.id) {
//                 case btn.id:
//                   return setIsActiveBtn(btn.id === isActiveBtn ? null : btn.id);
//                 default:
//                   return;
//               }
//             }}
//           >
//             <span
//               className={
//                 isActiveBtn === btn.id
//                   ? classes.HeaderItemValue_active
//                   : classes.HeaderItemValue
//               }
//             >
//               {btn.name__btn}
//             </span>
//             <svg
//               width="24"
//               height="24"
//               viewBox="0 0 24 24"
//               fill="none"
//               xmlns="http://www.w3.org/2000/svg"
//             >
//               <path
//                 d="M18.5172 13H5.48284C5.30466 13 5.21543 13.2154 5.34142 13.3414L11.8586 19.8586C11.9367 19.9367 12.0633 19.9367 12.1414 19.8586L18.6586 13.3414C18.7846 13.2154 18.6953 13 18.5172 13Z"
//                 fill={isActiveBtn === btn.id ? "#ffffff" : "#737373"}
//               />
//               <path
//                 d="M18.5172 11H5.48284C5.30466 11 5.21543 10.7846 5.34142 10.6586L11.8586 4.14142C11.9367 4.06332 12.0633 4.06332 12.1414 4.14142L18.6586 10.6586C18.7846 10.7846 18.6953 11 18.5172 11Z"
//                 fill={isActiveBtn === btn.id ? "#ffffff" : "#737373"}
//               />
//             </svg>
//           </button>
//         ))} */}
//         <button
//             // key={btn.id}
//             className={classes.TableHeaderItem}
//               onClick={(id) => {
//               if (!isActiveBtn) sortedArrey(id);
//                   if (isActiveBtn) unSortedArrey();
//               switch (id) {
//                 case id:
//                   return setIsActiveBtn(id === isActiveBtn ? null : id);
//                 default:
//                   return;
//               }
//             }}
//           >
//             <span
//               className={
//                 isActiveBtn
//                   ? classes.HeaderItemValue_active
//                   : classes.HeaderItemValue
//               }

//             >
//               Name
//             </span>
//             <svg
//               width="24"
//               height="24"
//               viewBox="0 0 24 24"
//               fill="none"
//               xmlns="http://www.w3.org/2000/svg"
//             >
//               <path
//                 d="M18.5172 13H5.48284C5.30466 13 5.21543 13.2154 5.34142 13.3414L11.8586 19.8586C11.9367 19.9367 12.0633 19.9367 12.1414 19.8586L18.6586 13.3414C18.7846 13.2154 18.6953 13 18.5172 13Z"
//                 fill={isActiveBtn === "001" ? "#ffffff" : "#737373"}
//               />
//               <path
//                 d="M18.5172 11H5.48284C5.30466 11 5.21543 10.7846 5.34142 10.6586L11.8586 4.14142C11.9367 4.06332 12.0633 4.06332 12.1414 4.14142L18.6586 10.6586C18.7846 10.7846 18.6953 11 18.5172 11Z"
//                 fill={isActiveBtn === "001" ? "#ffffff" : "#737373"}
//               />
//             </svg>
//           </button>
//       </div>
//       <motion.div
//         className={classes.VaultsTableItems}
//         initial={{ opacity: 0 }}
//         animate={{
//           opacity: 1,
//           transition: { ease: "easeIn", duration: 0.7 },
//         }}
//       >
//         {sortedItems.map((item) => (
//           <Link to={"/vaultsinfo"} key={item.id}>
//             <VaultsTableItem item={item} />
//           </Link>
//         ))}
//       </motion.div>
//     </div>
//   );
// };

// export default VaultsTable;
