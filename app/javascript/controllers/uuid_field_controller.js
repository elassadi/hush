import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = []
  static values = {
    view: String
  }


  connect() {


  }

  disconnect() {
  }


  onUuidFieldClicked(event) {
    event.preventDefault();

    const uuidContent = this.element.textContent.trim();

    // Copy the content of the span to the clipboard
    navigator.clipboard.writeText(uuidContent).then(() => {
      // Create the badge element
      const badge = document.createElement("span");
      badge.textContent = "Kopiert";
      badge.classList.add("copied-badge");
      this.element.appendChild(badge);

      const spanRect = event.target.getBoundingClientRect();
      badge.style.top = "40px"


      // Show the badge with transition
      badge.classList.add("show");

      // Remove the badge after 2 seconds
      setTimeout(() => {
        badge.classList.remove("show");
        setTimeout(() => badge.remove(), 300); // Remove after transition ends
      }, 500);
    }).catch(err => {
      console.error('Failed to copy text: ', err);
    });
  }
}
