import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {

  static targets = ['priceFieldInput', 'priceFieldNettoBruttoSpan', 'priceFieldNettoBruttoLabel',
  'hiddenPriceFieldInput']
  static values = {
    view: String
  }


  connect() {
    if (['new', 'create', 'edit'].includes(this.viewValue)) {
      // set an intastance to be used from other controller to change the value
      this.priceFieldInputTarget["priceField"] = this
      this.priceFieldInputTarget.addEventListener('focus', this.onPriceFieldFocus)
      if (this.isOnlyVisibleInputField()) {
        this.priceFieldInputTarget.focus();
      }
    }

  }

  disconnect() {}


  onPriceFieldFocus(event){
    event.target.select();
  }

  isOnlyVisibleInputField() {
    const form = this.priceFieldInputTarget.closest('form');
    const visibleInputFields = form.querySelectorAll('input[type="text"], input[type="number"], input[type="email"], input:not([type]), input[type="password"], input[type="date"], input[type="datetime-local"], input[type="month"], input[type="search"], input[type="tel"], input[type="time"], input[type="url"], input[type="week"]');
    return visibleInputFields.length === 1;
  }


  toggle_input_mode(){
    let input_element = this.priceFieldInputTarget

    if (this.input_mode() == "brutto"){
      input_element.value = this.brutto_to_netto().toFixed(2)
      this.set_input_mode("netto")
    } else {
      input_element.value = this.netto_to_brutto().toFixed(2)
      this.set_input_mode("brutto")
    }
    this.setPriceFieldNettoBruttoLabel()
    this.updateNettoBruttoField()
  }

  netto_to_brutto(netto){
    let input_element = this.priceFieldInputTarget
    if (!netto)
      netto = input_element.value

    return this.toFloat(netto) * (1 + this.tax_percent(input_element))
  }

  brutto_to_netto(brutto){
    let input_element = this.priceFieldInputTarget

    if (!brutto)
      brutto = input_element.value

    return this.toFloat(brutto) / (1 + this.tax_percent(input_element))
  }

  input_mode(){
    return this.priceFieldInputTarget.attributes["data-input-mode"].value || "netto"
  }

  set_input_mode(value){
    this.priceFieldInputTarget.setAttribute("data-input-mode", value)
  }

  tax_percent(){
    return this.toFloat(this.priceFieldInputTarget.attributes["data-tax-value"].value)/100.0
  }

  adjustNettoValue(){
    let mode = this.input_mode(input_element)
    if (mode == "netto"){
      return
    }
    this.priceFieldInputTarget.value = (this.netto_to_brutto() || 0.0).toFixed(2)
  }

  setPriceFieldNettoBruttoLabel(){
    this.priceFieldNettoBruttoLabelTarget.textContent =  (this.input_mode() == "netto") ?   "btto" : "ntto "
  }

  onFocus(event) {
    event.target.select();
  }

  onpriceFieldNettoBruttoLabelClicked(event){
    this.toggle_input_mode()
  }

  onPriceInputChanged(event){
    if (!this.setZeroValue()) {
      this.updateNettoBruttoField()
      this.hiddenPriceFieldInputTarget.value = this.rawNettoValue()
    }
  }

  updateNettoBruttoField() {
    if (this.hasPriceFieldNettoBruttoSpanTarget)
      this.priceFieldNettoBruttoSpanTarget.textContent = this.calculateNettoBruttoValue()
  }



  setZeroValue() {

    let input_element = this.priceFieldInputTarget

    if (input_element.value)
      return false

    input_element.value = "0.0"
    input_element.select();
    return true
  }

  calculateNettoBruttoValue(){

    let mode = this.input_mode()
    if (mode == "netto"){
      return (this.netto_to_brutto() || 0.0).toFixed(2)
    }else {
      return (this.brutto_to_netto() || 0.0).toFixed(2)
    }
  }

  rawNettoValue(){

    let input_element = this.priceFieldInputTarget

    let mode = this.input_mode()
    if (mode == "netto"){
      return input_element.value
    }

    return this.brutto_to_netto() || 0.0
  }

  setRawNettoValue(value){

    let input_element = this.priceFieldInputTarget

    let mode = this.input_mode()
    if (mode == "brutto"){
      value = (this.netto_to_brutto(value) || 0.0).toFixed(2)
    }else{
      value = ( parseFloat(value) || 0.0).toFixed(2)
    }
    input_element.value = value
    input_element.dispatchEvent(new Event('input'))
  }

  toFloat(value) {
    if (!value)
      return 0.0

    return parseFloat(value.toString().replace(",","."));
  }


}
