import React from 'react'
import classes from './DescriptionItemsPlace.module.scss'
import zeropic from '../../../images/zeropic.svg'
import lilpercent from '../../../images/littlepercent.svg'

const DescriptionItemPlace = () => {
  return (
    <div className={classes.DescriptionItemPlace}>
      <div className={classes.DescriptionItem}>
        <div className={classes.DescriptionItemPercent}>
            <img src={zeropic} alt=''/>
        </div>
        <div className={classes.DescriptionItemTitle}>Management fees</div>
      </div>
      <div className={classes.DescriptionItem}>
        <div className={classes.DescriptionItemPercent}>
            <img src={zeropic} alt=''/>
        </div>
        <div className={classes.DescriptionItemTitle}>Withdrawal fees</div>
      </div>
      <div className={classes.DescriptionItem}>
        <div className={classes.DescriptionItemPercent}>
            <img src={zeropic} alt=''/>
        </div>
        <div className={classes.DescriptionItemTitle}>Performance fees</div>
      </div>
      <div className={classes.DescriptionItem}>
        <div className={classes.DescriptionItemPercent}>
            <img src={lilpercent} alt=''/>
        </div>
        <div className={classes.DescriptionItemTitle}>Single time deposit fee</div>
      </div>
    </div>
  )
}

export default DescriptionItemPlace
