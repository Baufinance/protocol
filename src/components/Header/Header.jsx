import React, { useRef, useState } from "react";
import classes from "./Header.module.scss";
import eth from "../../images/eth.svg";
import { Link, NavLink } from "react-router-dom";
import "./DropDownStyles.css";
import { useClickOutside } from "../../hooks/useClickOutSide";
import { StatesContext } from "../../App";
import ProfileData from "./profile-data";
import { ConnectButton } from '@rainbow-me/rainbowkit';

const ArrowUp = () => {
  return (
    <svg
      width="30"
      height="24"
      viewBox="0 0 32 32"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M9.79289 20.792C9.40237 21.1825 9.40237 21.8157 9.79289 22.2062C10.1834 22.5967 10.8166 22.5967 11.2071 22.2062L9.79289 20.792ZM22.4982 10.5009C22.4982 9.94862 22.0505 9.5009 21.4982 9.5009L12.4982 9.5009C11.9459 9.5009 11.4982 9.94862 11.4982 10.5009C11.4982 11.0532 11.9459 11.5009 12.4982 11.5009L20.4982 11.5009L20.4982 19.5009C20.4982 20.0532 20.9459 20.5009 21.4982 20.5009C22.0505 20.5009 22.4982 20.0532 22.4982 19.5009L22.4982 10.5009ZM11.2071 22.2062L22.2053 11.208L20.7911 9.79379L9.79289 20.792L11.2071 22.2062Z"
        fill="#E5E8DF"
      />
    </svg>
  );
};
const Header = () => {
  const states = React.useContext(StatesContext);

  const [isActiveItem, setIsActiveItem] = React.useState("");
  const [openMenu, setOpenMenu] = useState(false);
  const menuRef = useRef(null);

  useClickOutside(menuRef, () => {
    if (openMenu) setTimeout(() => setOpenMenu(false), 50);
  });

  const handlerNavItemToggler = (itemPath) => {
    setIsActiveItem(itemPath);
  };

  const itemNav = [
    {
      id: "001",
      itemName: "Vaults",
      pathName: "/vaults",
      isActive: true,
      arrowIcon: "",
    },
    {
      id: "002",
      itemName: "Roadmap",
      pathName: "/roadmap",
      isActive: false,
      arrowIcon: "",
    },
    {
      id: "003",
      itemName: "Docs",
      pathName: "/docs",
      isActive: false,
      arrowIcon: <ArrowUp />,
    },
  ];
  return (
    <header className={classes.Header} id="header">
      <Link to="/"
      onClick={()=>setIsActiveItem('')}
      >
        <svg
          width="236"
          height="60"
          viewBox="0 0 236 60"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M0.000209808 20L19.8516 20L19.8516 -7.62939e-06L0.000209808 -7.62939e-06L0.000209808 20Z"
            fill="#E8CB3C"
          />
          <path
            d="M39.7029 50C39.7029 44.4771 35.2591 40 29.7773 40C24.2954 40 19.8516 44.4771 19.8516 50C19.8516 55.5228 24.2954 60 29.7773 60C35.2591 60 39.7029 55.5228 39.7029 50Z"
            fill="#0091F0"
          />
          <path
            d="M9.92587 40H0.000209808V30C0.000209808 27.3479 1.04595 24.8043 2.90737 22.9289C4.7688 21.0536 7.29342 20 9.92587 20H19.8516L19.8516 30C19.8516 32.6522 18.8058 35.1957 16.9444 37.0711C15.083 38.9464 12.5583 40 9.92587 40Z"
            fill="#E10E1A"
          />
          <path
            d="M9.92569 40H19.8514V50C19.8514 52.6522 18.8056 55.1957 16.9442 57.0711C15.0828 58.9464 12.5581 60 9.92569 60C7.29323 60 4.76859 58.9464 2.90716 57.0711C1.04574 55.1957 0 52.6522 0 50C0 47.3478 1.04574 44.8043 2.90716 42.9289C4.76859 41.0536 7.29323 40 9.92569 40Z"
            fill="#C200A9"
          />
          <path
            d="M36.79 22.9268C35.8684 21.9977 34.7739 21.2609 33.5692 20.7587C32.3645 20.2564 31.0732 19.9986 29.7694 20C28.4656 19.9986 27.1744 20.2564 25.9697 20.7587C24.7649 21.2609 23.6704 21.9977 22.7488 22.9268C21.8263 23.8551 21.0947 24.9578 20.5962 26.1716C20.0976 27.3854 19.842 28.6864 19.8438 30C19.8438 32.6522 20.8895 35.1957 22.7509 37.0711C24.6123 38.9464 27.137 40 29.7694 40C31.0734 40.0007 32.3648 39.7422 33.5695 39.2393C34.7742 38.7364 35.8686 37.999 36.79 37.0693C37.7125 36.1418 38.444 35.0398 38.9425 33.8266C39.4411 32.6135 39.6968 31.313 39.6951 30C39.6969 28.6864 39.4412 27.3854 38.9427 26.1716C38.4442 24.9578 37.7126 23.8551 36.79 22.9268Z"
            fill="#8EC300"
          />
          <path
            d="M68.774 47.9868C67.4046 48.0067 66.0525 47.6778 64.843 47.0306C63.6794 46.3953 62.7197 45.4391 62.0762 44.2741C61.3621 42.9419 61.0082 41.4438 61.0502 39.9303V25.8575H63.7747V35.1491H63.8323C64.1661 34.5327 64.6134 33.9861 65.1504 33.5385C65.7053 33.0751 66.3359 32.7122 67.0141 32.4661C67.7206 32.206 68.4676 32.0749 69.2198 32.079C70.5339 32.0573 71.8304 32.3858 72.9779 33.0314C74.0837 33.6728 74.991 34.611 75.5987 35.7414C76.2638 37.0131 76.5945 38.4352 76.5593 39.8722C76.5767 41.0263 76.3812 42.1737 75.9829 43.2559C75.6252 44.2173 75.0759 45.0947 74.369 45.8343C73.6779 46.5501 72.8398 47.105 71.9135 47.4603C70.9082 47.8294 69.8438 48.0079 68.774 47.9868ZM68.774 45.6291C69.6645 45.6389 70.5406 45.4019 71.3064 44.9439C72.0748 44.4761 72.703 43.8071 73.124 43.0081C73.5991 42.0889 73.8345 41.0631 73.808 40.0271C73.8305 39.0119 73.6006 38.0071 73.1393 37.1041C72.7244 36.3014 72.1067 35.6231 71.3486 35.1374C70.5867 34.6572 69.7035 34.4085 68.8048 34.4212C67.9142 34.4108 67.038 34.6479 66.2724 35.1065C65.5038 35.5777 64.88 36.2545 64.4702 37.0616C64.0051 37.9894 63.7753 39.0189 63.8016 40.0581C63.776 41.0823 64.006 42.0966 64.4702 43.0081C64.882 43.8087 65.5058 44.4787 66.2724 44.9439C67.028 45.3993 67.8935 45.6364 68.774 45.6291Z"
            fill="white"
          />
          <path
            d="M87.0629 47.9869C85.7235 48.0201 84.4044 47.6508 83.274 46.9261C82.2056 46.2163 81.3552 45.2201 80.8186 44.0496C80.235 42.7897 79.9408 41.4135 79.9578 40.0232C79.9389 38.619 80.265 37.2319 80.9069 35.9853C81.5277 34.7898 82.4724 33.7963 83.6314 33.1204C84.9318 32.385 86.4062 32.0197 87.8968 32.0635C89.3363 32.0232 90.759 32.3835 92.0085 33.1049C93.136 33.7824 94.0531 34.764 94.6561 35.9389C95.2852 37.1726 95.6033 38.5434 95.5822 39.9303V47.6229H92.8308V44.5258H92.7693C92.4516 45.1328 92.0492 45.6908 91.5743 46.1828C91.0346 46.7323 90.3954 47.1725 89.6913 47.4797C88.8604 47.8332 87.9647 48.006 87.0629 47.9869ZM87.7738 45.6291C88.6976 45.6464 89.6066 45.3936 90.3907 44.9013C91.1588 44.4041 91.7747 43.7018 92.1699 42.8726C92.6015 41.9659 92.8185 40.9707 92.8039 39.9652C92.8194 38.9862 92.6117 38.0167 92.1968 37.1313C91.815 36.3211 91.216 35.6346 90.4676 35.1491C89.679 34.6503 88.7623 34.3959 87.8315 34.4174C86.8662 34.3887 85.9142 34.6487 85.0955 35.1646C84.3373 35.6577 83.7316 36.3552 83.347 37.1777C82.9309 38.0778 82.7233 39.0614 82.7399 40.0542C82.7282 41.0262 82.9303 41.9887 83.3317 42.8726C83.7068 43.6919 84.3017 44.3892 85.0494 44.8858C85.8646 45.3996 86.8127 45.6583 87.7738 45.6291Z"
            fill="white"
          />
          <path
            d="M107.721 47.9868C106.452 48.0071 105.197 47.7147 104.066 47.1351C103.023 46.5997 102.15 45.7785 101.549 44.7658C100.93 43.6886 100.618 42.4602 100.646 41.2156V32.4197H103.398V41.1885C103.377 42.0178 103.582 42.837 103.99 43.5579C104.366 44.2109 104.914 44.7467 105.573 45.1065C106.223 45.4598 106.951 45.6435 107.69 45.6407C108.439 45.6459 109.177 45.4622 109.838 45.1065C110.499 44.7449 111.05 44.2097 111.433 43.5579C111.852 42.8413 112.063 42.0201 112.04 41.1885V32.4197H114.795V41.2156C114.823 42.4621 114.505 43.6915 113.877 44.7658C113.271 45.7743 112.4 46.5943 111.36 47.1351C110.235 47.7163 108.985 48.0088 107.721 47.9868Z"
            fill="white"
          />
          <path
            d="M133.507 47.6268V34.7774H130.875V32.4197H133.507V30.1858C133.507 28.8308 133.892 27.7739 134.66 27.0074C135.429 26.2408 136.47 25.8459 137.811 25.8459H141.066V28.1998H138.345C138.064 28.1813 137.782 28.2225 137.517 28.3205C137.252 28.4185 137.011 28.5712 136.808 28.7689C136.433 29.205 136.242 29.7722 136.278 30.3484V32.4042H146.457V47.6113H143.737V34.7619H136.278V47.6113L133.507 47.6268ZM145.081 29.9458C144.841 29.9481 144.602 29.9 144.38 29.8048C144.159 29.7095 143.959 29.569 143.794 29.3922C143.619 29.2257 143.48 29.0245 143.385 28.8014C143.291 28.5782 143.243 28.3379 143.245 28.0952C143.244 27.8528 143.292 27.6126 143.387 27.3896C143.481 27.1666 143.62 26.9654 143.794 26.7983C143.96 26.6227 144.16 26.4833 144.381 26.3888C144.603 26.2942 144.841 26.2465 145.081 26.2485C145.325 26.2441 145.566 26.2907 145.79 26.3853C146.014 26.48 146.217 26.6206 146.384 26.7983C146.554 26.9679 146.688 27.17 146.779 27.3927C146.871 27.6155 146.916 27.8543 146.914 28.0952C146.917 28.3362 146.872 28.5753 146.78 28.7981C146.689 29.021 146.554 29.223 146.384 29.3922C146.217 29.5711 146.015 29.7129 145.791 29.8082C145.567 29.9036 145.325 29.9505 145.081 29.9458Z"
            fill="white"
          />
          <path
            d="M151.502 47.6268V38.8308C151.473 37.5875 151.785 36.3603 152.405 35.2846C153.004 34.2749 153.87 33.4532 154.906 32.9113C156.032 32.3315 157.282 32.0403 158.545 32.0635C159.815 32.0365 161.07 32.3278 162.2 32.9113C163.231 33.4548 164.092 34.2765 164.686 35.2846C165.306 36.3603 165.618 37.5875 165.589 38.8308V47.6268H162.869V38.8618C162.889 38.0304 162.679 37.2097 162.261 36.4924C161.877 35.8403 161.325 35.3052 160.663 34.9439C160.013 34.5893 159.285 34.4043 158.545 34.4057C157.806 34.4043 157.078 34.5893 156.428 34.9439C155.767 35.3042 155.215 35.8396 154.833 36.4924C154.414 37.209 154.204 38.0302 154.226 38.8618V47.6268H151.502Z"
            fill="white"
          />
          <path
            d="M176.926 47.9868C175.587 48.0196 174.268 47.6504 173.137 46.9261C172.069 46.2163 171.219 45.2201 170.682 44.0496C170.1 42.7894 169.807 41.4132 169.825 40.0232C169.805 38.6193 170.13 37.2322 170.77 35.9853C171.392 34.7907 172.337 33.7975 173.495 33.1204C174.794 32.3857 176.267 32.0203 177.756 32.0635C179.196 32.0228 180.619 32.3831 181.868 33.1049C182.996 33.7833 183.914 34.7645 184.52 35.9388C185.149 37.174 185.468 38.5459 185.45 39.9342V47.6268H182.698V44.5296H182.641C182.323 45.1376 181.919 45.6957 181.442 46.1866C180.903 46.7361 180.265 47.1764 179.563 47.4836C178.729 47.8359 177.83 48.0074 176.926 47.9868ZM177.637 45.6291C178.562 45.6458 179.472 45.3931 180.258 44.9013C181.024 44.4028 181.638 43.7007 182.033 42.8726C182.465 41.9659 182.682 40.9707 182.667 39.9652C182.685 38.986 182.477 38.016 182.06 37.1313C181.678 36.3211 181.08 35.6345 180.331 35.1491C179.542 34.6503 178.626 34.3959 177.695 34.4174C176.73 34.3891 175.778 34.6491 174.959 35.1645C174.201 35.6568 173.596 36.3546 173.214 37.1777C172.796 38.0772 172.589 39.0612 172.607 40.0542C172.593 41.0264 172.796 41.9894 173.199 42.8726C173.571 43.6924 174.165 44.39 174.913 44.8858C175.728 45.3996 176.676 45.6583 177.637 45.6291Z"
            fill="white"
          />
          <path
            d="M190.498 47.6268V38.8308C190.469 37.5875 190.782 36.3603 191.401 35.2846C192 34.2749 192.866 33.4532 193.903 32.9113C195.028 32.3315 196.278 32.0403 197.542 32.0635C198.812 32.0371 200.069 32.3284 201.2 32.9113C202.229 33.4559 203.089 34.2774 203.682 35.2846C204.302 36.3603 204.614 37.5875 204.585 38.8308V47.6268H201.865V38.8618C201.885 38.0304 201.675 37.2097 201.257 36.4924C200.874 35.8395 200.322 35.3041 199.659 34.9439C199.009 34.5893 198.281 34.4043 197.542 34.4057C196.804 34.4043 196.077 34.5893 195.428 34.9439C194.765 35.3041 194.213 35.8395 193.83 36.4924C193.41 37.209 193.2 38.0302 193.222 38.8618V47.6268H190.498Z"
            fill="white"
          />
          <path
            d="M216.972 47.6268C215.518 47.6535 214.081 47.3043 212.799 46.6125C211.614 45.9785 210.614 45.0445 209.897 43.9025C209.182 42.7414 208.812 41.3976 208.833 40.031C208.811 38.6643 209.181 37.3203 209.897 36.1595C210.616 35.0188 211.615 34.0851 212.799 33.4495C214.081 32.7595 215.518 32.4104 216.972 32.4352H218.747V34.7929H216.883C215.934 34.7772 214.999 35.0193 214.174 35.4936C213.388 35.9456 212.735 36.5986 212.28 37.3868C211.813 38.1907 211.573 39.1075 211.584 40.0387C211.573 40.9712 211.813 41.8893 212.28 42.6946C212.737 43.481 213.39 44.1336 214.174 44.5877C214.999 45.0603 215.935 45.3022 216.883 45.2885H218.747V47.6423L216.972 47.6268Z"
            fill="white"
          />
          <path
            d="M230.26 47.6268C228.738 47.6553 227.229 47.3349 225.848 46.6899C224.618 46.1091 223.578 45.188 222.847 44.0341C222.108 42.8312 221.731 41.4377 221.764 40.0232C221.742 38.6124 222.057 37.2169 222.682 35.9543C223.259 34.7892 224.14 33.8042 225.23 33.1049C226.365 32.397 227.68 32.0353 229.015 32.0635C230.383 32.0111 231.736 32.3638 232.907 33.0778C233.929 33.7329 234.737 34.675 235.232 35.7879C235.757 36.9957 236.019 38.3024 236.001 39.6206C236.001 39.8413 236.001 40.0697 236.001 40.3058C235.995 40.5167 235.971 40.7266 235.928 40.933H224.68C224.751 41.7961 225.07 42.6196 225.599 43.3024C226.117 43.9541 226.795 44.4584 227.566 44.7658C228.41 45.1007 229.311 45.2677 230.218 45.2575H234.152V47.6113L230.26 47.6268ZM224.634 39.0089H233.249C233.245 38.6035 233.205 38.1993 233.13 37.801C233.047 37.3676 232.908 36.9471 232.715 36.5505C232.522 36.1422 232.262 35.7693 231.947 35.4472C231.598 35.1095 231.185 34.8461 230.732 34.6729C230.189 34.4638 229.611 34.3626 229.03 34.3748C228.402 34.3552 227.779 34.488 227.213 34.7619C226.696 35.0251 226.238 35.3897 225.864 35.8343C225.491 36.2804 225.2 36.7906 225.007 37.3403C224.81 37.8775 224.685 38.4386 224.634 39.0089Z"
            fill="white"
          />
          <path
            d="M119.965 39.7909H124.019C125.01 39.7909 125.961 40.1878 126.662 40.8943C127.364 41.6007 127.758 42.5588 127.758 43.5579V47.6578H123.688C122.697 47.6578 121.746 47.2609 121.044 46.5545C120.343 45.848 119.949 44.8899 119.949 43.8908V39.7909H119.965Z"
            fill="#8EC300"
          />
        </svg>
      </Link>
      <ul className={classes.menuLinks}>
        {itemNav.map((item) => (
          <NavLink
            key={item.id}
            to={item.pathName}
            className={
              item.pathName === isActiveItem
                ? classes.menuLinksItem__active
                : classes.menuLinksItem
            }
            onClick={() => handlerNavItemToggler(item.pathName)}
          >
            <span className={classes.manuLinksItemSubName}>
              {item.itemName}
            </span>
            <span>{item.arrowIcon}</span>
          </NavLink>
        ))}
      </ul>

      <ConnectButton/>

    </header>
  );
};

export default Header;