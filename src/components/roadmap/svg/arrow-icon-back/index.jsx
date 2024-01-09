import React from "react";

const Index = ({isActive}) => {
  return (
    <svg
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M15 18L9 12L15 6"
        stroke={!isActive ?"rgba(229, 232, 223, 1)":"rgba(142, 195, 0, 1)"}
        strokeWidth="2"
        strokeLinecap="round"
      />
    </svg>
  );
};

export default Index;
