
  function getSelectOptions(model, min_input){

    var url = window.location.origin + "/api/"+model;
    var fields =["name"];
    var predicate="contains"
    var selectOptions = {
      language: {
        inputTooShort: function () {
          return "Bitte mindestens 2 Zeichen eingeben!";
        }
      },
      theme: 'bootstrap4',
      width: 380,
      minimumInputLength: min_input,
      allowClear: true,
      ajax: {
        url: url,
        dataType: "json",
        delay: 250,
        cache: true,
        data: function(params) {
          var textQuery = {
            m: "or"
          };
          fields.forEach(function(field) {
            textQuery[field + "_" + predicate] = params.term;
          });
          var query = {
            order: "name_desc",
            search_term: params.term,
            device_manufacturer_id: $("#device-manufacturer-select").val(),
            device_model_id: $("#device-model-select").val(),
            device_failure_category_id: $("#device-failure-category-select").val(),
            device_failure_specification_id: $("#device-failure-specification-select").val(),
            q: {
              groupings: [ textQuery ],
              combinator: "and",
              device_manufacturer_id_eq:  $("#device-manufacturer-select").val()
            }
          };
          return query;
        },
        processResults: function(data) {
          var processed = {
            results: jQuery.map(data, function(resource) {
              return {
                id: resource.id,
                text: resource["name"].toString(),
                image_path: resource["image_path"] ? resource["image_path"].toString() : null
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

  function getSelectOptions(model, min_input){

  var url = window.location.origin + "/api/partner/"+model;
  var fields =["name"];
  var token = "7yVmSUwiuGPoWL6V2xMwLgXBaNnqGXwFWpXm"
  var selectOptions = {
    language: {
      inputTooShort: function () {
        return "Bitte mindestens 2 Zeichen eingeben!";
      }
    },
    theme: 'bootstrap4',
    width: 380,
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
              price: resource["beautified_brutto_b2c"] ? resource["beautified_brutto_b2c"].toString() : null,
            };
          })
        };

        return processed;
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


    var data = $('#device-model-select').select2('data');

    if (data.length > 0) {
      $("#device-model-image-preview").attr("src", data[0].image_path);
      $("#device-model-image-label").text(data[0].text);
    }else {
      $("#device-model-image-label").text( "");
      $("#device-model-image-preview").attr("src", "/images/device_pictures/no-device.png");
    }
    update_repair_set_price();

  }

  function update_repair_set_price()  {
    var data = $('#repair-set-select').select2('data');

    if (data.length > 0) {
      $("#checkout-button").show();
      $("#label-button").show();
      var price = parseFloat(data[0].price.replace(",", "."));
        $("#repair-price").text(`${data[0].price.replace(".", ",")} €`);
        $("#repair-price-with-bonus").text(`${data[0].price.replace(".", ",")} €`);
      if (price > 400) {
        $("#repairbonus-container").show();
        $(".repairbonus-disclaimer").each(function() {
          $(this).show();
        });
        $("#repairbonus").text(" - 200 €");
        $("#repair-price-with-bonus").text(`${(price - 200).toFixed(2).replace(".", ",")} €`);
      }else if ( price > 75){
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
      $("#checkout-button").hide();
      $("#label-button").hide();
      $("#repair-price").text("");
      $("#repairbonus-container").hide();
      $(".repairbonus-disclaimer").each(function() {
          $(this).hide();
        });


    }

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
          update_repair_set_price();
        }, 50);
      }
      }
    );

    $('#repair-set-select').on('select2:unselecting', function (e) {
      if (e.params) {
        window.setTimeout(function () {
          update_repair_set_price();
        }, 50);
      }
      }
    );

  }






  function setup_checkout_button() {

    $('#checkout-button').on('click', function(event) {

        $('#popupModal').modal('show');
        //event.preventDefault(); // To prevent following the link (optional)
        //open_calendly();
    });


    $('#back-button').on('click', function(event) {
        event.preventDefault(); // To prevent following the link (optional)
        close_calendly();
    });

    $('#label-button').on('click', function(event) {
      event.preventDefault(); // To prevent following the link (optional)
      $('#popupModal2').modal('show');
    });



  }

  function open_versandlabel() {
    window.open("https://hush-haarentfernung.de/retourenlabel/", "_blank");
  }

  function open_calendly() {

    //$("#repair-set-container").hide();
    //$("#back-button").show();
    //$("#calendly-container").show();

    var model_data = $('#device-model-select').select2('data');
    var manufacturer_data = $('#device-manufacturer-select').select2('data');
    var repair_set_data = $('#repair-set-select').select2('data');

    Calendly.initPopupWidget({
        url: 'https://calendly.com/hush/reparatur',
        parentElement: document.getElementById('calendly-container'),
        prefill: {
            customAnswers: {
                a2: model_data[0].text + " " + manufacturer_data[0].text,
                a3: repair_set_data[0].text
            }
        }
   });
  }


  function close_calendly() {

    $("#repair-set-container").show();
    $("#calendly-container").empty();
    $("#back-button").hide();

  }

  $(function () {

    init_components();
    setup_manufacturer();
    setup_model();
    setup_repair_set();

    setup_checkout_button();
  });


    var md = new MobileDetect(window.navigator.userAgent);


    if (md.mobile()) {
      $("#repair-set-container").remove();
      $("#calendly-container").remove();
    }else{
      $("#mobile-button").remove();
    }


