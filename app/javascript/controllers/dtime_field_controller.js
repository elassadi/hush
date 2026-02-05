import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {

  static targets = ['startDateInput', 'endDateInput', 'startTimeInput', 'endTimeInput',
    "startDateFakeInput", "endDateFakeInput"
  ]
  static values = {
    view: String
  }


  connect() {
    document.dispatchEvent(new CustomEvent('dtime-controller:connected', { bubbles: true }));
  }

  disconnect() {}


  onDateChanged(event) {
    window.temp = event;

    // Validate and possibly update the end date
    this.validateEndDate();

    // Validate and possibly update the end time
    this.validateEndTime();

     // Dispatch the custom event

     let {startDate, endDate} = this.getDtimeValue();

    let dateChangedEvent = new CustomEvent('dtimeFieldDateChanged', {
      detail: {
        id: this.element.id,
        startDate: startDate,
        endDate: endDate
      }
    });

    document.dispatchEvent(dateChangedEvent);
  }

  getDtimeValue() {

    const startTime = this.startTimeInputTarget.value;
    const endTime = this.endTimeInputTarget.value;


    const startDate = new Date(this.startDateFakeInputTarget.value);
    const endDate = new Date(this.endDateFakeInputTarget.value);

    // Split the time strings into hours and minutes
    const [startHours, startMinutes] = startTime.split(':').map(Number);


    const [endHours, endMinutes] = endTime.split(':').map(Number);

    // Set the hours and minutes on the Date objects
    startDate.setHours(startHours, startMinutes, 0, 0); // 0 seconds, 0 milliseconds
    endDate.setHours(endHours, endMinutes, 0, 0); // 0 seconds, 0 milliseconds

    return {
      startDate: startDate,
      endDate: endDate,
    }
  }





  setStartAndEndDate(startDate, endDate) {
    const endDateInstance = this.endDateFakeInputTarget._flatpickr;
    const startDateInstance = this.startDateFakeInputTarget._flatpickr;


    startDateInstance.setDate(startDate);
    endDateInstance.setDate(endDate);


    const hours = startDate.getHours().toString().padStart(2, '0');
    const minutes = startDate.getMinutes().toString().padStart(2, '0');
    let start_time = `${hours}:${minutes}`;

    const end_hours = endDate.getHours().toString().padStart(2, '0');
    const end_minutes = endDate.getMinutes().toString().padStart(2, '0');
    let end_time = `${end_hours}:${end_minutes}`;

    this.startTimeInputTarget.value = start_time;
    this.validateEndTime();
    this.endTimeInputTarget.value = end_time;

  }


  setStartTime(timeString) {
    this.startTimeInputTarget.value = timeString;
  }


  validateEndDate() {
    const startDate = this.startDateInputTarget.value;
    const endDateInstance = this.endDateFakeInputTarget._flatpickr;

    if (!startDate) return;

    // Convert startDate to a Date object
    const startDateObject = new Date(startDate);

    // Check if the end date is empty or in the past
    if (!endDateInstance.selectedDates.length || endDateInstance.selectedDates[0] < startDateObject) {

        endDateInstance.setDate(startDateObject);
    }
  }




    // Method to validate and update the end time if needed
  validateEndTime() {
    const startTime = this.startTimeInputTarget.value;
    const previousSelectedValue = this.endTimeInputTarget.value;

    const startDate = new Date(this.startDateInputTarget.value);
    const endDate = new Date(this.endDateInputTarget.value);


    if (!startTime) return;

    // Function to remove the colon and convert time string to integer
    function timeStringToInt(time) {
        return parseInt(time.replace(":", ""), 10);
    }

    // Convert startTime to an integer
    const startTimeInt = timeStringToInt(startTime);

    // Clear the current options in the endTimeInput
    this.endTimeInputTarget.innerHTML = '';

    // Generate time options dynamically in 15-minute intervals
    let optionFound = false;
    for (let hour = 0; hour < 24; hour++) {
        for (let minute = 0; minute < 60; minute += 15) {
            const hourStr = hour.toString().padStart(2, '0');
            const minuteStr = minute.toString().padStart(2, '0');
            const time = `${hourStr}:${minuteStr}`;
            const timeInt = timeStringToInt(time);

            if (timeInt > startTimeInt || startDate < endDate) {
                const optionElement = document.createElement('option');
                optionElement.value = time;
                optionElement.text = time;
                this.endTimeInputTarget.appendChild(optionElement);

                // Restore the previously selected value if it exists in the new options
                if (time === previousSelectedValue) {
                    optionElement.selected = true;
                    optionFound = true;
                }
            }
        }
    }

    // If the previous selected value was not found in the new options, clear the selection
    if (!optionFound) {
        this.endTimeInputTarget.value = '';
    }

    // If no option is selected, select the first option
    if (!this.endTimeInputTarget.value) {
        this.endTimeInputTarget.selectedIndex = 0;
    }


  }


  allDay(value) {
    if (value) {
      this.hideElements([this.startTimeInputTarget, this.endTimeInputTarget])
    }else {
      this.showElements([this.startTimeInputTarget, this.endTimeInputTarget])
    }
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


}
