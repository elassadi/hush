import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [  ] // use the target Avo prepared for you
  static values = { view: String }

  async connect() {

    // if (['show'].includes(this.viewValue)) {
    //   document.addEventListener("resourceCreated", this.handleResourceCreated.bind(this))
    // }

  }



  disconnect() {

  }

}
