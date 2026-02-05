import { Controller } from "@hotwired/stimulus"
import RecloudApi from "controllers/helpers/api"
import Swal from 'sweetalert2';


export default class extends Controller {

  static targets = ['deviceColorBelongsToInput', 'deviceModelBelongsToInput',
    'imeiTextInput'] // use the target Avo prepared for you
  static values = { view: String }




  connect() {

    window.cont = this

    this.recloudApi = new RecloudApi(this)
    if (this.hasDeviceColorBelongsToInputTarget)
      this.placeholder = this.deviceColorBelongsToInputTarget.options[0].text

  }

  async onImeiChange(event) {



    let imei = this.imeiTextInputTarget.value
    if (imei.length < 8 )
      return


    let device = await this.recloudApi.fetchDeviceByImei(imei)
    if (!device)
      return

    var el = this.deviceModelBelongsToInputTargets.find(element => element.type === 'hidden');
    var old_model_id = el.value
    el.setAttribute("value", device.device_model_id)

    var el = this.deviceModelBelongsToInputTargets.find(element => element.type === 'text');
    var old_model = el.value
    el.setAttribute("value", device.name)

    var new_model = device.name

    var old_color = this.deviceColorBelongsToInputTarget.selectedOptions[0].text

    if (this.viewValue != "new" && old_model_id != device.device_model_id) {
      await Swal.fire({
        title: 'Achtung!',
        html: `Das Gerät mit dem Modell <b>"${old_model} ${old_color}"</b> wurde durch das neue Modell <b>"${new_model}"</b> ersetzt. Bitte überprüfen Sie die Daten und wählen Sie eine neue Farbe für das Gerät aus.`,
        icon: 'warning',
        confirmButtonText: 'Verstanden',
        customClass: {
          confirmButton: 'custom-confirm-button' // Tailwind class for background color
        }
      });
    }
    return await this.onDeviceModelChange({target: {type: 'hidden'}})
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
