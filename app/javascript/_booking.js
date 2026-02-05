
const MIN_DAYS_FROM_TODAY=1;
const BONUS_ON=true
const MIN_PREIS=115;
const MAX_BONUS_VALUE=200;


function getSelectOptions(model, min_input){

  var url = window.location.origin + "/api/partner/"+model;
  var token = bookingData.token;  // Your authorization token
  var selectOptions = {
    language: {
      inputTooShort: function () {
        return "Bitte mindestens 2 Zeichen eingeben!";
      }
    },
    theme: 'bootstrap4',
    //width: 380,
    minimumInputLength: min_input,
    allowClear: true,
    ajax: {
      url: url,
      dataType: "json",
      delay: 250,
      cache: true,
      data: function(params) {

        var query = {
          search_term: params.term,
          device_manufacturer_id: $("#device-manufacturer-select").val(),
          device_model_id: $("#device-model-select").val(),
          device_failure_category_id: $("#device-failure-category-select").val(),
          device_failure_specification_id: $("#device-failure-specification-select").val(),
        };
        return query;
      },
      beforeSend: function(xhr) {
        xhr.setRequestHeader('Authorization', 'Token token=' + token);
      },
      processResults: function(data) {
        var processed = {
          results: jQuery.map(data, function(resource) {
            return {
              id: resource.id,
              text: resource["name"].toString(),
              image_path: resource["image_path"] ? resource["image_path"].toString() : null,
              price: resource["retail_price"] ? (resource["retail_price"] * 1.19).toFixed(2).toString() : null,
            };
          })
        };

        return processed;
      }
    }
  };
  //$(el).on("select2:select", onItemSelected);
  //$(el).on("select2:close", onSelectClosed);
  return selectOptions;
}


var repair_sets=[];
var current_model=null;
var flatpickr_instance = null;
var selectedDateTime = null;

function getRepairSetItems() {

  var url = window.location.origin + "/api/repair_set";
  var fields =["name"];
  var predicate="contains"
  var selectOptions = {
    language: {
        inputTooShort: function () {
          return "Bitte mindestens 2 Zeichen eingeben!";
        }
      },
    theme: 'bootstrap4',
    //width: 380,
    minimumInputLength: 0,
    allowClear: true,
    ajax: {
      url: url,
      dataType: "json",
      delay: 250,
      cache: true,
      data: function(params) {
        return  {
          order: "name_desc",
          search_term: params.term,
          device_manufacturer_id: $("#device-manufacturer-select").val(),
          device_model_id: $("#device-model-select").val(),
          device_color_id: $("#device-color-select").val(),
          device_failure_category_id: $("#device-failure-category-select").val(),
          device_failure_specification_id: $("#device-failure-specification-select").val(),
        };
      },
      processResults: function(data) {
        repair_sets = {
          results: jQuery.map(data, function(resource) {
            return {
              id: resource.id,
              text: resource["name"].toString(),
              price: resource["beautified_brutto_b2c"].toString()
            };
          })
        };

        return repair_sets;
      }
    }
  };
  return selectOptions;
}



function init_components() {

  $("#device-manufacturer-select").select2(getSelectOptions("device_manufacturers", 0));
  $("#device-model-select").select2(getSelectOptions("device_models", 0 ));


  $("#device-model-select").prop('disabled', true);


  $("#device-failure-category-select").select2(getSelectOptions("device_failure_categories", 0));
  $("#device-failure-specification-select").select2(getSelectOptions("device_failure_specifications", 0));
  $("#device-failure-detail-select").select2(getSelectOptions("device_failure_detail", 0));


  $("#repair-set-select").select2(getSelectOptions("repair_sets", 0));
  $("#repair-set-select").prop('disabled', true);

}



function setup_manufacturer() {

  $('#device-manufacturer-select').on('select2:select', function (e) {
    if (e.params) {
      $("#device-model-select").prop('disabled', false);
      $("#device-model-select").val(null).trigger('change.select2');
      $("#repair-set-select").prop('disabled', true);
      $("#repair-set-select").val(null).trigger('change.select2');

      update_model_card();

      window.setTimeout(function () {
        $("#device-model-select").select2("open");
      }, 50);
    }
    }
  );


  $('#device-manufacturer-select').on('select2:unselecting', function (e) {
    $("#device-model-select").val(null).trigger('change.select2');
    $("#device-model-select").prop('disabled', true);
    $("#repair-set-select").val(null).trigger('change.select2');
    $("#repair-set-select").prop('disabled', true);
    update_model_card();
  });
}

function update_model_card()  {


  var manufacturer = $('#device-manufacturer-select').select2('data');
  var data = $('#device-model-select').select2('data');
  var repair_set_data = $('#repair-set-select').select2('data');

  if (repair_set_data.length > 0) {

    //let image_path = `/images/device_pictures/${data[0].id}.jpg`;
    let image_path = data[0].image_path;
    $("#device-model-image-preview").attr("src", image_path);

    var title = `${manufacturer[0].text} ${data[0].text}`;

    title = `${repair_set_data[0].text}`;
    $("#device-model-image-label").text(title);
  }else {
    $("#device-model-image-label").text( "");
    $("#device-model-image-preview").attr("src", "/images/device_pictures/no-device.png");
  }
  update_repair_set_price();

}

function update_repair_set_price()  {
    var data = $('#repair-set-select').select2('data');
    if (data.length > 0) {
      hide_all();
      $("#schedule-button").show();
      $("#label-button").show();
      var price = parseFloat(data[0].price.replace(",", "."));
        $("#repair-price").text(`${data[0].price.replace(".", ",")} €`);
        $("#repair-price-with-bonus").text(`${data[0].price.replace(".", ",")} €`);
      if (price > 400 && BONUS_ON) {
        $("#repairbonus-container").show();
        $(".repairbonus-disclaimer").each(function() {
          $(this).show();
        });
        $("#repairbonus").text(" - "+ MAX_BONUS_VALUE +" €");
        $("#repair-price-with-bonus").text(`${(price - MAX_BONUS_VALUE).toFixed(2).replace(".", ",")} €`);
      }else if ( price > MIN_PREIS  && BONUS_ON){
        $("#repairbonus-container").show();
        $(".repairbonus-disclaimer").each(function() {
          $(this).show();
        });
        //let discountedPrice = (Math.round(price * 100) / 2) / 100;
        let discountedPrice = Math.floor((price / 2) * 100) / 100;
        $("#repairbonus").text(" - 50 %")
        $("#repair-price-with-bonus").text(`${discountedPrice.toFixed(2).replace(".", ",")} €`);
      }
    }else {
      hide_all();
    }
  }

function hide_all() {
  $("#schedule-button").hide();
  $("#label-button").hide();
  $("#repair-price").text("");
  $("#repairbonus-container").hide();
  $(".repairbonus-disclaimer").each(function() {
      $(this).hide();
    });
}



function setup_model() {

  $('#device-model-select').on('select2:select', function (e) {
    if (e.params) {
      $("#repair-set-select").prop('disabled', false);
      $("#repair-set-select").val(null).trigger('change.select2');
      window.setTimeout(function () {
        $("#repair-set-select").select2("open");
        update_model_card();
      }, 50);
    }
    }
  );

  $('#device-model-select').on('select2:unselecting', function (e) {
    $("#repair-set-select").val(null).trigger('change.select2');
    $("#repair-set-select").prop('disabled', true);
    update_model_card();
  });

}

function setup_repair_set (){

  $('#repair-set-select').on('select2:select', function (e) {
    if (e.params) {
      window.setTimeout(function () {
        update_model_card();
        update_repair_set_price();
      }, 50);
    }
    }
  );

  $('#repair-set-select').on('select2:unselecting', function (e) {
    if (e.params) {
      window.setTimeout(function () {
        update_model_card();
        update_repair_set_price();
      }, 50);
    }
    }
  );

}


// Function to return the modal content HTML
function getRepairBonusModalContent() {
return `
  <p><b>Bitte beachten:</b> <br><br>Der angezeigte Preis gilt unter der Voraussetzung, dass Sie für den Reparaturbonus Sachsen berechtigt sind. Dieser Bonus bietet Ihnen bis zu "+ MAX_BONUS_VALUE +"€ Rabatt (50% der Reparaturkosten).
  Gültig nur in Sachsen.</p>
  <p>Der Hauptwohnsitz muss in Sachsen sein, man muss mindestens 18 Jahre alt sein, um den Reparaturbonus Sachsen in Anspruch nehmen zu dürfen.</p>
  <p>Nur für Privatkunden, <b>keine Firmen</b></p>
  <p>Bewilligungsstelle für das Programm ist die Sächsische Aufbaubank Förderbank (SAB)</p>
`;
}



function setup_action_buttons() {


// Updated click event handler for the schedule button
  $('#schedule-button').on('click', function(event) {
      event.preventDefault(); // Prevent the default action of the button
      if (BONUS_ON)
        showCustomModal(getRepairBonusModalContent(), 'info'); // Show modal with content
      show_calendar(); // Show the calendar after the modal
      activate_step(2); // Move to step 2
  });
  $('#back-button').on('click', function(event) {
      event.preventDefault(); // To prevent following the link (optional)
      hide_calendar();
      activate_step(1)
  });

  $('#show-form-button').on('click', function(event) {
      event.preventDefault(); // To prevent following the link (optional)
      show_form();
      activate_step(3)
  });
  $('#back-to-scheduling').on('click', function(event) {
      event.preventDefault(); // To prevent following the link (optional)
      hide_form();
      activate_step(2)
  });

  $('#submit-button').on('click', function(event) {
      event.preventDefault(); // To prevent following the link (optional)
      submitForm();
  });
}

function show_form() {
  $("#schedule-action-buttons").hide();
  $("#calendar-timer-container").hide();
  $("#customer-details-container").show();
  $("#submit-action-container").show();
}

function hide_form() {
  $("#schedule-action-buttons").show();
  $("#calendar-timer-container").show();
  $("#customer-details-container").hide();
  $("#submit-action-container").hide();
}



  // Validate First Name
function validateFirstName() {
  var firstName = $('#firstName').val().trim();
  if (firstName === '') {
    $('#firstName').addClass('is-invalid');
    return false;
  } else {
    $('#firstName').removeClass('is-invalid');
    return true;
  }
}

// Validate Last Name
function validateLastName() {
  var lastName = $('#lastName').val().trim();
  if (lastName === '') {
    $('#lastName').addClass('is-invalid');
    return false;
  } else {
    $('#lastName').removeClass('is-invalid');
    return true;
  }
}

// Validate Email
function validateEmailField() {
  var email = $('#email').val().trim();
  if (email === '' || !validateEmail(email)) {
    $('#email').addClass('is-invalid');
    return false;
  } else {
    $('#email').removeClass('is-invalid');
    return true;
  }
}

// Validate Phone Number
function validatePhone() {
  var phone = $('#phone').val().trim();
  if (!validatePhoneNumber(phone)) {
    $('#phone').addClass('is-invalid');
    return false;
  } else {
    $('#phone').removeClass('is-invalid');
    return true;
  }
}

// Validate Notes Length (max 500 characters)
function validateNotes() {
  var notes = $('#notes').val().trim();
  if (notes.length > 500) {
    $('#notes').addClass('is-invalid');
    return false;
  } else {
    $('#notes').removeClass('is-invalid');
    return true;
  }
}

// Validate AGB Checkbox
function validateAGB() {
  if (!$('#agb').is(':checked')) {
    $('#agb').addClass('is-invalid');
    $('.agb-invalid-feedback').show(); // Show the error message
    return false;
  } else {
    $('#agb').removeClass('is-invalid');
    $('.agb-invalid-feedback').hide(); // Hide the error message if checkbox is checked
    return true;
  }
}

// Overall form validation
function validateForm() {
  var isValid = true;
  if (!validateFirstName()) isValid = false;
  if (!validateLastName()) isValid = false;
  if (!validateEmailField()) isValid = false;
  if (!validatePhone()) isValid = false;
  if (!validateNotes()) isValid = false;
  if (!validateAGB()) isValid = false;

  if (!isValid) {
    // Show error modal with a combined message of errors
    showCustomModal("Bitte überprüfen Sie das Formular auf Fehler und füllen Sie alle erforderlichen Felder korrekt aus.", 'error');
  }


  return isValid;
}

// Email validation function
function validateEmail(email) {
  var re = /^(([^<>()\[\]\.,;:\s@"]+(\.[^<>()\[\]\.,;:\s@"]+)*)|(".+"))@(([^<>()[\]\.,;:\s@"]+\.)+[^<>()[\]\.,;:\s@"]{2,})$/i;
  return re.test(email);
}

function validatePhoneNumber(phone) {
  var phonePattern = /^(?:049|\+49|0)\d{6,20}$/;
  return phonePattern.test(phone);
}

function show_calendar() {

  if (!flatpickr_instance) {
    getAvailableDays(get_min_date().toISOString().split('T')[0]);
  }
  $("#device-select-container").hide();
  $("#schedule-button").hide();
  $("#schedule-action-buttons").show();
  $("#calendar-timer-container").show();
}

function activate_step(step) {
  window.scrollTo({
    top: 0,
    behavior: 'smooth' // This ensures smooth scrolling
  });
  $(".step-number").removeClass("active-step");
  $(`#step-${step}`).addClass("active-step");
}

function hide_calendar() {

  $("#device-select-container").show();
  $("#calendar-timer-container").hide();
  $("#schedule-button").show();
  $("#device-select-container").show();
  $("#calendly-container").empty();
  $("#schedule-action-buttons").hide();

}

function get_min_date() {
  let date = new Date(); // Get today's date

  date.setDate(date.getDate() + MIN_DAYS_FROM_TODAY ); // Start from after tomorrow

  // Loop to ensure the min date is not a Sunday (0 = Sunday)
  while (date.getDay() === 0) {
      date.setDate(date.getDate() + 1); // Increment the date by 1 day
  }
  return date; // Return the first non-Sunday date
}

function get_max_date() {
  let minDate = get_min_date(); // Get the min date
  let maxDate = new Date(minDate); // Start with the min date
  maxDate.setMonth(maxDate.getMonth() + 1); // Add one month
  return maxDate; // Return the first non-Sunday date after one month
}

function init_flatpickr(data) {


  var availableDates = data.map(dateStr => new Date(dateStr));


  var minDate = availableDates[0];  // First available
  var maxDate = availableDates[availableDates.length - 1];  // Last available Date

  var min = get_min_date()
  if (minDate < min) {
    minDate = min;
  }

  flatpickr_instance = flatpickr(
    "#calendar", {
    inline: true,
    defaultDate: minDate ,
    minDate: minDate,
    maxDate: maxDate,
    locale: {
        firstDayOfWeek: 1,
        weekdays: {
            shorthand: ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"],
            longhand: ["Sonntag","Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"],
        },
        months: {
            shorthand: ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"],
            longhand: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"],
        }
    },
    disable: [
      function(date) {
          // Return true to disable Sundays (0 is Sunday)
          return !availableDates.some(d => d.toDateString() === date.toDateString());
      }
    ],
    onReady: function(selectedDates, dateStr, instance) {
        if (dateStr)
          updateAvailableTimeSlots(dateStr);  // Fetch new time slots when date changes
      },
    onChange: function(selectedDates, dateStr, instance) {
        if (dateStr)
          updateAvailableTimeSlots(dateStr);  // Fetch new time slots when date changes
      }
  });
}


function getAvailableDays(dateStr) {
  var url = window.location.origin + "/api/partner/calendar_entries/available_slots";
  var token = bookingData.token;  // Your authorization token
  var merchantId = $('#branch-select').val();

  var startDate = new Date(dateStr);
  var endDate = new Date(startDate);
  endDate.setMonth(startDate.getMonth() + 2);

  var formattedEndDate = endDate.toISOString().split('T')[0];


  $.ajax({
    url: url,
    method: "GET",
    data: {
      start_date: dateStr,
      end_date: formattedEndDate,
      merchant_id: merchantId,
      days_only: true
    },
    headers: {
      'Authorization': 'Token token=' + token
    },
    success: function(data) {
      init_flatpickr(data);
    },
    error: function(err) {
    }
  });
}

function updateAvailableTimeSlots(dateStr) {
  var url = window.location.origin + "/api/partner/calendar_entries/available_slots";
  var token = bookingData.token;  // Your authorization token
  var merchantId = $('#branch-select').val();

  $.ajax({
    url: url,
    method: "GET",
    data: {
      start_date: dateStr,
      merchant_id: merchantId
    },
    headers: {
      'Authorization': 'Token token=' + token
    },
    success: function(data) {
      // Clear previous time slots
      populate_time_picker(data)
      // Append each available slot as a button

    },
    error: function(err) {

    }
  });
}

function populateBranchSelect() {
  var url = window.location.origin + "/api/partner/merchants/branches";
  var token = bookingData.token;  // Your authorization token
  $.ajax({
    url: url,
    method: "GET",
    headers: {
      'Authorization': 'Token token=' + token
    },
    success: function(data) {
      $('#branch-select').empty();
      // Add options dynamically
      data.forEach(function(branch, index) {


        var option = new Option(branch.name, branch.id);
        $(option).attr('data-address', branch.address);
        $('#branch-select').append(option);

        // Set the first item as selected by default
        if (index === 0) {
          $('#branch-select').val(branch.id);
          handleBranchChange();

        }
      });
    },
    error: function(err) {

    }
  });
  $('#branch-select').on('change', function() {
    handleBranchChange();
  });
}


function handleBranchChange() {
  // Fetch the selected branch's ID
  var companyName = $('#branch-select option:selected').text();
  var selectedOption = $('#branch-select option:selected');

// Get the address from the data-address attribute
  var branchAddress = selectedOption.data('address');

  $("#branch-name").text(companyName);
  $("#branch-address").text(branchAddress);

  var googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=' + encodeURIComponent(branchAddress);

  // Update the href of the anchor tag with the Google Maps URL
  $('#branch-address-url').attr('href', googleMapsUrl);
  hide_termin_panel();
}



function enable_next_button() {
  $("#show-form-button").prop('disabled', false);
}
function disable_next_button() {
  $("#show-form-button").prop('disabled', true);
}

function populate_time_picker(data){
  $(".time-picker").empty();
  data.forEach(function(slot) {
    var startTime = new Date(slot.start);
    var endTime = new Date(slot.end);

    var formattedStartTime = startTime.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'});
    var formattedEndTime = endTime.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'});
    var formattedDate = startTime.toLocaleDateString([], {day: '2-digit', month: 'long', year: 'numeric'});
    //var formattedDate = startTime.toLocaleDateString('de-DE', { weekday: 'long', day: '2-digit', month: 'long', year: 'numeric' });

    // Create the time button
    var timeButton = $(`<button class="time-button">${formattedStartTime}</button>`);

    // Append the button to the time-picker container
    $(".time-picker").append(timeButton);

    // Attach click event listener to the button
    timeButton.on('click', function() {
      selectedDateTime = startTime.toISOString();

      on_time_picker_selected(formattedDate, formattedStartTime, formattedEndTime);
    });
  });
}

function on_time_picker_selected(date, startTime, endTime) {
  $("#termin-panel").show();
  $("#scheduled-date").text(date);
  $("#scheduled-time").text(`${startTime} bis ${endTime}`);
  enable_next_button();
  document.getElementById("show-form-button").scrollIntoView({
    behavior: "smooth",  // Ensures smooth scrolling
    block: "center"      // Scrolls to the element such that it's centered in the viewport
  });
}

function hide_termin_panel() {
  $("#termin-panel").hide();
  $("#scheduled-date").text("");
  $("#scheduled-time").text("");
  disable_next_button();
  if (flatpickr_instance)
    flatpickr_instance.clear();
  $(".time-picker").empty();
}

function setup_form_validation() {
  $('#firstName').on('blur', function () {
    validateFirstName();
  });

  $('#lastName').on('blur', function () {
    validateLastName();
  });

  $('#email').on('blur', function () {
    validateEmailField();
  });

  $('#phone').on('blur', function () {
    validatePhone();
  });

  $('#notes').on('blur', function () {
    validateNotes();
  });

  $('#agb').on('change', function () {
    validateAGB();
  });
}

function showCustomModal(message, type) {
  // Set the message in the modal
  $('#customModalMessage').html(message);

  // Clear any existing alert classes
  $('#customModalMessage').removeClass('alert-danger alert-info');

  // Update the modal title and class based on type
  if (type === 'error') {
    $('#customModalLabel').text('Fehler');
    $('#customModalMessage').addClass('alert-danger'); // Set error styling
  } else if (type === 'info') {
    $('#customModalLabel').text('Information');
    $('#customModalMessage').addClass('alert-info'); // Set info styling
  }

  // Show the modal
  $('#customModal').modal('show');
}


function showSubmitButtonSpinner() {
  $('#submit-button').html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Processing...').prop('disabled', true);
}


function hideSubmitButtonSpinner() {
  $('#submit-button').html('Jetzt buchen').prop('disabled', false);
}

function submitForm() {
  // Validate the form first
  if (!validateForm()) {
    return;
  }



  // Collect form data
  var firstName = $('#firstName').val().trim();
  var lastName = $('#lastName').val().trim();
  var email = $('#email').val().trim();
  var phone = $('#phone').val().trim();
  var notes = $('#notes').val().trim();
  var merchantId = $('#branch-select option:selected').val();

  // Collect selected date and time (already stored in `selectedDateTime`)
  if (!selectedDateTime) {
    showCustomModal("Bitte wählen Sie ein Zeitfenster aus.", 'error');
    return;
  }

  var startTime = selectedDateTime;
  var endTime = new Date(new Date(selectedDateTime).getTime() + 90 * 60000).toISOString(); // 90-minute duration

  // Prepare the data to send
  var dataToSend = {
    customer: {
      first_name: firstName,
      last_name: lastName,
      email: email,
      mobile_number: phone
    },
    repair_set_id: $('#repair-set-select').val(),
    start_at: startTime,
    end_at: endTime,
    merchant_id: merchantId
  };

  // Conditionally add notes if it's not empty
  if (notes !== '') {
    dataToSend.notes = notes;
  }
  // Authorization token

  showSubmitButtonSpinner();
  var token = bookingData.token;  // Your authorization token

  $.ajax({
    url: window.location.origin + "/api/partner/issue_calendar_entries",
    method: "POST",
    contentType: "application/json",
    data: JSON.stringify(dataToSend),
    headers: {
      'Authorization': 'Token token=' + token // Include the token in the headers
    },
    success: function(response) {

      if (window.umami) {
        window.umami.track('booking-checkout-completed');
      }
      // Success message or redirect
      if (bookingData.withSubdomain) {
        window.location.href = `/booking/thanks`;
      }else {
        window.location.href = `/booking/${bookingData.accountUuid}/thanks`;
      }
    },
    error: function(xhr) {
      var response = xhr.responseJSON;
      // Check for dry-schema errors
      if (response && response.errors && Array.isArray(response.errors)) {
        handleDrySchemaErrors(response.errors); // Handle dry-schema errors
      } else {
      // Check for ActiveRecord errors
        if (response && response.errors && typeof response.errors === 'object') {
          handleActiveRecordErrors(response.errors); // Handle ActiveRecord errors
        }
      }

      // General error handler (if no specific errors are returned)
      if (!response.errors) {
        showCustomModal("Es ist ein unbekannter Fehler aufgetreten. Bitte versuchen Sie es später erneut.", 'error');
      }
      hideSubmitButtonSpinner()
    }
  });
}

  // Method to handle Dry-Schema errors
function handleDrySchemaErrors(errors) {
  // Iterate through each error in the response
  errors.forEach(function(error) {
    var field = error.path[0]; // Get the field name (e.g., 'notes', 'email', etc.)
    var message = error.text; // The error message text (e.g., 'must be filled')

    // Show error for the corresponding input field
    var inputField = $(`#${field}`);
    inputField.addClass('is-invalid'); // Highlight the field as invalid
    var invalidFeedback = inputField.siblings('.invalid-feedback');
    invalidFeedback.text(message); // Set the error message for the field
    invalidFeedback.show(); // Display the error message
  });
}

// Method to handle ActiveRecord errors
function handleActiveRecordErrors(errors) {
  // Iterate through each error field (e.g., 'email', 'mobile_number')
  Object.keys(errors).forEach(function(field) {
    var messages = errors[field]; // Get the array of error messages for the field

    // Join multiple error messages (if any) into a single string
    var message = messages.join(', ');

    // Show error for the corresponding input field
    if (field === 'mobile_number') {
      field = 'phone'; // Change the field name to match the input field ID
    }
    var inputField = $(`#${field}`);
    inputField.addClass('is-invalid'); // Highlight the field as invalid
    var invalidFeedback = inputField.siblings('.invalid-feedback');
    invalidFeedback.text(message); // Set the error message for the field
    invalidFeedback.show(); // Display the error message
  });
}




$(function () {
  init_components();
  setup_manufacturer();
  setup_model();
  setup_repair_set();
  setup_action_buttons();
  populateBranchSelect();
  setup_form_validation();
});


