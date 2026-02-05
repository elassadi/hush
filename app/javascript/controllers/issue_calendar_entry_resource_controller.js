import { Controller } from "@hotwired/stimulus"


export default class extends Controller {

  static targets = [
    'entryTypeSelectInput'
  ]
  static values = { view: String }



  async connect() {



    if (this.viewValue == 'new' || this.viewValue == 'edit') {
      this.initDraftEvent()
    }else if (this.viewValue == 'show') {
      this.jumpToEvent()
      this.setSelectedEventIdOnly()
    }

  }


  initDraftEvent() {
    // Check if the draft event has already been created
    if (this.initDraftEventCreated) {
      return;
    }



    // Attempt to get the controllers
    let embeddedController = this.getEmbeddedCalendarController();
    let dtimController = this.getDtimeController();
    const element = document.querySelector('[data-model-name="CalendarEntry"][data-model-id]');

    // Access the value of the data-model-id attribute
    let modelId= undefined

    if (element) {
      modelId = element.dataset.modelId;
    }

    // If both controllers are available, proceed with creating the draft event
    if (embeddedController && dtimController) {

      this.initDraftEventCreated = true;

      let { startDate, endDate } = dtimController.getDtimeValue();

      embeddedController.createDraftEvent({
        startStr: startDate.toISOString(),
        endStr: endDate.toISOString()
      });
      embeddedController.calendar.gotoDate(startDate);
      embeddedController.setSelectedEventId(modelId);
    } else {
      // If either controller is not ready, retry after 200ms
      setTimeout(() => {
        this.initDraftEvent();
      }, 50);
    }
  }


  setSelectedEventIdOnly() {
    // Attempt to get the controllers
    let embeddedController = this.getEmbeddedCalendarController();
    const element = document.querySelector('[data-model-name="CalendarEntry"][data-model-id]');

    // Access the value of the data-model-id attribute
    let modelId= undefined

    if (element) {
      modelId = element.dataset.modelId;
    }

    // If both controllers are available, proceed with creating the draft event
    if (embeddedController) {
      embeddedController.setSelectedEventId(modelId);
    } else {
      // If either controller is not ready, retry after 200ms
      setTimeout(() => {
        this.setSelectedEventIdOnly();
      }, 50);
    }
  }




  jumpToEvent(attempt = 1) {
    // Attempt to get the controllers
    let embeddedController = this.getEmbeddedCalendarController();

    // If both controllers are available, proceed with creating the draft event
    if (embeddedController ) {
      const startAtValue = document.getElementById('dtime-field-start-at').value;
      let embeddedController = this.getEmbeddedCalendarController();
      embeddedController.calendar.gotoDate(startAtValue);
    } else if(attempt < 5){
      // If either controller is not ready, retry after 200ms
      setTimeout(() => {
        this.jumpToEvent( attempt + 1);
      }, 50);
    }
  }

  getDtimeController() {
    return this.application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller~="dtime-field"]'),
        "dtime-field"
    )
  }


  getEmbeddedCalendarController() {
    return this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller~="embedded-calendar"]'),
      "embedded-calendar"
    )
  }


  onEntryTypeSelectChange(event) {
    this.hide_or_show_inputs()
  }

  hide_or_show_inputs() {
    let value = this.entryTypeSelectInputTarget.selectedOptions[0].value
    switch (value) {
      case 'user':
        this.hideElements([this.customerBelongsToWrapperTarget])
        this.showElements([this.userBelongsToWrapperTarget])
        break;
      case 'customer':
      case 'regular':
        this.hideElements([this.userBelongsToWrapperTarget])
        this.showElements([this.customerBelongsToWrapperTarget])
        break;
      default:
        this.hideElements(this.allInputs())
    }
  }

  allInputs() {
    return [
      this.userBelongsToWrapperTarget,
      this.customerBelongsToWrapperTarget
    ]
  }

  disconnect() {



  }


  // Private

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


}
