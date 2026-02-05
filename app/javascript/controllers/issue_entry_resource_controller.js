import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ['articleBelongsToInput', 'categorySelectInput', 'categorySelectWrapper',
  'issueBelongsToWrapper',
  'repairSetBelongsToWrapper','repairSetBelongsToInput','articelBelongsToWrapper',
  'articleNameTextWrapper','articleBelongsToWrapper',
  'pricePriceInput', 'qtyNumberWrapper'
  ] // use the target Avo prepared for you
  static values = { view: String }
  static preSelectedArea

  get placeholder() {

    return "i18n_please_select_an_option"
  }


  async connect() {

    if (this.viewValue == 'index') {
      this.scanAndGroupRows()
      return
    }



    this.boundUpdateSummaryFrame = this.updateSummaryFrame.bind(this)
    document.addEventListener("turbo:frame-load", this.boundUpdateSummaryFrame)

    if (['new', 'create', 'edit'].includes(this.viewValue)) {
      this.onCategoryChange()
    }
  }


  disconnect() {
    document.removeEventListener("turbo:frame-load", this.boundUpdateSummaryFrame)
  }

  updateSummaryFrame(event) {
    if (event.target.id == "has_many_field_show_issue_entries"){
      var el = document.getElementById("summary")
      el.reload()
    }
  }
  onCategoryChange(event) {
    this.hideElements([this.issueBelongsToWrapperTarget]);
    if (this.viewValue === 'edit') {
      this.hideElements([this.categorySelectWrapperTarget]);
    }

    if (event) {
      this.updateFieldAttribute(this.pricePriceInputTarget, "value", 0.0);
    }

    this.pricePriceInputTarget.readOnly = false;
    let value = this.categorySelectInputTarget.selectedOptions[0].value;

    this.handleCategoryDisplay(value);
  }

  handleCategoryDisplay(category) {
    switch (category) {
      case "article":
        this.configureArticleUI();
        break;
      case "repair_set":
        this.configureRepairSetUI();
        break;
      case "text":
        this.configureTextUI();
        break;
      case "rabatt":
        this.configureRabattUI();
        break;
    }
  }

  configureArticleUI() {
    this.hideElements([this.articleNameTextWrapperTarget, this.repairSetBelongsToWrapperTarget]);
    this.showElements([this.articleBelongsToWrapperTarget, this.qtyNumberWrapperTarget]);
  }

  configureRepairSetUI() {
    if (this.viewValue === 'new') {
      this.hideElements([this.articleNameTextWrapperTarget, this.articleBelongsToWrapperTarget, this.qtyNumberWrapperTarget]);
      this.showElements([this.repairSetBelongsToWrapperTarget]);
    } else if (this.viewValue === 'edit') {
      this.hideElements([this.articleNameTextWrapperTarget, this.repairSetBelongsToWrapperTarget, this.articleBelongsToWrapperTarget]);
    }
  }

  configureTextUI() {
    this.hideElements([this.repairSetBelongsToWrapperTarget, this.articleBelongsToWrapperTarget]);
    this.showElements([this.articleNameTextWrapperTarget, this.qtyNumberWrapperTarget]);
  }

  configureRabattUI() {
    this.hideElements([
      this.repairSetBelongsToWrapperTarget,
      this.articleBelongsToWrapperTarget,
      this.articleNameTextWrapperTarget,
      this.qtyNumberWrapperTarget
    ]);
  }

  toggleInput(disable = true, inputTarget) {
    if (!inputTarget) return;

    const buttonElement = inputTarget.closest('.relative').querySelector('[data-search-target="clearButton"]');
    if (disable) {
      inputTarget.setAttribute('disabled', 'true');
      inputTarget.classList.add('disabled:opacity-50', 'disabled:cursor-not-allowed');
      inputTarget.dataset.shouldBeDisabled = "true";

      if (buttonElement) {
        buttonElement.setAttribute('disabled', 'true');
        buttonElement.classList.add('disabled:cursor-not-allowed');
      }
    } else {
      inputTarget.removeAttribute('disabled');
      inputTarget.classList.remove('disabled:opacity-50', 'disabled:cursor-not-allowed');
      inputTarget.dataset.shouldBeDisabled = "false";

      if (buttonElement) {
        buttonElement.removeAttribute('disabled');
        buttonElement.classList.remove('disabled:cursor-not-allowed');
      }
    }
  }


  async hideElements(elements) {
    Array(elements).flat().forEach((el) => {
      el.classList.add("hidden")
    })
  }

  async showElements(elements) {
    Array(elements).flat().forEach((el) => {
      el.classList.remove("hidden")
    })
  }


  async onArticleChange(event) {

    if (!event || event.target.type != 'hidden')
      return

    if (!['new', 'create'].includes(this.viewValue))
      return


    var el = this.articleBelongsToInputTargets.find(element => element.type === 'hidden');


    if (el) {
      const article_id = el.value
      if (!article_id) {
        return
      }
      const data = await this.fetchArticle(article_id)
      this.pricePriceInputTarget["priceField"].setRawNettoValue(data.retail_price)
    }
  }


  async onRepairSetChange(event) {

    if (!event || event.target.type != 'hidden')
      return

    if (!['new', 'create'].includes(this.viewValue))
      return


    var el = this.repairSetBelongsToInputTargets.find(element => element.type === 'hidden');

    if (el) {
      const repair_set_id = el.value
      if (!repair_set_id) {
        return
      }

      const data = await this.fetchRepairSet(repair_set_id)

      this.pricePriceInputTarget["priceField"].setRawNettoValue(data.retail_price)
    }
  }


  // Private
  updateFieldAttribute(target, attribute, value) {
    target.value = value
    target.setAttribute(attribute, value)
    target.dispatchEvent(new Event('input'))
  }

  async fetchArticle(article_id){
    if (!article_id) {
      return []
    }

    this.loading = true

    const response = await fetch(
      `${window.Avo.configuration.root_path}/resources/articles/${article_id}`, {
          headers: { 'Accept': 'application/json'}
        }
    )
    const data = await response.json()

    this.loading = false

    return data
  }



  async fetchRepairSet(repair_set_id){
    if (!repair_set_id) {
      return []
    }

    this.loading = true

    const response = await fetch(
      `${window.Avo.configuration.root_path}/resources/repair_sets/${repair_set_id}`, {
          headers: { 'Accept': 'application/json'}
        }
    )
    const data = await response.json()

    this.loading = false

    return data

  }

  scanAndGroupRows() {
    const turboFrame = document.getElementById('has_many_field_show_issue_entries');
    if (!turboFrame) return;

    const tableBody = turboFrame.querySelector('.w-full tbody');
    if (!tableBody) return;

    this.clearExistingGroupRows(tableBody);

    const repairSets = this.groupRepairSets(tableBody.querySelectorAll('tr'));
    this.assignRepairSetIdsToCheckboxes(repairSets);

    this.insertGroupRows(repairSets, tableBody);
  }

  clearExistingGroupRows(tableBody) {
      const existingGroupRows = tableBody.querySelectorAll('.group-row');
      existingGroupRows.forEach(row => row.remove());
  }

  groupRepairSets(rows) {
    const repairSets = {};

    rows.forEach(row => {
      row.classList.add('show-row');
      const hiddenInput = row.querySelector('input[name="row_repair_set[]"]');
      if (hiddenInput) {
        const repairSetName = hiddenInput.getAttribute('data-repair-set-name');
        const repairSetId = hiddenInput.getAttribute('data-repair-set-id');
        const repairSetPrice = parseFloat(hiddenInput.getAttribute('data-repair-set-entry-price')) || 0;

        if (!repairSets[repairSetId]) {
          repairSets[repairSetId] = { name: repairSetName, totalPrice: 0, rows: [] };
        }

        repairSets[repairSetId].totalPrice += repairSetPrice;
        repairSets[repairSetId].rows.push(row);
      }
    });

    return repairSets;
  }

  assignRepairSetIdsToCheckboxes(repairSets) {
    for (const [repairSetId, repairSetData] of Object.entries(repairSets)) {
        this.assignRepairSetIdToCheckboxes(repairSetData, repairSetId);
    }
  }

  insertGroupRows(repairSets, tableBody) {
    for (const [repairSetId, repairSetData] of Object.entries(repairSets)) {
      const firstRow = tableBody.querySelector(`input[data-repair-set-id="${repairSetId}"]`).closest('tr');
      const groupRow = this.createGroupRow(repairSetData.name, repairSetId, repairSetData.totalPrice);
      firstRow.parentNode.insertBefore(groupRow, firstRow);

      const lastRow = repairSetData.rows[repairSetData.rows.length - 1];
      lastRow.style.borderBottom = '1px solid #000';
    }
  }


  assignRepairSetIdToCheckboxes(repairSetData, repairSetId) {
    repairSetData.rows.forEach(row => {
      const checkbox = row.querySelector('input[type="checkbox"][name="Artikel auswählen"]');
      if (checkbox) {
        checkbox.setAttribute('data-repair-set-id', repairSetId);
      }
    });
  }

  toggleGroupCheckboxes(event) {
    const checkbox = event.target;
    const repairSetId = checkbox.value;
    const allCheckboxes = this.element.querySelectorAll(`input[data-repair-set-id="${repairSetId}"]`);

    allCheckboxes.forEach(cb => {
      cb.click()
      cb.checked = checkbox.checked;
    });
  }

  // Create a grouping row with a minus icon, repair set name, and total price
  createGroupRow(repairSetName, repairSetId, totalPrice) {
    const groupRow = document.createElement('tr');
    groupRow.classList.add('group-row', 'bg-gray-100', 'hover:bg-gray-200');  // Add styling if needed

    const iconCell = document.createElement('td');
    iconCell.classList.add('w-10', 'px-3', 'py-3', 'text-center', 'cursor-pointer');
    iconCell.innerHTML = `
      <input type="checkbox" name="Set auswählen" id="repair-set[]" value="${repairSetId}"
        class="mx-3 rounded checked:bg-primary-400 focus:checked:!bg-primary-400  w-4 h-4"
        data-action="click->issue-entry-resource#toggleGroupCheckboxes" >
    `;

    // const controllCell = document.createElement('td');
    // controllCell.classList.add('w-10', 'px-3', 'py-3', 'text-center', 'cursor-pointer');
    // controllCell.innerHTML = ""


    const nameCell = document.createElement('td');
    nameCell.classList.add('pl-5', 'py-3', 'text-left', 'font-semibold');
    nameCell.setAttribute('colspan', '5'); // Adjust colspan based on your table structure

    // Create the link element
    const link = document.createElement('a');
    link.href = `/resources/repair_sets/${repairSetId}`;  // Generate the link using the repairSetId
    link.target = '_blank';  // Set target to _blank to open in a new tab
    link.textContent = repairSetName;
    link.classList.add('text-blue-500', 'hover:underline'); // Add any styling classes you prefer

    // Append the link to the cell
    nameCell.appendChild(link);

    // Create a cell for the total price
    const priceCell = document.createElement('td');
    priceCell.classList.add('py-3', 'text-left', 'font-semibold', 'px-3');
    priceCell.textContent = `${totalPrice.toFixed(2).replace('.', ',')} €`; // Format the total price
    priceCell.dataset.originalText = priceCell.textContent; // Store the original text for resetting
    // priceCell.setAttribute('contenteditable', 'true'); // Enable inline editing
    // priceCell.dataset.action = "focus->issue-entry-resource#handleFocus blur->issue-entry-resource#handleBlur  keydown->issue-entry-resource#handleKeyDown";


    const actionCell = document.createElement('td');
    actionCell.classList.add('cursor-pointer');
    actionCell.dataset.action = "click->issue-entry-resource#openUpdatePriceModal";
    actionCell.dataset.price = priceCell.textContent;
    actionCell.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
      stroke="currentColor" class="text-gray-600 h-6 hover:text-gray-600">
      <path d="M9.00001 20.2499H4.5C4.30109 20.2499 4.11033 20.1709 3.96967 20.0302C3.82902 19.8896 3.75 19.6988 3.75 19.4999V15.3093C3.74966 15.2119 3.76853 15.1154 3.80553 15.0253C3.84253 14.9352 3.89694 14.8533 3.96563 14.7843L15.2156 3.53429C15.2854 3.46343 15.3686 3.40715 15.4603 3.36874C15.5521 3.33033 15.6506 3.31055 15.75 3.31055C15.8495 3.31055 15.9479 3.33033 16.0397 3.36874C16.1314 3.40715 16.2146 3.46343 16.2844 3.53429L20.4656 7.71554C20.5365 7.78533 20.5928 7.86851 20.6312 7.96026C20.6696 8.052 20.6894 8.15046 20.6894 8.24992C20.6894 8.34938 20.6696 8.44784 20.6312 8.53958C20.5928 8.63132 20.5365 8.71451 20.4656 8.78429L9.00001 20.2499Z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>
      <path d="M20.25 20.25H9" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>
      <path d="M12.75 6L18 11.25" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>
    </svg>`;

    // Append cells to the group row
    groupRow.appendChild(iconCell);
    //groupRow.appendChild(controllCell);
    groupRow.appendChild(nameCell);
    groupRow.appendChild(priceCell);
    groupRow.appendChild(actionCell);

    return groupRow;
  }




  toggleCheckbox(event) {
    event.target.checked = !event.target.checked;
  }






  openUpdatePriceModal(event) {


    const currentRow = event.currentTarget.closest('tr');
    const table = currentRow.closest('table');  // Assuming the rows are within a table element
    // Uncheck all checkboxes in the same table
    const checkboxes = table.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach(checkbox => {
        checkbox.checked = false;
    });

    const price = event.currentTarget.dataset.price;
    const checkbox = currentRow.querySelector('input[type="checkbox"]');
    if (!checkbox.checked)
      checkbox.click();
    //checkbox.checked = true; // Ensure checkbox is selected when action cell is clicked

    let href=`/resources/issue_entries/actions/update_price_action?${new URLSearchParams({price: price})}`
    let tempLink = document.createElement("a")
    tempLink.href = href
    tempLink.setAttribute("data-turbo-frame", "actions_show")
    document.body.appendChild(tempLink)
    tempLink.click()
    document.body.removeChild(tempLink)
    this.setPriceWithDelay(price)
  }


  setPriceWithDelay(price) {

    let attempts = 0;
    const intervalId = setInterval(() => {
        const turboFrame = document.getElementById('actions_show');
        if (turboFrame) {
            const priceInput = turboFrame.querySelector('#fields_price_visble');
            if (priceInput) {
                const formattedPrice = parseFloat(price.replace(',', '.').replace(' €', '')).toFixed(2);
                priceInput.value = formattedPrice

                const event = new Event('change', { bubbles: true, cancelable: true });
                priceInput.dispatchEvent(event);

                let controller = this.application.getControllerForElementAndIdentifier(
                  document.querySelector('[data-controller~="price-field"]'),
                  "price-field"
                )

                if (controller) {

                  controller.onPriceInputChanged({ target: priceInput});
                }

                priceInput.select()
                clearInterval(intervalId);
            } else {
                attempts++;

                if (attempts >= 5) { // Give up after 5 attempts
                    clearInterval(intervalId);

                }
            }
        } else {

            clearInterval(intervalId);
        }
    }, 250);
  }

  // Archive code

    __handleFocus(event) {
      //event.target.classList.add('editing'); // Add the editing class when focused
    // Select the text inside the <td>
    const range = document.createRange(); // Create a range object
    const selection = window.getSelection(); // Get the current selection

    range.selectNodeContents(event.target); // Set the range to encompass the entire content of the <td>
    selection.removeAllRanges(); // Clear any existing selections
    selection.addRange(range); // Add the newly created range
  }

  __handleBlur(event) {
    if (this.fallbackToOriginalText) {
      event.target.textContent = event.target.dataset.originalText;
    } else {
      event.target.dataset.originalText = event.target.textContent;
    }

    event.target.classList.remove('editing');
  }


  async __updatePriceOnServer(price, avoResourceId) {
    // Fetch CSRF token from meta tag
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    // Normalize the price to ensure it's in the correct format for the server
    const formattedPrice = parseFloat(price.replace(',', '.').replace(' €', '')).toFixed(2);

    // Prepare the data to be sent to the server
    const dataToSend = {
        authenticity_token: csrfToken,
        fields: {
            avo_resource_ids: avoResourceId,
            price_visible: 100
        },
        price: formattedPrice
    };

    // Construct the URL with avo_resource_id as a query parameter
    const url = `/resources/issue_entries/actions/update_price_action`;

    // Perform the fetch request
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify(dataToSend)
    });

    if (!response.ok) {
      console.error('Failed to update price', response);
    } else {

    }
  }
  __handleKeyDown(event) {
    const allowedKeys = [
      'Enter', 'Escape', 'Backspace', 'Tab', 'ArrowLeft', 'ArrowRight', 'Delete'
    ];
    this.fallbackToOriginalText = true
    const allowedKeyCodes = [44, 46, 8, 13, 9, 37, 39, 46, 188]; // 190 is for period

    if (allowedKeys.includes(event.key)) {
      if (event.key === 'Enter') {
        event.preventDefault(); // Prevent default Enter behavior (newline)
        this.fallbackToOriginalText = false
        event.target.blur(); // Trigger blur to save
        let price = event.target.textContent
        this.updatePriceOnServer()
      } else if (event.key === 'Escape') {
        event.preventDefault(); // Prevent default Escape behavior
        event.target.blur(); // Trigger blur to save
      }
      return;
    }

    if (isNaN(String.fromCharCode(event.which)) && !allowedKeyCodes.includes(event.which)) {
      event.preventDefault();
    }
  }
}
