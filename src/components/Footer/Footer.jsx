import React from 'react'
import classes from './Footer.module.scss'
import headerLogo from '../../images/Logo.svg'
import {Link} from 'react-router-dom'

const Footer = () => {
  return (
    <footer className={classes.Footer}>
      <div className={classes.FooterUp}>
        <Link href="#">Docs</Link>
        <Link className={classes.LogoLink}>
            <img src={headerLogo} alt="logo" to={'/'}/>
        </Link>
        <Link href="#">Audit</Link>
      </div>
      <a href="mailto:hi@bau.finance" className={classes.FooterEmail}>hi@bau.finance</a>
      <nav className={classes.FooterLinks}>
        <Link href="#">Twitter</Link>
        <Link href="#">Github</Link>
        <Link href="#">Telegram</Link>
        <Link href="#">Mirror</Link>
        <Link href="#">Discord</Link>
      </nav>
      <div className={classes.footerCopyWrite}>© | 2023 | Bau.Finance</div>
    </footer>
  )
}

export default Footer
