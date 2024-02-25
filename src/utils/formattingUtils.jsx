import { formatCurrency } from "@coingecko/cryptoformat";
import millify from 'millify';

const removeTrailingZeros = (strNumber) => {
  // Remove trailing zeros after decimal point and the decimal point itself if not needed
  return strNumber.replace(/(\.\d*?)0+$/, "$1").replace(/\.$/, "");
};

export const formatNumber = (number, currency = "", humanize = { enabled: true, threshold: 100000000 }) => {
  if (!number || isNaN(number) || number === 0n || parseInt(number) === 0) {
    return <span>{`0 ${currency}`}</span>;
  }

  // Humanize large numbers
  if (humanize.enabled && Math.abs(number) >= humanize.threshold) {
    return <span>{millify(number, { precision: 2, lowercase: true })} {currency}</span>;
  }

  // Format currency for numbers over 10000
  if (number >= 10000) {
    return <span>{formatCurrency(parseFloat(number), currency, "en")}</span>;
  }

  // Scientific notation for very small numbers
  if (number < 1e-5) {
    const power = Math.floor(Math.log10(number) * -1) - 1;
    const scaledNumber = number * Math.pow(10, power + 1);
    const formattedNumber = removeTrailingZeros(scaledNumber.toFixed(5));

    return (
      <>
        <span>0.0</span>
        <sub>{power}</sub>
        <span>{formattedNumber.substring(2)} {currency}</span>
      </>
    );
  }

  // Default formatting
  const precision = getPrecisionValue(number);
  const formattedNumber = removeTrailingZeros(Number(number).toFixed(precision));
  return <span>{`${formattedNumber} ${currency}`}</span>;
};

function getPrecisionValue(value) {
  if (value < 1e-19) return 20;
  if (value < 1e-18) return 19;
  if (value < 1e-17) return 18;
  if (value < 1e-16) return 17;
  if (value < 1e-15) return 16;
  if (value < 1e-14) return 15;
  if (value < 1e-13) return 14;
  if (value < 1e-12) return 13;
  if (value < 1e-11) return 12;
  if (value < 1e-10) return 11;
  if (value < 1e-9) return 10;
  if (value < 1e-8) return 9;
  if (value < 1e-7) return 8;
  if (value < 1e-6) return 7;
  if (value < 1e-5) return 6;
  if (value < 1e-4) return 5;
  if (value < 1e-3) return 4;
  if (value < 1e-2) return 3;
  if (value < 1e-1) return 3;
  if (value < 1e3) return 2;
  if (value < 1e4) return 2;
  if (value < 1e5) return 1;

  return 0;
}

export function shortenId(id, length = 3) {
  const first = id.slice(0, length)
  const last = id.slice(-length)
  return `${first}...${last}`
}