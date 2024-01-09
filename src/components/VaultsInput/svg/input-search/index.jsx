import React from 'react'
import styles from "./input.search.module.scss"

const Index = () => {
  return (
    <svg
          className={styles.input__search}
          viewBox="0 0 24 24"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            fillRule="evenodd"
            clipRule="evenodd"
            d="M10.4 14.6667C12.7564 14.6667 14.6667 12.7564 14.6667 10.4C14.6667 8.04359 12.7564 6.13333 10.4 6.13333C8.04358 6.13333 6.13333 8.04359 6.13333 10.4C6.13333 12.7564 8.04358 14.6667 10.4 14.6667ZM16.8 10.4C16.8 6.86538 13.9346 4 10.4 4C6.86538 4 4 6.86538 4 10.4C4 13.9346 6.86538 16.8 10.4 16.8C11.7822 16.8 13.0621 16.3618 14.1083 15.6168L18.1791 19.6876C18.5956 20.1041 19.271 20.1041 19.6876 19.6876C20.1041 19.271 20.1041 18.5956 19.6876 18.1791L15.6168 14.1083C16.3618 13.0621 16.8 11.7822 16.8 10.4Z"
            fill="#E5E8DF"
          />
        </svg>
  )
}

export default Index