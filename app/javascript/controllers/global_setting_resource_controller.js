import { Controller } from "@hotwired/stimulus"


export default class extends Controller {

  static targets = [

  ] // use the target Avo prepared for you
  static values = { view: String }



  async connect() {


    if (this.viewValue == 'new' || this.viewValue == 'edit') {
      this.register_tinymce();
    }
  }


  register_tinymce(){
   tinymce.init({
     selector: '.tinymce',
     language: 'de',
     height: 300,
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


}
