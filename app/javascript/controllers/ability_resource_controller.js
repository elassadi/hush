import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {

  static targets = ['resourceSelectInput', 'actionTagsTagsWrapper'] // use the target Avo prepared for you
  static values = {view: String} // use the target Avo prepared for you

  connect() {

    //this.resourceSelectWrapperTarget.textContent = "vvvvvvv"
  }
  __onResourceChanges (event) {
    this.actionTagsTagsWrapperTarget.classList.add("hidden")
  }


  onResourceChanges (event) {
    let resource = this.resourceSelectInputTarget.selectedOptions[0].value
    let url = `${window.Avo.configuration.root_path}/resources/abilities/actions?resource=${resource}`

    get(url, {
        responseKind: "turbo-stream"
      }
    )

  }
}
