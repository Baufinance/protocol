import React from "react";
import classes from "./profile.data.module.scss";
import { StatesContext } from "../../../App";

const Index = () => {
  const states = React.useContext(StatesContext);
  // const[isStatus, setIsStatus] = React.useState('')
  const transItems = [
    {
      id: "001",
      itemName: "dydx-eth",
      itemStatus: "success",
    },
    {
      id: "002",
      itemName: "dydx-eth",
      itemStatus: "pending",
    },
    {
      id: "003",
      itemName: "dydx-eth",
      itemStatus: "error",
    },
  ];
  return (
    <div className={classes.profile__data} onClick={(e) => e.stopPropagation()}>
      <p className={classes.profile__top_title}>Profile</p>
      <div className={classes.profile__top_username_wrap}>
        <span className={classes.profile__top_username}>ox1gt...a123</span>
        <button type="button" className={classes.profile__top_copy}>
          <svg
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <rect
              x="5"
              y="5"
              width="9"
              height="11"
              rx="1"
              stroke="#E5E8DF"
              strokeWidth="2"
            />
            <path
              d="M14 7H17C18.1046 7 19 7.89543 19 9V17C19 18.1046 18.1046 19 17 19H11C9.89543 19 9 18.1046 9 17V15.3077"
              stroke="#E5E8DF"
              strokeWidth="2"
            />
          </svg>
        </button>
      </div>
      <div className={classes.profile__currency}>
        <div className={classes.profile__deposit}>
          <p className={classes.deposit__title}>Deposited</p>
          <p className={classes.deposit__data}>$ 1,200.00</p>
        </div>
        <div className={classes.profile__earny}>
          <p className={classes.earny__title}>Earnings</p>
          <p className={classes.earny__data}>+ $ 200.00</p>
        </div>
      </div>
      <div className={classes.profile__trans}>
        <p className={classes.trans__title}>Your transactions</p>
        <ul className={classes.profile__trans_list}>
          {transItems.map((trItem) => (
            <li className={classes.trans__list_item} key={trItem.id}>
              <span className={classes.list__item_name}>{trItem.itemName}</span>
              {trItem.itemStatus === "success" && (
                <>
                  <span className={classes.list__item_status}>
                    <span className={classes.item__status_success}>
                      {trItem.itemStatus}
                    </span>
                    <svg
                      width="32"
                      height="32"
                      viewBox="0 0 32 32"
                      fill="none"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path
                        d="M9.79289 20.792C9.40237 21.1825 9.40237 21.8157 9.79289 22.2062C10.1834 22.5967 10.8166 22.5967 11.2071 22.2062L9.79289 20.792ZM22.4982 10.5009C22.4982 9.94862 22.0505 9.5009 21.4982 9.5009L12.4982 9.5009C11.9459 9.5009 11.4982 9.94862 11.4982 10.5009C11.4982 11.0532 11.9459 11.5009 12.4982 11.5009L20.4982 11.5009L20.4982 19.5009C20.4982 20.0532 20.9459 20.5009 21.4982 20.5009C22.0505 20.5009 22.4982 20.0532 22.4982 19.5009L22.4982 10.5009ZM11.2071 22.2062L22.2053 11.208L20.7911 9.79379L9.79289 20.792L11.2071 22.2062Z"
                        fill="#E5E8DF"
                      />
                    </svg>
                  </span>
                </>
              )}
              {trItem.itemStatus === "pending" && (
                <>
                  <span className={classes.list__item_status}>
                    <span className={classes.item__status_pending}>
                      {trItem.itemStatus}
                    </span>
                    <svg
                      width="32"
                      height="32"
                      viewBox="0 0 32 32"
                      fill="none"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path
                        d="M9.79289 20.792C9.40237 21.1825 9.40237 21.8157 9.79289 22.2062C10.1834 22.5967 10.8166 22.5967 11.2071 22.2062L9.79289 20.792ZM22.4982 10.5009C22.4982 9.94862 22.0505 9.5009 21.4982 9.5009L12.4982 9.5009C11.9459 9.5009 11.4982 9.94862 11.4982 10.5009C11.4982 11.0532 11.9459 11.5009 12.4982 11.5009L20.4982 11.5009L20.4982 19.5009C20.4982 20.0532 20.9459 20.5009 21.4982 20.5009C22.0505 20.5009 22.4982 20.0532 22.4982 19.5009L22.4982 10.5009ZM11.2071 22.2062L22.2053 11.208L20.7911 9.79379L9.79289 20.792L11.2071 22.2062Z"
                        fill="#E5E8DF"
                      />
                    </svg>
                  </span>
                </>
              )}
              {trItem.itemStatus === "error" && (
                <>
                  <span className={classes.list__item_status}>
                    <span className={classes.item__status_error}>
                      {trItem.itemStatus}
                    </span>
                    <svg
                      width="32"
                      height="32"
                      viewBox="0 0 32 32"
                      fill="none"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path
                        d="M9.79289 20.792C9.40237 21.1825 9.40237 21.8157 9.79289 22.2062C10.1834 22.5967 10.8166 22.5967 11.2071 22.2062L9.79289 20.792ZM22.4982 10.5009C22.4982 9.94862 22.0505 9.5009 21.4982 9.5009L12.4982 9.5009C11.9459 9.5009 11.4982 9.94862 11.4982 10.5009C11.4982 11.0532 11.9459 11.5009 12.4982 11.5009L20.4982 11.5009L20.4982 19.5009C20.4982 20.0532 20.9459 20.5009 21.4982 20.5009C22.0505 20.5009 22.4982 20.0532 22.4982 19.5009L22.4982 10.5009ZM11.2071 22.2062L22.2053 11.208L20.7911 9.79379L9.79289 20.792L11.2071 22.2062Z"
                        fill="#E5E8DF"
                      />
                    </svg>
                  </span>
                </>
              )}
            </li>
          ))}
        </ul>
      </div>
      <button
        type="button"
        className={classes.disconnect}
        onClick={() => {
          states.handlerOpenAuthProfileData();
          states.handlerAuthed();
        }}
      >
        Disconnect
      </button>
    </div>
  );
};

export default Index;
