import {
  Controller
} from "@hotwired/stimulus"

import {
  get
} from "@rails/request.js"

export default class extends Controller {

  static targets = ['articleTypeSelectInput', 'eanTextInput', 'eanTextWrapper',
    'defaultPurchasePricePriceWrapper', 'defaultRetailPricePriceWrapper', "marginPriceWrapper",
    'defaultPurchasePricePriceInput', 'defaultRetailPricePriceInput', 'marginPriceInput',
    'pricingStrategieSelectInput', 'pricingStrategieSelectInputWrapper',

    'defaultRetailPricePriceHidden',
    'defaultPurchasePricePriceHidden',
    'marginPriceHidden'

  ]
  static values = {
    view: String
  }

  connect() {
    if (['new', 'create', 'edit'].includes(this.viewValue)) {
      this.onArticleTypeChange()
      this.onPricingStrategieChange()
    }
    if (['show'].includes(this.viewValue)) {
      document.addEventListener("resourceCreated", this.handleResourceCreated.bind(this))
    }
  }

  disconnect() {
    document.removeEventListener("resourceCreated", this.handleResourceCreated.bind(this))
  }

  handleResourceCreated(event) {
    const { resourceModelName, resourceModelId } = event.detail

    if (resourceModelName === "stock_movement") {
      setTimeout(() => {
        var el = document.getElementById("has_one_field_show_side_bar_stocks")
        if (el) {
          el.reload()
        }
      }, 350)
    }



  }

  onPricingStrategieChange(event) {

    let value = this.pricingStrategieSelectInputTarget.selectedOptions[0].value

    switch (value) {
      case 'disabled':
        this.hideElements([this.marginPriceWrapperTarget, this.defaultPurchasePricePriceWrapperTarget])
        break;
      case 'absolut':
        this.showElements([this.marginPriceWrapperTarget, this.defaultPurchasePricePriceWrapperTarget])
        var el = this.marginPriceWrapperTarget.getElementsByClassName("input-icon")[0]
        el.textContent = "€"
        break;
      case 'percentage':
        this.showElements([this.marginPriceWrapperTarget, this.defaultPurchasePricePriceWrapperTarget])
        var el = this.marginPriceWrapperTarget.getElementsByClassName("input-icon")[0]
        el.textContent = "%"
        break;
    }
    this.calculateAndUpdateMargin()
  }

  onArticleTypeChange(event) {
    let value = this.articleTypeSelectInputTarget.selectedOptions[0].value
    if (value == "basic") {
      this.showElements([this.eanTextWrapperTarget, this.defaultPurchasePricePriceWrapperTarget])
    } else {
      this.hideElements([this.eanTextWrapperTarget, this.defaultPurchasePricePriceWrapperTarget])
    }
  }

  onDefaultPurchasePriceChanged(event){
    this.calculateAndUpdateMargin(event)
  }

  onDefaultRetailPriceChanged(event) {
    this.calculateAndUpdateMargin(event)
  }

  onMarginChanged(event){

    this.calculateAndUpdateRetailPrice(event)
  }

  calculateAndUpdateMarginAbsoulte() {

    let purchase = this.toFloat(this.defaultPurchasePricePriceHiddenTarget.value)
    let target_value = this.toFloat(this.defaultRetailPricePriceHiddenTarget.value)

    return target_value - purchase
  }

  calculateAndUpdateMarginPercentage() {

    let purchase = this.toFloat(this.defaultPurchasePricePriceHiddenTarget.value)
    let target_value = this.toFloat(this.defaultRetailPricePriceHiddenTarget.value)


    return (target_value/purchase - 1) * 100


  }

  calculateAndUpdateMargin() {

    if (this.stop_reenter)
      return

    this.stop_reenter = true

    let pricing_strategie = this.pricingStrategieSelectInputTarget.selectedOptions[0].value

    let margin = 0

    if (pricing_strategie == "disabled") {
      this.stop_reenter = false
      return;
    }

    if (pricing_strategie == "absolut") {
      margin = this.calculateAndUpdateMarginAbsoulte()
    }

    if (pricing_strategie == "percentage") {
      margin = this.calculateAndUpdateMarginPercentage()
    }

    this.updateFieldAttribute(this.marginPriceInputTarget, "value", this.toFixed(margin))

    this.stop_reenter = false
  }

  calculateAndUpdateRetailPrice() {

    if (this.stop_reenter)
      return

    this.stop_reenter = true

    let pricing_strategie = this.pricingStrategieSelectInputTarget.selectedOptions[0].value

    let price = 0

    if (pricing_strategie == "disabled") {

      this.stop_reenter = false
      return;
    }

    if (pricing_strategie == "absolut") {
      let purchase = this.toFloat(this.defaultPurchasePricePriceHiddenTarget.value)
      let margin = this.toFloat(this.marginPriceInputTarget.value)

      price =  margin +  purchase
    }

    if (pricing_strategie == "percentage") {
      let purchase = this.toFloat(this.defaultPurchasePricePriceHiddenTarget.value)
      let margin = this.toFloat(this.marginPriceInputTarget.value)

      price = purchase + (purchase * margin/100.0)
    }

    this.defaultRetailPricePriceInputTarget["priceField"].setRawNettoValue(this.toFixed(price))

    this.stop_reenter = false
  }

  hideElements(elements) {
    Array(elements).flat().forEach((el) => {
      el.classList.add("hidden")
    })
  }

  showElements(elements) {
    Array(elements).flat().forEach((el) => {
      el.classList.remove("hidden")
    })
  }

  toFloat(value) {
    if (!value)
      return 0.0

    return parseFloat(value.replace(",", "."));
  }

  toFixed(value) {
    if (!value || value<=0)
      return 0.0

    return value.toFixed(2)
  }

  updateFieldAttribute(target, attribute, value) {
    target.value = value
    target.setAttribute(attribute, value)
    target.dispatchEvent(new Event('input'))
  }
}
