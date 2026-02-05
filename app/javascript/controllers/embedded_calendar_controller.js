import { Controller } from "@hotwired/stimulus"
//import "calendar"
import flatpickr from "flatpickr"



export default class extends Controller {

  static targets = [] // use the target Avo prepared for you
  static values = { view: String }



  async connect() {
    var that = this;



    if (that.viewValue == 'index') {
      return
    }

    if (that.viewValue == 'new' || that.viewValue == 'edit') {
      this.createDraftEventEnabled = true;
    }


    var calendarEl = document.getElementById('embedded-calendar');
    if (!calendarEl) {
      return
    }
    var calendar = new FullCalendar.Calendar(calendarEl, {
      scrollTime: '09:00:00',
      slotLabelFormat: {
        hour: '2-digit',
        minute: '2-digit',
        omitZeroMinute: false,
        hour12: false
      },
      selectable: true,
      select: function(info) {
          let selectedElement = document.querySelector(".fc-highlight")
          if (selectedElement) {
            selectedElement.classList.add("pre-selected-range")
          }
          that.createDraftEvent(info);
      },

      customButtons: {
        selectDate: {
          text: 'Datum',
          click: function(event) {
            that.showDatePicker(event.target);
          }
        }
      },
      dayMaxEventRows: true,
      dayMaxEvents: true,
      views: {
        timeGrid: {
          dayMaxEventRows: 3
        }
      },
      navLinks: true,
      editable: true,
      nowIndicator: true,
      businessHours: [
        {
          daysOfWeek: [1, 2, 3, 4, 5],
          startTime: '09:00',
          endTime: '17:00'
        },
        {
          daysOfWeek: [6],
          startTime: '09:00',
          endTime: '12:00'
        }
      ],
      views: {
        dayGridThreeDays: {
          type: 'timeGrid',
          duration: { days: 3 }
        }
      },
      buttonIcons: {
        selectDate: 'date-icon',
        addCalendarEntry: 'add-icon',
      },
      buttonText: {
        today: 'Heute',
        month: 'Monat',
        week: 'Woche',
        day: 'Tag',
        list: 'Liste',
        dayGridThreeDays: '3 Tage'
      },
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'timeGridDay,dayGridThreeDays'
      },
      snapDuration: '00:15:00',
      initialView: 'timeGridDay',
      allDayText: 'GT',
      locale: 'de',
      firstDay: 1,

      eventContent: function(arg) {

        try {
          let html = '';
          if (that.draftEvent && /^draft-\d+$/.test(arg.event.id)) {
            html = that.renderDraftEvent(arg);
          } else {
            html = that.renderEventContent(arg);
          }
          return { html: html };
        } catch (error) {
          console.error("Error in eventContent:", error);
          throw error; // Re-throw the error to ensure it is not swallowed
        }
      },

      eventDidMount: function(info) {

        try {
          return that.renderConfirmedEvent(info)
        } catch (error) {
          console.error("Error in eventContent:", error)
          throw error // Re-throw the error to ensure it is not swallowed
        }

      },
      eventChange: function(info) {
        that.handleEventChange(info);
      },

      eventDrop: function(info) {
        that.handleEventChange(info);
      },

      events: function(fetchInfo, successCallback, failureCallback) {
        let start = fetchInfo.startStr;
        let end = fetchInfo.endStr;
        fetch(`/resources/calendar_entries?start=${start}&end=${end}`)
          .then(response => response.json())
          .then(events => {
            events = events.map(event => {
              return {
                ...event,
                editable: false
              };
            });

            let sEvent = events.find(
              event => event.extendedProps && event.extendedProps.id == that.selectedEventId
            );

            if (sEvent) {
              that.selectedEvent = sEvent;
            }

            successCallback(events);
          })
          .catch(error => {
            failureCallback(error);
          });
      },
      datesSet: function(info) {
        //that.moveDraftEvent(info.startStr, info.endStr);
      },

      dateClick: function(info) {
      },

      eventMouseEnter: function() {},
      eventMouseLeave: function() {},

      // Custom code to highlight 15-minute time slots
      slotLabelDidMount: function(slotInfo) {
        slotInfo.el.addEventListener('mousemove', function(e) {
          let events = slotInfo.view.calendar.getEvents();
          let isOverEvent = events.some(event => {
            return event.start < slotInfo.date && event.end > slotInfo.date;
          });

          if (!isOverEvent) {
            slotInfo.el.style.backgroundColor = '#e3f2fd';
            slotInfo.el.style.border = '1px dotted #0d47a1';
          }
        });

        slotInfo.el.addEventListener('mouseleave', function(e) {
          slotInfo.el.style.backgroundColor = '';
          slotInfo.el.style.border = '';
        });
      },
      eventsSet: function(events) {
        window.initTippy()
      }
    });

    calendar.render();
    this.calendar = calendar;
    window.calendar = calendar;
    window.embedded = this // for debugging

    document.addEventListener("resourceCreated", this.handleResourceChanged.bind(this))
    document.addEventListener("resourceUpdated", this.handleResourceChanged.bind(this))
    document.addEventListener("resourceDestroyed", this.handleResourceChanged.bind(this))
    document.addEventListener("dtimeFieldDateChanged", this.handleDraftEventTimeChanges.bind(this))

  }

  renderConfirmedEvent(info) {




    let confirmed = info.event.extendedProps.confirmed;

    if (this.selectedEventId == info.event.extendedProps.id) {
      if (this.viewValue == 'show') {
        info.el.classList.add('draft-event');
      }else {
        info.el.style.display = 'none';;
      }
      return
    }

    if ((this.draftEvent && info.event.id === this.draftEvent.id) || info.event.extendedProps.isDraft === true) {
      info.el.classList.remove('unconfirmed-event'); // Remove unconfirmed class if it was added
      info.el.classList.add('confirmed-event');

      return
    }

    if (confirmed) {
      info.el.classList.add('confirmed-event'); // Add the class for confirmed events
      info.el.classList.remove('unconfirmed-event'); // Remove unconfirmed class if it was added
    } else {
      info.el.classList.remove('confirmed-event'); // Remove the confirmed class if it's not confirmed
      info.el.classList.add('unconfirmed-event'); // Optionally, add a class for unconfirmed events
    }
  }

  setSelectedEventId(id) {
    this.selectedEventId = id
    //this.calendar.refetchEvents()
  }

  renderDraftEvent(arg) {
    if (this.selectedEvent)
      return this.renderDraftEventContentHtml(this.selectedEvent.extendedProps, 'black', 'Draft Event')
  }

  shortenNotes(notes, maxLength) {
    if (!notes) {
      return '';
    }
    if (notes.length > maxLength) {
      return notes.substring(0, maxLength) + '...';
    }
    return notes;
  }


  renderEventContent(arg) {
    let data = arg.event.extendedProps
    if (data.entry_type == "blocker") {
      return this.renderBlockerEventContent(arg)
    } else {
      return this.renderOtherEventContent(arg)
    }
  }


  renderBlockerEventContent(arg) {
    let data = arg.event.extendedProps
    let eventLink = this.composeEventLink(data);

    return `
      <b>
        Zeitblocker
      </b><br/>
      ${data.default_notes}<br/>
      ${arg.timeText}
    `;
  }


  renderOtherEventContent(arg) {
    let data = arg.event.extendedProps

    let notes = this.shortenNotes(data.notes, 60)
    // we may use it for a tip popup

    let template =
      "<b><a href='{{eventLink}}' class='underline-on-hover' style='color: {{textColor}}' target='_blank' " +
      "onclick='event.preventDefault(); event.stopPropagation(); window.open(\"{{eventLink}}\", \"_blank\");'>" +
      "{{name}}</a></b><br/>" +
      "{{default_notes}}<br/>" +
      "{{timeText}}";

    let eventLink = this.composeEventLink(data)
    let html = template
      .replace("{{name}}", data.name)
      .replace("{{default_notes}}", data.default_notes)
      .replace("{{textColor}}", arg.event.textColor)
      .replace("{{timeText}}", arg.timeText)
      .replace(/{{eventLink}}/g, eventLink); // Use regular expression with 'g' flag to replace all occurrences

    return html
  }

  renderDraftEventContentHtml(data, textColor, timeText) {

    let notes = this.shortenNotes(data.notes, 60);

    if (!notes) {
      notes = data.default_notes
    }

    // Use a template to substitute data
    let template =
      "<b><span style='color: {{textColor}}'  >{{name}}</span></b><br/>"+
      "{{notes}}<br/>" +
      "{{timeText}}";

    let eventLink = this.composeEventLink(data);

    let html = template.replace('{{name}}', data.name)
                   .replace('{{notes}}', notes)
                   .replace('{{textColor}}', textColor)
                   .replace('{{timeText}}', timeText)
                   .replace('{{eventLink}}', eventLink)


    return html;
  }

  composeEventLink(data) {
    const baseUrl = '/resources';
    const linkMap = {
      "Issue": `${baseUrl}/issues/`,
      "Customer": `${baseUrl}/customers/`,
      "User": `${baseUrl}/users/`
    };

    return linkMap[data.calendarable_type] ? linkMap[data.calendarable_type] + data.calendarable_id : '';
  }


  handleEventChange(info) {

    if (info.event.id === this.draftEvent.id) {
      this.draftEvent = info.event;
      this.updateDtimeField();
    }
  }


  createDraftEvent(info) {
    // If a draft event already exists, remove it


    let firstDraftEvent = false
    if (!this.createDraftEventEnabled)
      return

    if (this.draftEvent) {
      this.draftEvent.remove();
    }else {
      firstDraftEvent = true
    }

    // Create a new draft event object
    this.draftEvent = this.calendar.addEvent({
      id: 'draft-' + new Date().getTime(), // Create a unique ID
      title: 'Draft Event',
      start: info.startStr,
      end: info.endStr,
      //backgroundColor: 'rgba(255, 165, 0, 0.5)', // Semi-transparent orange color
      borderColor: 'blue', // Border color for the draft event
      editable: true, // Allow the draft event to be dragged and resized
      classNames: ['draft-event', 'confirmed-event'], // Add a class for custom styling
      extendedProps: {
        isDraft: true // A flag to indicate that this is a draft event
      }
    });
    this.updateDtimeField();

    const startDate = new Date(info.startStr);

    // Extract hours and minutes
    const hours = startDate.getHours();
    const minutes = startDate.getMinutes();

    // Create an object with the time information
    const timeObject = {
      hour: hours,
      minute: minutes
    };

    // Scroll the calendar to the start time of the newly created draft event
    if (firstDraftEvent) {
      setTimeout(() => {
        this.calendar.scrollToTime(timeObject);
      }, 200);
    }
  }




  updateDtimeField(event) {
    if (!this.draftEvent) {
      return
    }

    let start = this.draftEvent.start
    let end = this.draftEvent.end






    let controller = this.getCalendarEntryEventDtimeFieldResourceController();

    controller.setStartAndEndDate(start, end)


  }

  getCalendarEntryEventDtimeFieldResourceController() {
      return this.application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="dtime-field"]'),
        "dtime-field"
    )
  }

  ____moveDraftEvent(newStartDate) {
    if (this.draftEvent) {
      // Extract the time part from the existing start and end times
      const startTime = this.draftEvent.start.toISOString().substr(11, 8); // HH:MM:SS
      const endTime = this.draftEvent.end.toISOString().substr(11, 8);     // HH:MM:SS




      // Create new start and end datetimes using the new date and the existing times
      const newStart = new Date(`${newStartDate}T${startTime}`);
      const newEnd = new Date(`${newStartDate}T${endTime}`);

      // Set the new start and end times for the draft event
      this.draftEvent.setStart(newStart);
      this.draftEvent.setEnd(newEnd);




    }
  }
  showDatePicker(buttonElement) {
    // Create a div container with absolute positioning
    let containerDiv = document.createElement('div');
    containerDiv.style.position = 'absolute';
    containerDiv.style.left = `${buttonElement.getBoundingClientRect().left}px`;
    containerDiv.style.top = `${buttonElement.getBoundingClientRect().bottom}px`;
    containerDiv.style.zIndex = '9999'; // Ensure it appears above other elements

    // Create an input field inside the div
    let tempInput = document.createElement('input');
    tempInput.style.opacity = '0'; // Make the input invisible
    tempInput.style.height = '0'; // Ensure the input doesn't take up space
    tempInput.style.border = 'none'; // Remove any borders
    tempInput.style.padding = '0'; // Remove any padding

    // Append the input to the div and the div to the body
    containerDiv.appendChild(tempInput);
    document.body.appendChild(containerDiv);

    const removeInput = () => {
      if (containerDiv && document.body.contains(containerDiv)) {
        document.body.removeChild(containerDiv);
      }
    };

    flatpickr(tempInput, {
      onChange: (selectedDates, dateStr, instance) => {
        this.calendar.gotoDate(dateStr);
        removeInput(); // Safely remove the input after selecting a date
      },
      onClose: () => {
        removeInput(); // Safely remove the input when the picker closes
      },
      defaultDate: this.calendar.getDate(), // Set the default date to the currently viewed date on the calendar
    });

    // Programmatically open the date picker
    tempInput.click();
}


  handleResourceChanged(event) {

    const { resourceModelName, resourceModelId } = event.detail

    if (resourceModelName === "calendar_entry") {
        setTimeout(() => {
          calendar.refetchEvents();
        }, 200)
    }
  }


  handleDraftEventTimeChanges(event) {



    const { id, startDate, endDate } = event.detail;

    this.draftEvent.setStart(startDate);
    this.draftEvent.setEnd(endDate);

    const dateStr = startDate.toISOString().substr(0, 10);
    this.calendar.gotoDate(dateStr);

  }




}
