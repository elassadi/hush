import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static targets = ["calendarEntryId", "calendarEntryStart"] // use the target Avo prepared for you
  static values = { view: String }

  // Public methods
  refreshCalendar() {
    // Check if the calendar is initialized
    if (this.calendar) {
      // Fetch the latest events and update the calendar
      this.showLoader(); // Show loader when refreshing
      this.calendar.refetchEvents()
    }
  }

  // Private methods
  async connect() {
    var that = this
    var calendarEl = document.getElementById("calendar")
    var calendar = new FullCalendar.Calendar(calendarEl, {
      eventContent: function (arg) {
        try {
          return { html: that.renderEventContent(arg) }
        } catch (error) {
          console.error("Error in eventContent:", error)
          throw error // Re-throw the error to ensure it is not swallowed
        }
      },
      eventDragStart: function (info) {
        window.recloudCalendarGlobalisDragging = true;
      },
      eventDragStop: function (info) {
        window.recloudCalendarGlobalisDragging = false;
      },
      loading: function(isLoading) {
        if (isLoading) {
          that.showLoader();  // Show loader when loading starts
        } else {
          that.hideLoader();  // Hide loader when loading is done
        }
      },
      slotLabelFormat: {
        hour: "2-digit",
        minute: "2-digit",
        omitZeroMinute: false,
        hour12: false,
      },
      selectable: true,
      select: function (info) {
        let selectedElement = document.querySelector(".fc-highlight")
        if (selectedElement) {
          selectedElement.classList.add("pre-selected-range")
        }
        that.openNewModal(info.startStr, info.endStr, info.allDay)
      },
      customButtons: {
        selectDate: {
          text: "Datum",
          click: function (event) {
            that.showDatePicker(event.target)
          },
        },
        addCalendarEntry: {
          text: "Termin hinzufügen",
          click: function (event) {
            that.addCalendarEntry(event.target)
          },
        },
      },
      dayMaxEventRows: true,
      dayMaxEvents: true,
      views: {
        timeGrid: {
          dayMaxEventRows: 3,
        },
      },
      navLinks: true,
      allDayMaintainDuration: true,
      editable: true,
      nowIndicator: true,
      businessHours: [
        {
          daysOfWeek: [1, 2, 3, 4, 5],
          startTime: "09:00",
          endTime: "18:00",
        },
        {
          daysOfWeek: [6],
          startTime: "09:00",
          endTime: "12:00",
        },
      ],
      views: {
        dayGridThreeDays: {
          type: "timeGrid",
          duration: { days: 3 },
        },
      },
      buttonIcons: {
        selectDate: "date-icon",
        addCalendarEntry: "add-icon",
      },
      buttonText: {
        today: "Heute",
        month: "Monat",
        week: "Woche",
        day: "Tag",
        list: "Liste",
        dayGridThreeDays: "3 Tage",
      },
      headerToolbar: {
        left: "prev,next today",
        center: "title",
        right:
          "selectDate,timeGridDay,dayGridThreeDays,timeGridWeek listWeek",
      },
      snapDuration: "00:15:00",
      initialView: "timeGridWeek",
      allDayText: "GT",
      locale: "de",
      firstDay: 1,
      eventDidMount: that.renderEvent.bind(this),
      events: that.fetchEvents.bind(this),
      eventDrop: that.handleEventDrop.bind(this),
      eventResize: that.handleEventResize.bind(this),
      eventClick: that.handleEventClick.bind(this),
      dateClick: function (info) {},
      eventMouseEnter: function (info) {
        const startTime = info.event.start.toLocaleTimeString([], {
          hour: "2-digit",
          minute: "2-digit",
        })
        const endTime = info.event.end
          ? info.event.end.toLocaleTimeString([], {
              hour: "2-digit",
              minute: "2-digit",
            })
          : ""

        const startLabel = document.createElement("div")
        startLabel.classList.add("event-label", "event-start-label")
        startLabel.textContent = startTime

        const endLabel = document.createElement("div")
        endLabel.classList.add("event-label", "event-end-label")
        endLabel.textContent = endTime

        info.el.appendChild(startLabel)
        info.el.appendChild(endLabel)
      },
      eventMouseLeave: function (info) {
        let startLabels = document.querySelectorAll(".event-start-label")
        let endLabels = document.querySelectorAll(".event-end-label")

        if (startLabels) {
          startLabels.forEach((label) => {
            label.parentNode.removeChild(label)
          })
        }

        if (endLabels) {
          endLabels.forEach((label) => {
            label.parentNode.removeChild(label)
          })
        }
      },
      slotLabelDidMount: function (slotInfo) {
        slotInfo.el.addEventListener("mousemove", function (e) {
          let events = slotInfo.view.calendar.getEvents()
          let isOverEvent = events.some((event) => {
            return event.start < slotInfo.date && event.end > slotInfo.date
          })

          if (!isOverEvent) {
            slotInfo.el.style.backgroundColor = "#e3f2fd"
            slotInfo.el.style.border = "1px dotted #0d47a1"
          }
        })

        slotInfo.el.addEventListener("mouseleave", function (e) {
          slotInfo.el.style.backgroundColor = ""
          slotInfo.el.style.border = ""
        })
      },
      eventsSet: function(events) {
        window.initTippy()
      }
    })
    calendar.render()
    this.calendar = calendar
    window.mainCalendar = calendar
    window.mainCalendarController = this

    document.addEventListener(
      "resourceCreated",
      this.handleResourceChanged.bind(this)
    )
    document.addEventListener(
      "resourceUpdated",
      this.handleResourceChanged.bind(this)
    )
    document.addEventListener(
      "resourceDestroyed",
      this.handleResourceChanged.bind(this)
    )


    const calendarEntryId = this.calendarEntryIdTarget.value
    const calendarEntryStart = this.calendarEntryStartTarget.value
    if (calendarEntryId) {
      this.calendar.gotoDate(calendarEntryStart)
      this.shouldHighlightEvent = true;
      this.selectedEventId = calendarEntryId
    }

    // Set interval to make the request every 30 minutes (1800000 milliseconds)
    //const keepAliveInterval = 30 * 60 * 1000; // 30 minutes
    const keepAliveInterval = 10 * 60 * 1000; // 30 minutes

    // Start the keep-alive mechanism
    setInterval(this.refreshCalendar.bind(this), keepAliveInterval);
  }


   // Show loader by displaying the overlay
   showLoader() {
    const loader = document.getElementById("calendar-loader");
    if (loader) {
      loader.style.display = "flex"; // Show loader
    }
  }

  // Hide loader by hiding the overlay
  hideLoader() {
    const loader = document.getElementById("calendar-loader");
    if (loader) {
      loader.style.display = "none"; // Hide loader
    }
  }


  highlightEvent(eventEl) {
    if (!eventEl) return;

    // Add a highlight class to the event element
    eventEl.classList.add('highlighted-event');
    this.shouldHighlightEvent = false;

    // Remove the highlight after 3 seconds
    setTimeout(() => {
      eventEl.classList.remove('highlighted-event');
    }, 2000);
  }



  toggleSelectEvent(info) {
    if (info.el.classList.contains('selected-event')) {
      return this.unselectAllEvents(info);
    }

    this.selectEvent(info);
  }

  unselectAllEvents(info) {
    const previouslySelectedEvents = document.querySelectorAll('.selected-event');
    previouslySelectedEvents.forEach((el) => {
      el.classList.remove('selected-event');
      this.resetEventToOne(el);
    });
  }

  selectEvent(info) {
    if (!info.el) return;

    this.unselectAllEvents(info);
    info.el.classList.add('selected-event');
    this.bringEventToTop(info.el);
    this.selectedEventId = info.event.id
  }


  bringEventToTop(element) {
    if (element) {
      const eventHarness = element.closest('.fc-timegrid-event-harness');

      if (eventHarness) {
        eventHarness.style.zIndex = '1000';
      }
    }
  }

  resetEventToOne(element) {
    if (element) {
      const eventHarness = element.closest('.fc-timegrid-event-harness');
      if (eventHarness) {
        eventHarness.style.zIndex = '1';
      }
    }
  }




  fetchEvents(fetchInfo, successCallback, failureCallback) {
    let start = encodeURIComponent(fetchInfo.startStr)
    let end = encodeURIComponent(fetchInfo.endStr)

    fetch(`/resources/calendar_entries?start=${start}&end=${end}`)
      .then((response) => response.json())
      .then((events) => {
        events = events.map(event => {
          if (event.extendedProps.status === "canceld") {
            event.editable = false; // Disable moving
            event.durationEditable = false; // Disable resizing
          }
          return event;
        });
        successCallback(events)
      })
      .catch((error) => {
        //failureCallback(error)
        this.redirect_to_login(error)
      })
  }

  handleEventDrop(info) {
    this.handleEventResizeOrDrop(info)
  }

  handleEventResize(info) {
    this.handleEventResizeOrDrop(info)
  }

  handleEventClick(info) {
    this.toggleSelectEvent(info);
  }

  addDoubleClickListener(info) {
    info.el.addEventListener("dblclick", () => {
      this.openEditModal(info.event);
    });
  }



  handleEventResizeOrDrop(info) {
    if (info.event.extendedProps.calendarable_type == "User") {
      return this.updateCalendarEntry(info, false)
    }

    if (info.event.extendedProps.confirmed) {
      this.showConfirmationModal(
        info,
        () => {
          this.calendar.resumeRendering()
        },
        () => {
          info.revert()
          this.calendar.resumeRendering()
        }
      )
    }else {
      return this.updateCalendarEntry(info, false)
    }
  }

  showConfirmationModal(info, onConfirm, onCancel) {
    const confirmModal = document.getElementById("confirmModal")
    const notifyCustomer = confirmModal.querySelector("#notify_customer")
    notifyCustomer.checked = false

    confirmModal.classList.remove("hidden")


    this.calendar.pauseRendering()

    const handleKeydown = (event) => {
      if (event.key === "Enter") {
        handleYes()
      } else if (event.key === "Escape") {
        handleNo()
      }
    }

    const handleYes = () => {
      const notifyCustomer = confirmModal.querySelector("#notify_customer").checked;
      confirmModal.classList.add("hidden");
      this.updateCalendarEntry(info, notifyCustomer); // Adjusted to pass checkbox value
      onConfirm(notifyCustomer); // Pass the checkbox value to onConfirm if needed
      document.removeEventListener("keydown", handleKeydown);
    }

    const handleNo = () => {
      confirmModal.classList.add("hidden")
      onCancel()
      document.removeEventListener("keydown", handleKeydown)
    }

    document.getElementById("confirmModalYesButton").onclick = handleYes
    document.getElementById("confirmModalNoButton").onclick = handleNo
    document.addEventListener("keydown", handleKeydown)
  }

  async updateCalendarEntry(info, notifyCustomer) {
    const entryData = this.prepareCalendarEntryData(info.event) // Pass the event data

    if (notifyCustomer) {
      entryData.notify_customer = notifyCustomer; // Add the notify_customer value to the entryData
    }
    try {
      const response = await fetch(`/resources/calendar_entries/${entryData.id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        },
        body: JSON.stringify(entryData),
      })

      const responseData = await response.json()

      if (response.ok) {
        if (responseData.errors) {
          this.showErrors(responseData.errors)
        }
      } else {
        this.showErrors(responseData.errors)
      }
      this.calendar.refetchEvents()
    } catch (error) {
      this.redirect_to_login(error)
    }
  }

  redirect_to_login(error) {
    console.error("Error while updating calendar entry:", error)
    alert("Ein Fehler ist beim Aktualisieren des Kalendereintrags aufgetreten. Sie müssen sich erneut anmelden.")
    window.location.href = "/resources/users/sign_in"
  }
  showErrors(errors) {
    let errorMessages = Object.keys(errors)
      .map((field) => `${field}: ${errors[field].join(", ")}`)
      .join("\n")

    this.showAlertModal("Error(s)", errorMessages, "error")
  }
  showAlertModal(title, message, type = "info") {
    const modal = document.getElementById("alertModal")
    const modalTitle = document.getElementById("alertModalTitle")
    const modalMessage = document.getElementById("alertModalMessage")
    const successIcon = document.getElementById("alertSuccessIcon")
    const errorIcon = document.getElementById("alertErrorIcon")
    const closeButton = document.getElementById("alertModalCloseButton")

    // Set the title and message
    modalTitle.textContent = title
    modalMessage.textContent = message

    // Reset icons visibility
    successIcon.classList.add("hidden")
    errorIcon.classList.add("hidden")

    // Show appropriate icon based on type
    if (type === "success") {
      successIcon.classList.remove("hidden")
    } else if (type === "error") {
      errorIcon.classList.remove("hidden")
    }

    // Show the modal
    modal.classList.remove("hidden")

    // Handle modal close
    closeButton.onclick = () => {
      modal.classList.add("hidden")
    }
  }

  prepareCalendarEntryData(event) {
    return {
      id: event.extendedProps.id,
      start: event.startStr,
      end: event.endStr,
      all_day: event.allDay
    }
  }



  showDatePicker(buttonElement) {
    let containerDiv = document.createElement("div")
    containerDiv.style.position = "absolute"
    containerDiv.style.left = `${buttonElement.getBoundingClientRect().left}px`
    containerDiv.style.top = `${buttonElement.getBoundingClientRect().bottom}px`
    containerDiv.style.zIndex = "9999"

    let tempInput = document.createElement("input")
    tempInput.style.opacity = "0"
    tempInput.style.height = "0"
    tempInput.style.border = "none"
    tempInput.style.padding = "0"

    containerDiv.appendChild(tempInput)
    document.body.appendChild(containerDiv)

    const removeInput = () => {
      if (containerDiv && document.body.contains(containerDiv)) {
        document.body.removeChild(containerDiv)
      }
    }

    flatpickr(tempInput, {
      onChange: (selectedDates, dateStr) => {
        this.calendar.gotoDate(dateStr)
        removeInput()
      },
      onClose: removeInput,
      defaultDate: this.calendar.getDate(),
    })

    tempInput.click()
  }

  handleScroll(event) {
    if (event.deltaX > 0) {
      this.calendar.next()
    } else if (event.deltaX < 0) {
      this.calendar.prev()
    }
  }

  throttle(func, delay) {
    let lastCall = 0
    return function (...args) {
      const now = new Date().getTime()
      if (now - lastCall < delay) {
        return
      }
      lastCall = now
      return func(...args)
    }
  }



  openEditModal(event) {
    let resourceId = event.extendedProps.id
    let href = `/resources/calendar_entries/${resourceId}/edit?modal_resource=modal_resource&via_child_resource=CalendarEntryResource&via_resource_class=CalendarEntry&via_resource_id=${resourceId}`

    let tempLink = document.createElement("a")
    tempLink.href = href
    tempLink.setAttribute("data-turbo-frame", "modal_resource")
    tempLink.setAttribute("data-target", "control:edit")
    tempLink.setAttribute("data-control", "edit")
    tempLink.setAttribute("data-resource-id", resourceId)

    document.body.appendChild(tempLink)
    tempLink.click()
    document.body.removeChild(tempLink)
  }

  openNewModal(start, end, allDay = false) {
    let encodedStart = encodeURIComponent(start)
    let encodedEnd = encodeURIComponent(end)
    let href = `/resources/calendar_entries/new?modal_resource=modal_resource&start_time=${encodedStart}&end_time=${encodedEnd}&all_day=${allDay}`

    let tempLink = document.createElement("a")
    tempLink.href = href
    tempLink.setAttribute("data-turbo-frame", "modal_resource")
    tempLink.setAttribute("data-target", "control:new")
    tempLink.setAttribute("data-control", "new")
    tempLink.setAttribute("data-start", start)
    tempLink.setAttribute("data-end", end)

    document.body.appendChild(tempLink)
    tempLink.click()
    document.body.removeChild(tempLink)
  }

  handleResourceChanged(event) {
    const { resourceModelName } = event.detail

    if (resourceModelName === "calendar_entry") {
      setTimeout(() => {
        this.calendar.refetchEvents()
      }, 200)
    }
  }

  shortenNotes(notes, maxLength) {
    if (!notes) return ""
    return notes.length > maxLength
      ? notes.substring(0, maxLength) + "..."
      : notes
  }


  renderEvent(info) {
    try {
      if (info.event.id === this.selectedEventId) {
        this.selectEvent(info);
        if (this.shouldHighlightEvent)
          this.highlightEvent(info.el);
      }

      this.addDoubleClickListener(info);
      if (this.isCanceld(info.event)) {
        info.el.classList.add("canceld-event");
        info.el.classList.remove("unconfirmed-event");
        //info.event.setProp('editable', false);
        //info.event.setProp('durationEditable', false);
        return;
      }

      this.renderConfirmationStatus(info);

      // Add Tippy tooltip with notes on hover
      if (info.event.extendedProps.notes) {

        if (!window.recloudCalendarGlobalisDragging) {
          tippy(info.el, {
            content: info.event.extendedProps.notes,
            placement: 'right',
            theme: 'calendar-note',
            maxWidth: '350px',
          });
        }
      }

    } catch (error) {
      console.error("Error in renderEvent:", error);
      throw error;
    }
  }


  isCanceld(event) {
    return event.extendedProps.status === "canceld";
  }

  renderConfirmationStatus(info) {
    let confirmed = info.event.extendedProps.confirmed;

    if (confirmed) {
      info.el.classList.add("confirmed-event");
      info.el.classList.remove("unconfirmed-event");
    } else {
      info.el.classList.remove("confirmed-event");
      info.el.classList.add("unconfirmed-event");
    }
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

  _renderOtherEventContent(arg) {
    //let notes = this.shortenNotes(data.notes, 60); // We may use it for a tip popup
    let data = arg.event.extendedProps
    let eventLink = this.composeEventLink(data);

    return `
      <b>
        <a href="${eventLink}" class="underline-on-hover" style="color: ${arg.event.textColor}" target="_blank"
           onclick="event.preventDefault(); event.stopPropagation(); window.open('${eventLink}', '_blank');">
          ${data.name}
        </a>
      </b><br/>
      ${data.default_notes}<br/>
      ${arg.timeText}
    `;
  }

  composeEventLink(data) {
    const baseUrl = "/resources"
    const linkMap = {
      Issue: `${baseUrl}/issues/`,
      Customer: `${baseUrl}/customers/`,
      User: `${baseUrl}/users/`,
    }

    return linkMap[data.calendarable_type]
      ? linkMap[data.calendarable_type] + data.calendarable_id
      : ""
  }


  keepSessionAlive() {
    // Send a simple GET request to an endpoint that keeps the session alive
    fetch('/resources/users/keep_alive', {
      method: 'GET',
      headers: {
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content // Ensure CSRF token is sent
      }
    })
    .then(response => {
      if (!response.ok) {
        console.warn('Failed to keep session alive:', response.statusText);
      }
    })
    .catch(error => {
      console.error('Error during session keep-alive request:', error);
    });
  }
}