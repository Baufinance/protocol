/* eslint-disable react-hooks/exhaustive-deps */
import React, { useEffect } from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import MainPage from "./pages/MainPage/MainPage";
import Vaults from "./pages/Vaults/Vaults";
import VaultsInfo from "./pages/VaultsInfo/VaultsInfo";
import Roadmap from "./pages/roadmap/roadmap";
import Construction from "./pages/construction";
import Layout from "./components/layout";
import ErrorPage from "./pages/error";
import SubmitedInfo from "./components/submited-info";
import Cookie from "./components/cookie";
import useVaults from "./hooks/useVaults";
import useUserVaults from "./hooks/useUserVaults";


export const StatesContext = React.createContext();

function App() {

  const {vaults} = useVaults(1, 10)

  const {userVaults} = useUserVaults("0xf28558271c0b85e5ef433f4a2a10323edb9eec9f", 1, 10)

  const tableItems = vaults

  const myTableItems = userVaults


  console.log(tableItems)
  console.log(myTableItems)

  const vaultsBtns = [
    {
      id: "001",
      btn__name: "All vaults",
      vaults__length: tableItems.length,
      isBtnActive: true,
    },
    {
      id: "002",
      btn__name: "My vaults",
      vaults__length: null,
      isBtnActive: false,
    },
  ];

  const [isAllVaults, setisAllVaults] = React.useState([...tableItems]);


  const [isAllMyVaults, setisAllMyVaults] = React.useState([...myTableItems]);

  const [isAuth, setIsAuth] = React.useState(true);
  const [isOpenAuthWallet, setIsOpenAuthWallet] = React.useState(false);
  const [isAuthProfileData, setIsAuthProfileData] = React.useState(false);
  const [isSubmitedInfo, setIsSubmitedInfo] = React.useState(false);

  const [isCookie, setIsCookie] = React.useState(true);

  const [isBallance] = React.useState("0.7412");
  const [isBallanceWithdraw] = React.useState("0.4822");

  const [isConstruction, setIsConstruction] = React.useState(false);

  const [isDepositItemActive, setIsDepositItemActive] = React.useState(false);
  const [isDepositBtn, setIsDepositBtn] = React.useState(true);
  const [isActivateBtn, setIsActivateBtn] = React.useState(false);
  const [isActivateAproveBtn, setIsActivateAproveBtn] = React.useState(false);
  const [isAproveBtn, setIsAproveBtn] = React.useState(false);
  const [isDepositActiveteMSG, setIsDepositActiveteMSG] = React.useState(false);
  const [isDepositActiveteSuccessMSG, setIsDepositActiveSuccessMSG] =
    React.useState(false);

  const [isSortArray, setIsSortArray] = React.useState([...isAllVaults]);
  const [isSortMyArray, setIsSortMyArray] = React.useState([...isAllMyVaults]);

  const [isSortByName, setIsSortByName] = React.useState(false);
  const [isSortAPI, setIsSortAPI] = React.useState(false);
  const [isSortAPIDays, setIsSortAPIDays] = React.useState(false);
  const [isSortDeposited, setIsSortDeposited] = React.useState(false);
  const [isSortTVL, setIsSortTVL] = React.useState(false);

  const [inputValue, setInputValue] = React.useState("");
  const [inputValueMy, setInputValueMy] = React.useState("");

  const [isVaultsToggle, setIsVaultsToggle] = React.useState("all vaults");

  const [isBtnActive, setIsBtnActive] = React.useState("001");

  const [isNotFound, setIsNotFound] = React.useState(false);

  const hanlerSubmitedInfo = () => {
    setIsSubmitedInfo(!isSubmitedInfo);
  };
  const handlerOpenAuthProfileData = () => {
    setIsAuthProfileData(!isAuthProfileData);
  };

  const handlerOpenAuthWallet = () => {
    setIsOpenAuthWallet(!isOpenAuthWallet);
  };

  const handlerAuthed = () => {
    setIsAuth(!isAuth);
  };
  const handlerCookieToggler = () => {
    setIsCookie(false);
  };
  React.useEffect(() => {
    if (isOpenAuthWallet || isSubmitedInfo) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "auto";
    }
  }, [isOpenAuthWallet, isSubmitedInfo]);

  const handlerDepositInfo = () => {
    setIsDepositItemActive(!isDepositItemActive);
    console.log("Clicked");
  };
  const handlerCloseOutsideDepositInfo = () => {
    if (isDepositItemActive) {
      return setIsDepositItemActive(false);
    }
  };

  React.useEffect(() => {
    const constructionPage = document.querySelector("#construction");

    if (constructionPage) {
      setIsConstruction(true);
    }
  }, [isConstruction]);

  const handleFilter = (event) => {
    event.preventDefault();
    const query = event.target.value;
    let updatedList = [...isAllVaults];

    updatedList = updatedList.filter((item) => {
      return item.vaultName.toLowerCase().indexOf(query.toLowerCase()) !== -1;
    });

    setInputValue(query);
    setIsSortArray(updatedList);
  };
  const handleFilterMy = (event) => {
    event.preventDefault();
    const query = event.target.value;
    let updatedList = [...isAllMyVaults];

    updatedList = updatedList.filter((item) => {
      return item.vaultName.toLowerCase().indexOf(query.toLowerCase()) !== -1;
    });

    setInputValueMy(query);
    setIsSortMyArray(updatedList);
  };

  const handleClearInput = () => {
    setInputValue("");
    setIsSortArray(tableItems);
    setIsNotFound(false);
  };
  const handleClearMyInput = () => {
    setInputValueMy("");
    setIsSortMyArray(myTableItems);
    setIsNotFound(false);
  };


  useEffect(() => {
    setisAllVaults(vaults)
    setIsSortArray(vaults)

    setisAllMyVaults(userVaults)
    setIsSortMyArray(userVaults)

  }, [vaults, userVaults])

   React.useEffect(() => {
     if (isSortArray.length < 1 || isSortMyArray.length < 1)
       setIsNotFound(true);
     else setIsNotFound(false);
   }, [isSortArray, isSortMyArray]);



  const value = React.useMemo(
    () => ({
      isNotFound,
      setIsNotFound,
      handleClearInput,
      handleClearMyInput,
      isVaultsToggle,
      tableItems,
      setIsVaultsToggle,
      isBtnActive,
      setIsBtnActive,
      vaultsBtns,
      isAllVaults,
      setisAllVaults,
      isSortMyArray,
      setIsSortMyArray,
      isAllMyVaults,
      setisAllMyVaults,
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
      inputValue,
      setInputValue,
      inputValueMy,
      setInputValueMy,
      handleFilter,
      handleFilterMy,
      isDepositBtn,
      setIsDepositBtn,
      isActivateBtn,
      setIsActivateBtn,
      isActivateAproveBtn,
      setIsActivateAproveBtn,
      isAproveBtn,
      setIsAproveBtn,
      isDepositItemActive,
      isDepositActiveteMSG,
      setIsDepositActiveteMSG,
      isDepositActiveteSuccessMSG,
      setIsDepositActiveSuccessMSG,
      setIsOpenAuthWallet,
      handlerCookieToggler,
      handlerAuthed,
      isCookie,
      isAuth,
      handlerOpenAuthWallet,
      isOpenAuthWallet,
      handlerOpenAuthProfileData,
      isAuthProfileData,
      isConstruction,
      isSubmitedInfo,
      hanlerSubmitedInfo,
      handlerDepositInfo,
      handlerCloseOutsideDepositInfo,
      isBallance,
      isBallanceWithdraw,
    }),
    [
      isNotFound,
      setIsNotFound,
      handleClearInput,
      handleClearMyInput,
      isVaultsToggle,
      tableItems,
      vaultsBtns,
        ,
      setisAllVaults,
      isAllMyVaults,
      setisAllMyVaults,
      isSortMyArray,
      setIsSortMyArray,
      inputValue,
      setInputValue,
      inputValueMy,
      setInputValueMy,
      handleFilter,
      handleFilterMy,
      isBallance,
      isBallanceWithdraw,
      isDepositBtn,
      setIsDepositBtn,
      isActivateBtn,
      setIsActivateBtn,
      isActivateAproveBtn,
      setIsActivateAproveBtn,
      isAproveBtn,
      setIsAproveBtn,
      isDepositItemActive,
      isDepositActiveteMSG,
      setIsDepositActiveteMSG,
      isDepositActiveteSuccessMSG,
      setIsDepositActiveSuccessMSG,
      setIsOpenAuthWallet,
      isSubmitedInfo,
      hanlerSubmitedInfo,
      isCookie,
      isAuth,
      handlerAuthed,
      handlerOpenAuthWallet,
      isOpenAuthWallet,
      handlerOpenAuthProfileData,
      isAuthProfileData,
      isConstruction,
      handlerDepositInfo,
      handlerCloseOutsideDepositInfo,
    ]
  );

  console.log('data')
  console.log(isAllVaults)
  console.log(isAllMyVaults)

  console.log(isNotFound)

  return (
    <div
      className="app-wrapper"
      onClick={() => {
        setIsAuthProfileData(false);
      }}
    >

      <BrowserRouter>
        <StatesContext.Provider value={value}>
          <Layout>
            <Routes>
              <Route exec path="/" element={<MainPage />} />{" "}
              <Route exec path="/vaults" element={<Vaults />} />{" "}
              <Route exec path={"/vaultsinfo"} element={<VaultsInfo />} />{" "}
              <Route exec path="/roadmap" element={<Roadmap />} />{" "}
              <Route path="/error-page" element={<ErrorPage />} />{" "}
            </Routes>{" "}
          </Layout>{" "}
          <Routes>
            <Route path="/construction" element={<Construction />} />{" "}
          </Routes>{" "}
          {isCookie && <Cookie handlerCookieToggler={handlerCookieToggler} />}{" "}
          {isSubmitedInfo && <SubmitedInfo />}{" "}
        </StatesContext.Provider>{" "}
      </BrowserRouter>
    </div>
  );
}

export default App;
