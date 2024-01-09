import React from "react";
import classes from "./vaultsDepositList.module.scss";
import { StatesContext } from "../../../App";

const ItemIcon = () => {
  return (
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
  );
};

  const tokenItemsSearching = [
    { id: 1, itemName: "ETH", itemIcon: <ItemIcon />, isActiveItemL: true },
    { id: 2, itemName: "DAI", itemIcon: <ItemIcon />, isActiveItemL: false },
    { id: 3, itemName: "USDC", itemIcon: <ItemIcon />, isActiveItemL: false },
    { id: 4, itemName: "USDT", itemIcon: <ItemIcon />, isActiveItemL: false },
    { id: 5, itemName: "WBTC", itemIcon: <ItemIcon />, isActiveItemL: false },
    { id: 6, itemName: "WETH", itemIcon: <ItemIcon />, isActiveItemL: false },
  ];
  const tokenList = [
    {
      id: 1,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 2,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 3,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 4,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 5,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 6,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 7,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 8,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 9,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 10,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 11,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 12,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 13,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 14,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 15,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 16,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 17,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 18,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 19,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 20,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 21,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 22,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 23,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 24,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 25,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 26,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 27,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 28,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 29,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 30,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 31,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 32,
      itemName: "Ether",
      itemCount: "0",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
    {
      id: 33,
      itemName: "Ether",
      itemCount: "1.358",
      itemIcon: <ItemIcon />,
      itemDeposit: "1.413,41",
    },
  ];

const Index = () => {
  const states = React.useContext(StatesContext);
   const [filteredUsers, setFilteredUsers] = React.useState(tokenList);
  const [inputValue, setInputValue] = React.useState("");
  const [isNotFound, setIsNotFound] = React.useState(false)



  const handleFilter = (event) => {
  const query = event.target.value;

  let updatedList = [...tokenList];

  updatedList = updatedList.filter((item) => {
    console.log("item filtred ", item.itemName.toLowerCase().indexOf(query.toLowerCase()));
    return item.itemName.toLowerCase().indexOf(query.toLowerCase()) !== -1;
  });
  
  setInputValue(query)
  setFilteredUsers(updatedList);
};
React.useEffect(() => {
  if(filteredUsers.length < 1) setIsNotFound(true)
  else setIsNotFound(false)
}, [filteredUsers])

  return (
    <div
      className={classes.deposit__item_searching}
      onClick={(e) => {
        e.stopPropagation();
      }}
    >
      <div className={classes.searching__top}>
        <p className={classes.searching__top_text}>Select token</p>
        <button type="button" onClick={() => states.handlerDepositInfo()}>
          <svg
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M8 16L16 7.99997"
              stroke="#E5E8DF"
              strokeWidth="2"
              strokeLinecap="round"
            />
            <path
              d="M16 16L7.99997 7.99997"
              stroke="#E5E8DF"
              strokeWidth="2"
              strokeLinecap="round"
            />
          </svg>
        </button>
      </div>
      <div className={classes.searching__input_wrap}>
        <svg
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            fillRule="evenodd"
            clipRule="evenodd"
            d="M10.4 14.6667C12.7564 14.6667 14.6667 12.7564 14.6667 10.4C14.6667 8.04359 12.7564 6.13333 10.4 6.13333C8.04358 6.13333 6.13333 8.04359 6.13333 10.4C6.13333 12.7564 8.04358 14.6667 10.4 14.6667ZM16.8 10.4C16.8 6.86538 13.9346 4 10.4 4C6.86538 4 4 6.86538 4 10.4C4 13.9346 6.86538 16.8 10.4 16.8C11.7822 16.8 13.0621 16.3618 14.1083 15.6168L18.1791 19.6876C18.5956 20.1041 19.271 20.1041 19.6876 19.6876C20.1041 19.271 20.1041 18.5956 19.6876 18.1791L15.6168 14.1083C16.3618 13.0621 16.8 11.7822 16.8 10.4Z"
            fill="#E5E8DF"
          />
        </svg>
        <input 
        type="text"
        value={inputValue}
        onChange={handleFilter} 
        placeholder="Name or address" autoFocus />
      </div>
      <div className={classes.token__items}>
        {tokenItemsSearching &&
          tokenItemsSearching.map((tokenI) => (
            <div key={tokenI.id} className={classes.token__item}>
              <span className={classes.token__item_icon}>
                {tokenI.itemIcon}
              </span>
              <span className={classes.token__item_name}>
                {tokenI.itemName}
              </span>
            </div>
          ))}
      </div>
      <div className={classes.token__list_block}>
        <div className={classes.token__list_wrap}>
          <div className={classes.token__list}>
            {filteredUsers.length >= 1 && filteredUsers.map((tokenListI) => (
              <div className={classes.token__list_item} key={tokenListI.id}>
                <div className={classes.list__item_left}>
                  <div className={classes.item__left_icon}>
                    {tokenListI.itemIcon}
                  </div>
                  <div className={classes.item__left_description}>
                    <p className={classes.left__description_name}>
                      {tokenListI.itemName}
                    </p>
                    <p className={classes.left__description_count}>
                      {tokenListI.itemCount}
                    </p>
                  </div>
                </div>
                <div className={classes.item__right_cash}>
                  $ {tokenListI.itemDeposit}
                </div>
              </div>
            ))}
            {isNotFound && (<p style={{color:"white", textAlign:"center"}}>No results found</p>)}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Index;
