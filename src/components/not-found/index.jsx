import React from 'react'
import classes from "./notFound.module.scss"

const Index = () => {
  return (
    <div className={classes.not__found_block}>
      <p className={classes.not__found_title}>No results found</p>
      <p className={classes.not__found_text}>Try clearing your filters or changing your search term</p>
      </div>
  )
}

export default Index