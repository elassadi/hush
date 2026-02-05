import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ['profileButton', 'profileMenuContainer', 'dropdownNotification'] // use the target Avo prepared for you
  static values = {view: String} // use the target Avo prepared for you


  connect() {
    //this.eventNameTextWrapperTarget.textContent = this.viewValue
    document.addEventListener('click', this.onClickOutsideDropDownNotificationWindow.bind(this)) // Listen for outside clicks
  }

  disconnect() {
    document.removeEventListener('click', this.onClickOutsideDropDownNotificationWindow.bind(this)) // Clean up event listener when disconnected
  }

  showProfileMenu(){
    this.showElements(this.profileMenuContainerTarget)
  }

  outsideClick(event) {
      // Ignore event if clicked within element
      if(this.element === event.target || this.element.contains(event.target)) return;

      // Execute the actual action we're interested in
      this.closeProfileMenu()

      if (this.hasDropdownNotificationTarget)
        this.hideElements(this.dropdownNotificationTarget)

  }


  onClickOutsideDropDownNotificationWindow(event) {
    // Check if the click happened outside the dropdownNotification
    if (!this.hasDropdownNotificationTarget)
      return

    if (this.dropdownNotificationTarget.contains(event.target)) return;

    // Hide the dropdown if clicked outside
    this.hideElements(this.dropdownNotificationTarget)
  }

  closeProfileMenu(){
    this.hideElements(this.profileMenuContainerTarget)
  }

  updateDropdownNotificationFrame() {



    var el = document.getElementById("dropdownNotificationFrame")
    el.reload()


     // Listen for the Turbo Frame load event to show the dropdown
  el.addEventListener('turbo:frame-load', () => {
    let dropdown = document.querySelectorAll("#dropdownNotification")[0]
    if (dropdown) {
      dropdown.style.position = "absolute"
      this.showElements(dropdown)
    }
    //this.showElements(this.dropdownNotificationTarget)
  })
        //this.showElements(this.dropdownNotificationTarget)


  }


  async hideElements(elements) {
    Array(elements).flat().forEach((el) => {
      el.classList.add("hidden")
    })
  }

  async showElements(elements) {
    Array(elements).flat().forEach((el) => {
      el.classList.remove("hidden")
    })
  }

}
