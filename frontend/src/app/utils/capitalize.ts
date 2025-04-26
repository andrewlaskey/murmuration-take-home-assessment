export function capitalize(str: string) {
  return str
    .replace(/_/g, " ")
    .split(" ")
    .map((word) => {
      if (word.length === 0) return "";
      return word[0].toUpperCase() + word.slice(1).toLowerCase();
    })
    .join(" ");
}
