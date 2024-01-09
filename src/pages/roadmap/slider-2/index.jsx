import ArrowIconBack from "../../../components/roadmap/svg/arrow-icon-back";
import ArrowIconNext from "../../../components/roadmap/svg/arrow-icon-next";
import { motion } from "framer-motion";
import React, { useState } from "react";
// Import Swiper React components
import { Swiper, SwiperSlide } from "swiper/react";

// Import Swiper styles
import "swiper/css";
import "swiper/css/navigation";
// import "swiper/components/navigation/navigation.min.css";
import styles from "./slider.module.scss";

// import required modules
import { Navigation } from "swiper/modules";

const sliderItems = [
  {
    id: 1,
    itemDate: "28 aug",
    itemText: `Curve factory on Arbitrum`,
    isFill: "full",
    itemYear: "2023",
  },
  {
    id: 2,
    itemDate: "28 aug",
    itemText: `Curve factory on Arbitrum`,
    isFill: "party",
    itemYear: "",
  },
  {
    id: 3,
    itemDate: "3rd quarter 2024",
    itemText: `Curve factory on Arbitrum`,
    isFill: "transparent",
    itemYear: "",
  },
  {
    id: 4,
    itemDate: "3rd quarter 2024",
    itemText: `Curve factory on Arbitrum`,
    isFill: "transparent",
    itemYear: "2024",
  },
  {
    id: 5,
    itemDate: "3rd quarter 2024",
    itemText: `Curve factory on Arbitrum`,
    isFill: "transparent",
    itemYear: "",
  },
];

export default function Index() {
  const [, setSwiperRef] = useState(null);
  const navigationPrevRef = React.useRef(null);
  const navigationNextRef = React.useRef(null);
  const [isDisabled, setIsDisabled] = React.useState(false);

  // React.useEffect(() => {
  //   let list = navigationPrevRef.current;
  //   let classDis = list.className
  //   console.log("list ", list);
  //   console.log("classDis ", classDis);
  // }, []);

  return (
    <div className={styles.roadmap__slider}>
      <div className={styles.slider__inner}>
        <div className={styles.slider__navigation}>
          <button
            className={styles.navigation__left}
            ref={navigationPrevRef}
            disabled
          >
            <ArrowIconBack isDisabled={isDisabled} />
          </button>
          <button
            className={styles.navigation__right}
            ref={navigationNextRef}
            disabled
          >
            <ArrowIconNext isDisabled={isDisabled} />
          </button>
        </div>
        <Swiper
          onSwiper={setSwiperRef}
          slidesPerView={3}
          centeredSlides={false}
          spaceBetween={20}
          navigation={{
            prevEl: navigationPrevRef.current,
            nextEl: navigationNextRef.current,
          }}
          modules={[Navigation]}
          className={styles.swiper}
        >
          <motion.div
            className={styles.slider__body}
            drag="x"
            whileTap={{ cursor: "grabbing" }}
            dragElastic={0}
            dragConstraints={{
              left: -1000,
              right: 0,
            }}
          >
            {sliderItems.map((item, index) => (
              <SwiperSlide
                key={index}
                className={
                  item.isFill === "full"
                    ? styles.slider__item_filled
                    : (item.isFill === "party"
                        ? styles.slider__item_party
                        : "") ||
                      (item.isFill === "transparent"
                        ? styles.slider__item_transparent
                        : "")
                }
              >
                <motion.div>
                  <p className={styles.item__date}>{item.itemDate}</p>
                  <p className={styles.item__text}>{item.itemText}</p>
                  <p className={styles.item__year}>{item.itemYear}</p>
                </motion.div>
              </SwiperSlide>
            ))}
          </motion.div>
        </Swiper>

        <p className="append-buttons"></p>
      </div>
    </div>
  );
}
