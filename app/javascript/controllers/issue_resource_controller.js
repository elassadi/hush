import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {

  static targets = ['inputDeviceModelBelongsToInput','inputDeviceColorBelongsToInput', 'templateSelectInput',
    'customerBelongsToInput', 'deviceBelongsToInput', 'deviceBelongsToWrapper', 'inputDeviceFailureCategoriesTagsWrapper',
    'deviceAccessoriesListTagsWrapper', 'selectedRepairSetBelongsToInput',
    'hasInsuranceCaseBooleanInput', 'insuranceNumberTextWrapper', 'insuranceBelongsToWrapper',
    'tablePossibleRepairSetsTableWrapper'
  ] // use the target Avo prepared for you
  static values = { view: String }
  static preSelectedArea
  static placeholder = ''
  static lastUpdateRepairSetsCall = 0;





  async connect() {

    window.recloudReloadIssueEntriesFrame = this.reloadIssueEntriesFrame

    this.registerInputChangeListener();
    if (this.hasDeviceBelongsToInputTarget) {
      this.placeholder = this.deviceBelongsToInputTarget.options[0].text
    }


    if (['new'].includes(this.viewValue)) {
      const customer_id = this.selectedCustomer()
      if (!customer_id) {
        this.hideElements(this.allDeviceInputs())
        this.hideElements(this.tablePossibleRepairSetsTableWrapperTarget)
      } else {
        if (this.hasSelectedRepairSetBelongsToInputTarget) {
          this.showElements(this.deviceAccessoriesListTagsWrapperTarget)
        }else {
          this.showElements(this.allDeviceInputs())
        }
      }
      document.addEventListener("resourceCreated", this.handleResourceCreated.bind(this))
    }
    if (['new','edit'].includes(this.viewValue)) {
      this.showOrHideInsuranceFields()
    }

    if (['edit'].includes(this.viewValue)) {
      //this.updateRepairSets()
    }


    this.observeTitleVisibility()
  }

  startLoadingPreviewDocument(event) {


    // Update the text
    const textElement = this.element.querySelector(".preview-text");
    textElement.textContent = "Vorschau wird geladen";

    // Update the SVG icon
    const iconElement = this.element.querySelector(".preview-icon");

        iconElement.innerHTML = `
                <div class="spinner">
                  <div class="double-bounce1 bg-gray-600"></div>
                  <div class="double-bounce2 bg-gray-800"></div>
                </div>`;
  }

  reloadIssueEntriesFrame() {
    const frame = document.getElementById('has_many_field_show_issue_entries')
    if (frame) {
      frame.reload()
    }
  }

  highlightStatusElement() {

    const eventEl = Array.from(document.querySelectorAll('[data-resource-show-target="statusStatusBadgeWrapper"] span'))
    .find(span => span.textContent.trim() === 'Warte auf Kundengerät');
    // Add a highlight class to the event element
    if (!eventEl) {
      return
    }
    eventEl.classList.add('highlighted-event');

    // Remove the highlight after 3 seconds
    setTimeout(() => {
      eventEl.classList.remove('highlighted-event');
    }, 2000);
  }

  observeTitleVisibility() {
    const titleElement = document.querySelector('[data-target="title"]');


    // Create a floating div for the REP-xxxx display
    const floatingDiv = document.createElement('div');
    floatingDiv.id = 'floating-rep-number';
    floatingDiv.style.position = 'fixed';
    floatingDiv.style.top = '12px';
    floatingDiv.style.right = '120px';
    floatingDiv.style.padding = '5px 10px';
    //floatingDiv.style.backgroundColor = 'rgba(0, 0, 0, 0.7)';
    //floatingDiv.style.color = '#fff';
    floatingDiv.style.color = '#000';
    floatingDiv.style.fontWeight = '600';
    floatingDiv.style.fontSize = '1.5rem';

    floatingDiv.style.borderRadius = '5px';
    floatingDiv.style.display = 'none'; // Initially hidden
    floatingDiv.innerHTML = titleElement.innerText;
    floatingDiv.style.zIndex = 1000;
    document.body.appendChild(floatingDiv);

    // Use IntersectionObserver to detect when the element is out of view
    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (!entry.isIntersecting) {
          // Element is not visible, show the floating div

          floatingDiv.style.display = 'block';
        } else {
          // Element is visible, hide the floating div
          floatingDiv.style.display = 'none';
        }
      });
    });

    // Start observing the title element
    observer.observe(titleElement);
  }

  showOrHideInsuranceFields() {
    const has_case = Boolean(this.hasInsuranceCaseBooleanInputTarget.checked)

    if (has_case) {
      this.showElements([this.insuranceBelongsToWrapperTarget, this.insuranceNumberTextWrapperTarget])
    } else {
      this.hideElements([this.insuranceBelongsToWrapperTarget, this.insuranceNumberTextWrapperTarget])
    }
  }

  onHasInsuranceCaseChanged(event) {
    this.showOrHideInsuranceFields()
  }

  allDeviceInputs() {
    return [
      ...this.deviceInputs(),
      this.deviceAccessoriesListTagsWrapperTarget
    ]
  }

  deviceInputs() {
    return [
      this.deviceBelongsToWrapperTarget,
      this.inputDeviceFailureCategoriesTagsWrapperTarget,
    ]
  }


  disconnect() {
    // document.removeEventListener("turbo:frame-load", this.boundUpdateCommentableFrame)
    this.unregisterInputChangeListener();
  }


  handleResourceCreated(event) {

    const { resourceModelName, resourceModelId } = event.detail

    if (resourceModelName === "customer") {
        // Delay the execution by 200ms
        setTimeout(() => {
          this.onCustomerSelectChange({ target: { type: 'hidden' } })
        }, 200)

    }
  }

  registerInputChangeListener() {
    let selector ="#issue_input_device_failure_categories"
    const inputElement = document.querySelector(selector);

    if (inputElement) {
      inputElement.addEventListener("change", this.onInputDeviceFailureCategoriesChanged.bind(this));
    }
  }

  unregisterInputChangeListener() {
    let selector ="#issue_input_device_failure_categories"
    const inputElement = document.querySelector(selector);

    if (inputElement) {
      inputElement.removeEventListener("change", this.onInputDeviceFailureCategoriesChanged.bind(this));
    }
  }


  async onInputDeviceFailureCategoriesChanged(event) {
    this.updateRepairSets()
  }

  async onDeviceChange(event) {

    this.updateRepairSets()
  }



  // can be removed later
  async updateRepairSetsWithSelectInput(){
    const customer_id = this.selectedCustomer()

    if (!customer_id) {
      return
    }

    let device_id = this.deviceBelongsToInputTarget.value
    if ( isNaN(device_id) ) {
      return;
    }
    let el = document.querySelector('#issue_input_device_failure_categories')
    let device_failure_categories = el.value
    this.showElements(this.tablePossibleRepairSetsTableWrapperTarget)

    const sets = await this.fetchRepairSets(device_id, device_failure_categories)
    if (sets.length === 0) {
      this.possibleRepairSetsSelectInputTarget.classList.add('no-sets');
    } else {
      this.possibleRepairSetsSelectInputTarget.classList.remove('no-sets');
    }

    this.populate_dropdown(this.possibleRepairSetsSelectInputTarget, sets, false)


    let frame = document.querySelector('#table_possible_repair_sets_turbo_frame')
    if (frame) {
      const src = new URL(frame.src, window.location.origin);
      src.searchParams.set('device_failure_categories', device_failure_categories);
      frame.src = src.toString();
      console.log(frame.src)
      console.log(device_failure_categories)
      frame.reload()
    }
  }

  async updateRepairSets() {
    const customer_id = this.selectedCustomer();

    if (!customer_id) {
      return;
    }

    let device_id = this.deviceBelongsToInputTarget.value;
    if (isNaN(device_id)) {
      return;
    }

    let el = document.querySelector('#issue_input_device_failure_categories');
    let device_failure_categories = el.value;
    this.showElements(this.tablePossibleRepairSetsTableWrapperTarget);

    let frame = document.querySelector('#table_possible_repair_sets_turbo_frame');
    if (frame) {
      // Add the loader content to the frame
      frame.innerHTML = `
        <div class="flex flex-col items-center justify-center p-4 text-gray-700">
          <svg class="tea" width="37" height="48" viewBox="0 0 37 48" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M27.0819 17H3.02508C1.91076 17 1.01376 17.9059 1.0485 19.0197C1.15761 22.5177 1.49703 29.7374 2.5 34C4.07125 40.6778 7.18553 44.8868 8.44856 46.3845C8.79051 46.79 9.29799 47 9.82843 47H20.0218C20.639 47 21.2193 46.7159 21.5659 46.2052C22.6765 44.5687 25.2312 40.4282 27.5 34C28.9757 29.8188 29.084 22.4043 29.0441 18.9156C29.0319 17.8436 28.1539 17 27.0819 17Z" class="stroke-current" stroke-width="2"></path>
            <path d="M29 23.5C29 23.5 34.5 20.5 35.5 25.4999C36.0986 28.4926 34.2033 31.5383 32 32.8713C29.4555 34.4108 28 34 28 34" class="stroke-current" stroke-width="2"></path>
            <path id="teabag" class="fill-current" fill-rule="evenodd" clip-rule="evenodd" d="M16 25V17H14V25H12C10.3431 25 9 26.3431 9 28V34C9 35.6569 10.3431 37 12 37H18C19.6569 37 21 35.6569 21 34V28C21 26.3431 19.6569 25 18 25H16ZM11 28C11 27.4477 11.4477 27 12 27H18C18.5523 27 19 27.4477 19 28V34C19 34.5523 18.5523 35 18 35H12C11.4477 35 11 34.5523 11 34V28Z"></path>
            <path id="steamL" d="M17 1C17 1 17 4.5 14 6.5C11 8.5 11 12 11 12" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="var(--secondary)"></path>
            <path id="steamR" d="M21 6C21 6 21 8.22727 19 9.5C17 10.7727 17 13 17 13" stroke="var(--secondary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>
          </svg>
          <div class="font-bold mt-2">Wird geladen</div>
        </div>
      `;

      // Update the frame's src with new query parameters
      const src = new URL(frame.src, window.location.origin);
      src.searchParams.set('device_failure_categories', device_failure_categories);
      src.searchParams.set('device_id', device_id);
      frame.src = src.toString();

      // Reload the frame
      frame.reload();
    }
  }





  findIssueId() {
    const div = document.querySelector('[data-model-name="Issue"]');

    const issueId = div ? div.getAttribute('data-model-id') : null;

    return issueId;
  }

  async fetchRepairSets(device_id, device_failure_categories) {
    if (!device_id) {
      return [];
    }

    this.loading = true;
    let issueId = this.findIssueId();
    const encodedCategories = encodeURIComponent(device_failure_categories);

    let url = `${window.Avo.configuration.root_path}/resources/devices/${device_id}/list_repair_sets?device_failure_categories=${encodedCategories}`;
    if (issueId) {
      url += `&issue_id=${issueId}`;
    }

    const response = await fetch(url);
    const data = await response.json();

    this.loading = false;

    return data;
  }


  async onInputDeviceModelChange(event) {

    if (!event || event.target.type != 'hidden')
    return

    var el = this.inputDeviceModelBelongsToInputTargets.find(element => element.type === 'hidden');

    if (el) {
      const device_model_id = el.value
      if (!device_model_id) {
        return
      }

      const colors = await this.fetchDeviceColorsByDeviceModeldId(device_model_id)
      this.populate_dropdown(this.inputDeviceColorBelongsToInputTarget, colors)
    }
  }



  populate_dropdown(dropdown, values, add_blank=true) {

    Object.keys(dropdown.options).forEach(() => {
      dropdown.options.remove(0)
    })

    // Add blank option
    if (add_blank) {
      dropdown.add(new Option(this.placeholder))
    }

    // Add the new areas
    values.forEach((value) => {
      const option = new Option(value[1], value[0])
      if (value[2] === true) {
        option.selected = true; // Set as selected if value[2] exists and is true
      }
      dropdown.add(option)
    })
  }



  async onTemplateSelectChange(event){


    var element = document.querySelector("trix-editor")
    var editor = element.editor
    let value = this.templateSelectInputTarget.selectedOptions[0].value
    element.classList.add('textarea-status');

    if (!value) {
      element.classList.remove('error-status', 'ok-status');
      return
    }

    var template = await this.fetchTemplate(value)

    if (template.metadata.tags && template.metadata.tags.includes("unsuccessfull")) {
      element.classList.remove( 'ok-status');
      element.classList.add('error-status');
    }else {
      element.classList.remove('error-status');
      element.classList.add( 'ok-status');
    }
    editor.setSelectedRange([0, editor.getDocument().getLength()]);
    editor.insertHTML(template.body);
  }






  async onCustomerSelectChange(event) {

    if (event.target.type != 'hidden')  {
      return
    }


    const customer_id = this.selectedCustomer()

    if (!customer_id) {
      this.populate_dropdown(this.deviceBelongsToInputTarget, [])
      this.hideElements(this.allDeviceInputs())
      this.hideElements(this.tablePossibleRepairSetsTableWrapperTarget)
      return
    }

    if (this.hasSelectedRepairSetBelongsToInputTarget) {
      this.showElements(this.deviceAccessoriesListTagsWrapperTarget)
    }else {
      this.showElements(this.allDeviceInputs())
      const devices = await this.fetchDevicesByCustomerId(customer_id)
      this.populate_dropdown(this.deviceBelongsToInputTarget, devices)
      this.deviceBelongsToInputTarget.dispatchEvent(new Event('click'));
    }
  }

  selectedCustomer(){
    var el = this.customerBelongsToInputTargets.find(element => element.type === 'hidden');

    if (el) {
      return  el.value
    }
    return null
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


  async fetchTemplate(template_id) {
    this.loading = true;
    try {
        const response = await fetch(
            `${window.Avo.configuration.root_path}/resources/templates/${template_id}`
        );

        if (!response.ok) {
            // Throw an error with a message based on the status code
            throw new Error(`Error ${response.status}: ${response.statusText}`);
        }

        const data = await response.json();
        return data;

    } catch (error) {
        // Handle the error (e.g., logging, setting an error message in the state)
        console.error('Failed to fetch the template:', error);
        // Optionally, set an error state or return a default/fallback value
        return { error: error.message };
    } finally {
        this.loading = false;
    }
}

  async fetchDeviceColorsByDeviceModeldId(device_model_id){
    if (!device_model_id) {
      return []
    }

    this.loading = true

    const response = await fetch(
      `${window.Avo.configuration.root_path}/resources/devices/colors?device_model_id=${device_model_id}`,
    )
    const data = await response.json()

    this.loading = false

    return data
  }

  async fetchDevicesByCustomerId(customer_id){
    if (!customer_id) {
      return []
    }

    this.loading = true

    const response = await fetch(
      `${window.Avo.configuration.root_path}/resources/devices/list_devices_for_customer?customer_id=${customer_id}`,
    )
    const data = await response.json()

    this.loading = false

    return data
  }
}
