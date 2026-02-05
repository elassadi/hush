import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {

  static targets = ['draftDeviceColorBelongsToInput', 'draftDeviceModelBelongsToInput'] // use the target Avo prepared for you

  static values = { view: String }
  static preSelectedArea

  get placeholder() {
    return "i18n_please_select_an_option"
  }


  async connect() {


    if (['edit'].includes(this.viewValue)) {

    }
  }


  async onDeviceModelChange(event) {



    if (!event || event.target.type != 'hidden')
      return

    var el = this.draftDeviceModelBelongsToInputTargets.find(element => element.type === 'hidden');


    if (el) {
      const device_model_id = el.value
      // Dynamically fetch the areas for this country
      if (!device_model_id) {
        return
      }

      const colors = await this.fetchDeviceColorsByDeviceModeldId(device_model_id)
      this.populate_dropdown(this.draftDeviceColorBelongsToInputTarget, colors)


      this.draftDeviceColorBelongsToInputTarget.dispatchEvent(new Event('click'));


    }
  }



  populate_dropdown(dropdown, values,  selected_value=null) {

    Object.keys(dropdown.options).forEach(() => {
      dropdown.options.remove(0)
    })

    // Add blank option
    dropdown.add(new Option(this.placeholder))

    // Add the new areas
    values.forEach((value) => {
      dropdown.add(new Option(value[1], value[0]))
    })

  }

  // Private


  async fetchDeviceColorsByDeviceModeldId(device_model_id){
    if (!device_model_id) {
      return []
    }

    this.loading = true

    const response = await fetch(
      `${window.Avo.configuration.root_path}/resources/devices/colors?device_model_id=${device_model_id}`,
    )
    const data = await response.json()

    this.loading = false

    return data
  }
}
