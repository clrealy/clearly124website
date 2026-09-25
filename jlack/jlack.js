const copyBtn = document.getElementById("copy-btn");
const installCmd = document.getElementById("install-cmd");

if (copyBtn && installCmd) {
  copyBtn.addEventListener("click", async () => {
    try {
      await navigator.clipboard.writeText(installCmd.textContent);
      const original = copyBtn.textContent;
      copyBtn.textContent = "Copied!";
      setTimeout(() => {
        copyBtn.textContent = original;
      }, 1500);
    } catch (err) {
      copyBtn.textContent = "Ctrl+C";
    }
  });
}
