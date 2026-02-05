import { Controller } from "@hotwired/stimulus"


export default class extends Controller {

  static targets = [
    'htmlBodyTextareaInput', 'htmlBodyTextareaWrapper',
    'textBodyTextareaInput', 'textBodyTextareaWrapper',
    'templateTypeSelectInput',

  ] // use the target Avo prepared for you
  static values = { view: String }
  static preSelectedArea



  async connect() {


    if (this.viewValue == 'new' || this.viewValue == 'edit') {
      this.register_tinymce();
      this.hide_or_show_textarea()
    }
  }


  onTemplateTypeSelectChange(event) {


    this.hide_or_show_textarea()
  }

  hide_or_show_textarea() {
    let value = this.templateTypeSelectInputTarget.selectedOptions[0].value

    switch (value) {
      case 'repair_report':
      case 'mail':
      case 'html':
      case 'print':
        this.hideElements([this.textBodyTextareaWrapperTarget])
        this.showElements([this.htmlBodyTextareaWrapperTarget])
        break;
      case 'text':
      case 'sms':
        this.hideElements([this.htmlBodyTextareaWrapperTarget])
        this.showElements([this.textBodyTextareaWrapperTarget])
        break;
      default:
        this.hideElements(this.textInputs())
    }
  }

  register_tinymce(){
   tinymce.init({
     selector: '.tinymce',
     extended_valid_elements : "svg[*],path[*]",
     language: 'de',
     height: 800,
     menubar: true,
     _plugins: [
       'advlist autolink lists link image charmap print preview anchor',
       'searchreplace visualblocks code fullscreen',
       'insertdatetime media table paste code help wordcount'
     ],
     toolbar: 'undo redo | formatselect | ' +
      ' bold italic backcolor | alignleft aligncenter ' +
      ' alignright alignjustify | bullist numlist outdent indent | ' +
      ' removeformat | table tabledelete | code fullscreen preview help',

    plugins: 'table fullscreen preview code visualblocks image link',
    __plugins: 'preview importcss searchreplace autolink autosave save directionality code visualblocks visualchars fullscreen image link media template codesample table charmap pagebreak nonbreaking anchor insertdatetime advlist lists wordcount help charmap quickbars emoticons',


   });
  }


  disconnect() {
    tinymce.remove()
  }


  // Private

  textInputs() {
    return [
      this.htmlBodyTextareaWrapperTarget,
      this.textBodyTextareaWrapperTarget,
    ]
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
