export default class Api {

  constructor(controller) {
    this.controller = controller
  }


  async fetchDeviceColorsByDeviceModeldId(device_model_id){
    if (!device_model_id) {
      return []
    }

    this.loading = true

    const response = await fetch(
      `${window.Avo.configuration.root_path}/resources/devices/list_colors?device_model_id=${device_model_id}`,
    )
    const data = await response.json()

    this.loading = false

    return data
  }

  async fetchDeviceByImei(imei){
    if (!imei) {
      return
    }

    this.loading = true

    const response = await fetch(
      `${window.Avo.configuration.root_path}/resources/devices/fetch_by_imei?imei=${imei}`,
    )
    const data = await response.json()

    this.loading = false

    return data
  }

  populate_dropdown(dropdown, values,  selected_value=null) {

    Object.keys(dropdown.options).forEach(() => {
      dropdown.options.remove(0)
    })

    // Add blank option
    dropdown.add(new Option(this.i18n('select_an_option'), ''))

    // Add the new areas
    values.forEach((value) => {
      dropdown.add(new Option(value[1], value[0]))
    })
  }


  // private

  i18n (key) {
    return (window.Recloud.configuration.i18n[key] || key)
  }




}