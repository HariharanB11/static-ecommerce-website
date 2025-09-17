// Simple JS to handle Buy button clicks
document.addEventListener("DOMContentLoaded", () => {
  const buttons = document.querySelectorAll(".card button");
  buttons.forEach((btn) => {
    btn.addEventListener("click", () => {
      alert("Thank you for your interest! (Demo only)");
    });
  });
});
