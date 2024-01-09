import React from 'react'
import classes from './Button.module.scss'

const buttonActive = {
  border: '1px solid #8EC300'
}

const Button = ({text}) => {
  return (
    <button className={classes.Button}>
        {text}
    </button>
  )
}

export default Button
