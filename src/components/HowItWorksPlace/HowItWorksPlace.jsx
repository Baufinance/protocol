import React from 'react'
import classes from './HowItWorksPlace.module.scss'
import HowItWorksPlaceCard from './HowItWorksPlaceCard/HowItWorksPlaceCard'

const HowItWorksPlace = () => {
  return (
    <div className={classes.HowItWorksPlace}>
      <div className={classes.HowItWorksTitle}>HOW IT WORKS</div>
      <div className={classes.HowItWorksPlaceItems}>
        <HowItWorksPlaceCard/>
        <HowItWorksPlaceCard/>
        <HowItWorksPlaceCard/>
        <HowItWorksPlaceCard/>
      </div>
    </div>
  )
}

export default HowItWorksPlace
