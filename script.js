const yearEl = document.getElementById("year");
if (yearEl) {
  yearEl.textContent = new Date().getFullYear();
}

function detectBrowser() {
  const ua = navigator.userAgent;
  if (ua.includes("Edg/")) return "edge";
  if (ua.includes("OPR/") || ua.includes("Opera")) return "opera";
  if (ua.includes("Firefox/")) return "firefox";
  if (ua.includes("Chrome/") && !ua.includes("Edg/")) return "chrome";
  if (ua.includes("Safari/") && !ua.includes("Chrome/")) return "safari";
  return "browser";
}

const whoamiEl = document.getElementById("whoami-line");
if (whoamiEl) {
  const text = `visitor@${detectBrowser()}:~$ whoami`;
  let i = 0;
  const type = () => {
    whoamiEl.textContent = text.slice(0, i);
    i++;
    if (i <= text.length) {
      setTimeout(type, 35);
    }
  };
  type();
}
