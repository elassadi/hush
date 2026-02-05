import { Controller } from "@hotwired/stimulus"


export default class extends Controller {


  static values = { view: String }
  static event_target = ""


  async connect() {

    if (this.viewValue != 'show')
      return

    this.event_target = this.transformString (this.element.dataset.resourceName)
    this.boundUpdateSummaryFrame = this.updateSummaryFrame.bind(this)
    document.addEventListener("turbo:frame-load", this.boundUpdateSummaryFrame)

  }

  disconnect() {
    document.removeEventListener("turbo:frame-load", this.boundUpdateSummaryFrame)
  }

  transformString(inputStr) {
    let outputStr = inputStr.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase();
    outputStr = outputStr.replace(/_resource/, '');
    outputStr = `has_many_field_show_${outputStr}_entries`;
    return outputStr;
  }

  updateSummaryFrame(event) {
    if (event.target.id == this.event_target){
      var el = document.getElementById("summary")
      el.reload()
    }
  }

}
