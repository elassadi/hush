import { Controller } from "@hotwired/stimulus"


export default class extends Controller {

  static targets = [
    'entryTypeSelectInput',
    'userBelongsToInput',
    'userBelongsToWrapper',
    'customerBelongsToInput',
    'customerBelongsToWrapper',
    'allDayBooleanInput',
    'categorySelectWrapper',
    'notifyCustomerBooleanWrapper',
    'confirmAndNotifyCustomerBooleanWrapper',
    'selectedRepairSetBelongsToWrapper',
  ]
  static values = { view: String }



  async connect() {
    if (this.viewValue == 'new' || this.viewValue == 'edit') {
      this.hideOrShowInputs()
    }
    this.hideShowDtimeTimeInputs();
  }


  hideShowDtimeTimeInputs() {


    if (!this.hasAllDayBooleanInputTarget)
      return


    const value = Boolean(this.allDayBooleanInputTarget.checked)

    const dtimeController =  this.getCalendarEntryEventDtimeFieldResourceController()

    if (dtimeController) {
      dtimeController.allDay(value)
    }else {
        setTimeout(() => {
          this.hideShowDtimeTimeInputs(value)
        }, 200);
    }
  }


  onAllDayChanged(event) {
    this.hideShowDtimeTimeInputs()
  }

  onEntryTypeSelectChanged(event) {

    this.hideOrShowInputs()
  }
  hideOrShowInputs() {
    let value = this.entryTypeSelectInputTarget.selectedOptions[0].value;
    switch (value) {
      case 'blocker':
        this.hideElements([
          'customerBelongsToWrapper',
          'notifyCustomerBooleanWrapper',
          'confirmAndNotifyCustomerBooleanWrapper',
          'userBelongsToWrapper',
          'selectedRepairSetBelongsToWrapper'
        ]);
        this.showElements([
          'categorySelectWrapper'
        ]);
        break;
      case 'user':
        this.hideElements([
          'customerBelongsToWrapper',
          'notifyCustomerBooleanWrapper',
          'confirmAndNotifyCustomerBooleanWrapper',
          'selectedRepairSetBelongsToWrapper'
        ]);
        this.showElements([
          'userBelongsToWrapper',
          'categorySelectWrapper'
        ]);
        break;
      case 'customer':
      case 'repair':
        if (this.viewValue == 'new') {
          this.showElements(['notifyCustomerBooleanWrapper', 'confirmAndNotifyCustomerBooleanWrapper']);
        }
        this.hideElements(['userBelongsToWrapper', 'categorySelectWrapper']);
        this.showElements([
          'customerBelongsToWrapper',
          'selectedRepairSetBelongsToWrapper'
        ]);
        break;
      case 'regular':
        if (this.viewValue == 'new') {
          this.showElements(['notifyCustomerBooleanWrapper', 'confirmAndNotifyCustomerBooleanWrapper']);
        }
        this.hideElements(['userBelongsToWrapper', 'categorySelectWrapper','selectedRepairSetBelongsToWrapper']);
        this.showElements([
          'customerBelongsToWrapper'
        ]);
        break;
      default:
        this.hideElements(this.allInputs());
    }
  }
  allInputs() {
    return [
      "userBelongsToWrapper",
      "customerBelongsToWrapper",
      "categorySelectWrapper",
      "notifyCustomerBooleanWrapper",
      "confirmAndNotifyCustomerBooleanWrapper",
      "selectedRepairSetBelongsToWrapper"
    ]
  }

  disconnect() {
  }

  // Private


  getCalendarEntryEventDtimeFieldResourceController() {
    return this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller~="dtime-field"]'),
      "dtime-field"
    )
  }

  _hideElements(elements) {
    Array(elements).flat().forEach((el) => {
      el.classList.add("hidden")
    })
  }

  hideElements(targets) {
    targets.forEach(target => {
      // Check if the target is a string (i.e., target name) or an actual DOM element
      if (typeof target === 'string') {
        const targetExists = `has${this.capitalizeFirstLetter(target)}Target`;
        const targetInstance = `${target}Target`;

        // Check if the target exists using Stimulus's hasTarget helper
        if (this[targetExists]) {
          this[targetInstance].classList.add("hidden");
        }
      } else if (target instanceof HTMLElement) {
        // Directly hide the element if it's an HTMLElement
        target.classList.add("hidden")
      }
    });
  }

  // Helper to capitalize the first letter of the string to match Stimulus's hasTarget format
  capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }

  _showElements(elements) {
    Array(elements).flat().forEach((el) => {
      el.classList.remove("hidden")
    })
  }

  showElements(targets) {
    targets.forEach(target => {
      // Check if the target is a string (i.e., target name) or an actual DOM element
      if (typeof target === 'string') {
        const targetExists = `has${this.capitalizeFirstLetter(target)}Target`;
        const targetInstance = `${target}Target`;

        // Check if the target exists using Stimulus's hasTarget helper
        if (this[targetExists]) {
          this[targetInstance].classList.remove("hidden");
        }
      } else if (target instanceof HTMLElement) {
        // Directly hide the element if it's an HTMLElement
        target.classList.remove("hidden")
      }
    });
  }


}
