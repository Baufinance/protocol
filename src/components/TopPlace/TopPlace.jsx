import React from 'react'
import classes from './TopPlace.module.scss'
import MainPageDescr from '../MainPageDescr/MainPageDescr'

const TopPlace = ({handlerOpenAuthWallet, handlerIsMessageClose,isMessage}) => {
  return (
    <div className={classes.TopPlace}>
      <MainPageDescr handlerOpenAuthWallet={handlerOpenAuthWallet}
      handlerIsMessageClose={handlerIsMessageClose}
      isMessage={isMessage}
      />
    </div>
  )
}

export default TopPlace
