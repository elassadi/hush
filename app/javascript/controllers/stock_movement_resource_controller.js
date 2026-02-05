import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {

  static targets = ['stockLocationBelongsToInput', 'stockAreaBelongsToInput', 'articleBelongsToInput'] // use the target Avo prepared for you
  static values = { view: String }
  static preSelectedArea

  get placeholder() {
    return this.stockLocationBelongsToInputTarget.options[0].label
  }


  async connect() {

    if (['new'].includes(this.viewValue)) {
      this.preSelectedArea = null
      await this.onArticleChange()
      await this.onStockLocationChange()
    }
  }


  // Read the country select.
  // If there's any value selected show the areas and prefill them.
  async onStockLocationChange() {
    if (this.hasStockLocationBelongsToInputTarget && this.stockLocationBelongsToInputTarget) {
      const location = this.stockLocationBelongsToInputTarget.value
      // Dynamically fetch the areas for this country
      const areas = await this.fetchStockAreasByLocation(location)

      this.populate_dropdown(this.stockAreaBelongsToInputTarget, areas, this.preSelectedArea)
    }
  }


  async onArticleChange() {



    if (this.hasArticleBelongsToInputTarget && this.articleBelongsToInputTarget) {
      const article = this.articleBelongsToInputTarget.value
      if (!article) {
        return
      }

      const stockObject = await this.fetchDefaultStockByArticle(article)

      this.stockLocationBelongsToInputTarget.value = stockObject.location
      this.preSelectedArea = stockObject.area
      await this.onStockLocationChange()

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

    dropdown.value = selected_value || dropdown.options[0].value
  }

  // Private

  captureTheInitialValue() {
    this.initialValue = this.stockAreaBelongsToInputTarget.value
  }

  async fetchDefaultStockByArticle(article){
    if (!article) {
      return {}
    }

    this.loading = true

    const response = await fetch(
      `${window.Avo.configuration.root_path}/resources/stocks/default_stock?article=${article}`,
    )
    const data = await response.json()

    this.loading = false

    return data
  }

  async fetchStockAreasByLocation(location){
    if (!location) {
      return []
    }

    this.loading = true

    const response = await fetch(
      `${window.Avo.configuration.root_path}/resources/stocks/areas?location=${location}`,
    )
    const data = await response.json()

    this.loading = false

    return data
  }
}
