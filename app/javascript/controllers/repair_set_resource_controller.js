import { Controller } from "@hotwired/stimulus"
import RecloudApi from "controllers/helpers/api"



export default class extends Controller {

  static targets = ['deviceColorBelongsToInput', 'deviceModelBelongsToInput'] // use the target Avo prepared for you
  static values = { view: String }
  static preSelectedArea

  get placeholder() {
    return "i18n_please_select_an_option"
  }


  async connect() {

    this.recloudApi = new RecloudApi(this)
    //this.boundUpdateSummaryFrame = this.updateSummaryFrame.bind(this)
    //document.addEventListener("turbo:frame-load", this.boundUpdateSummaryFrame)

  }

  disconnect() {
    document.removeEventListener("turbo:frame-load", this.boundUpdateSummaryFrame)
  }

  updateSummaryFrame(event) {

    if (event.target.id == "has_many_field_show_repair_set_entries"){
      var el = document.getElementById("summary")
      //el.reload()
    }
  }



  async onDeviceModelChange(event) {


    if (!event || event.target.type != 'hidden')
    return

    var el = this.deviceModelBelongsToInputTargets.find(element => element.type === 'hidden');

    if (el) {
      const device_model_id = el.value
      if (!device_model_id) {
        return
      }

      const colors = await this.recloudApi.fetchDeviceColorsByDeviceModeldId(device_model_id)


      this.recloudApi.populate_dropdown(this.deviceColorBelongsToInputTarget, colors)

    }
  }


  // Private



}
