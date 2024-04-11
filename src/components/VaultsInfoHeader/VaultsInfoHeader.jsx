import React from 'react'
import classes from './VaultsInfoHeader.module.scss'
import { Link } from 'react-router-dom'
import Curve from '../../images/coinLogoHeader.png'
import Velo from "../../images/velo-coin.svg";
import menuArrow from '../../images/menu-arrow.svg'
import greenArrow from '../../images/greenArrow.svg'
import moment from 'moment';

const VaultsInfoHeader = ({item}) => {

  return (
    <div className={classes.VaultsInfoHeader}>
      <Link to='/vaults' className={classes.arrowBack}>
        <img src={greenArrow} alt=''/>
        <div className={classes.arrowTitle}>Back</div>
      </Link>
      <div className={classes.VaultData}>
        <img src={item.vaultPoolType == 'Curve'? Curve : Velo} className={classes.Curve} alt="" />
        <div className={classes.coinName}>{item.vaultName}</div>
        <Link href='#' className={classes.coinLink}>
            <div className={classes.coinLinkValue}>{item.symbol}</div>
            <img src={menuArrow} alt="" />
        </Link>
      </div>
      <div className={classes.vaultDescr}>
          <div className={classes.vaultTVL}>
            <div className={classes.vaultTVLTitle}>Total Deposited</div>
            <div className={classes.vaultTValue}>{item.vaultByDeposited.props.children}</div>
          </div>
          <div className={classes.vaultHarvest}>
            <div className={classes.vaultHarvestTitle}>Last harvest:</div>
            { item.lastHarvest &&
              <div className={classes.vaultHarvestValue}>{moment.unix(item.lastHarvest).fromNow()}</div>
            }
          </div>
        </div>
    </div>
  )
}

export default VaultsInfoHeader
