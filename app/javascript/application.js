// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", () => {
  const navbarBurger = document.querySelector(".navbar-burger");
  const navbarMenu = document.querySelector(".navbar-menu");

  if (navbarBurger && navbarMenu) {
    navbarBurger.addEventListener("click", () => {
      navbarBurger.classList.toggle("is-active");
      navbarMenu.classList.toggle("is-active");
    });
  }
});

document.addEventListener("turbo:load", function () {
  const dropdown = document.getElementById("myDropdown");
  const trigger = dropdown.querySelector(".dropdown-trigger button");

  trigger.addEventListener("click", function () {
    dropdown.classList.toggle("is-active"); // Toggle dropdown visibility
  });

  // Close dropdown when clicking outside
  document.addEventListener("click", function (event) {
    if (!dropdown.contains(event.target)) {
      dropdown.classList.remove("is-active");
    }
  });
});