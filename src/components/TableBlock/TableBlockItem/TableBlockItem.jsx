import React from 'react'
import classes from './TableBlock.module.scss'
import coniPic from '../../../images/logo-coin.svg'

const TableBlockItem = () => {
  return (
    <div className={classes.TableBlockItem}>
      <div className={classes.coinPic}>
        <img src={coniPic} alt=''/>
        <div className={classes.coinName}>DYDX-ETH</div>
      </div>
      <div className={classes.bauApyValue}>11%</div>
      <div className={classes.apyFeeValue}>9%</div>
      <div className={classes.baufeesValue}>$0.5</div>
      <div className={classes.feesValue}>≈$50</div>
    </div>
  )
}

export default TableBlockItem
