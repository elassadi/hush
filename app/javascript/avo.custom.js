// eslint-disable-next-line no-console
import { Application } from "@hotwired/stimulus"
import "controllers"
import Swal from 'sweetalert2';


window.Swal = Swal;

const application = window.Stimulus

application.debug = window?.localStorage.getItem('avo.debug')

function scrollActiveMenuItemIntoView() {
  const activeMenuItem = document.querySelector(".application-sidebar a.active");

  if (activeMenuItem) {
    activeMenuItem.scrollIntoView({
      behavior: "auto",
      block: "center",
    });
  }
}

document.addEventListener("DOMContentLoaded", scrollActiveMenuItemIntoView);
document.addEventListener("turbo:frame-load", scrollActiveMenuItemIntoView);


document.addEventListener("turbo:load", () => {
  document.addEventListener("turbo:before-stream-render", (event) => {
    const action = event.target.getAttribute("data-turbo-stream-action");

    if (action === "reload_frame") {

      const frameId = event.target.getAttribute("target");
      const frame = document.getElementById(frameId);
      if (frame) {
        frame.reload();
      }
      event.preventDefault();
    }
  });
});