import React from "react";
import Header from "../Header/Header";
import Footer from "../Footer/Footer";
import styles from "./layout.module.scss";
import { StatesContext } from "../../App";
import AuthWallet from "../../components/auth-wallet";

const Index = ({ children }) => {
  const states = React.useContext(StatesContext);

  React.useEffect(()=>{
    const errorPage = document.getElementById('error-page')
    if (errorPage === true) {
      
    }
  })
  return (
    <div className={styles.layout__wrapper}>
      {!states.isConstruction && <Header />}
      {children}
      {!states.isConstruction && <Footer />}

      {states.isOpenAuthWallet && (
        <AuthWallet
          handlerOpenAuthWallet={states.handlerOpenAuthWallet}
          handlerAuthed={states.handlerAuthed}
        />
      )}
    </div>
  );
};

export default Index;
