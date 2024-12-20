function removeImage(id) {
  $.ajax({
      url: '/components/control.cfc?method=deleteImage',
      type: 'GET',
      data: {
          "image": id
      },
      success: function(data){
        $(`#image-${id}`).remove();
      }
  });
}

$(document).ready(function () {
  $('#subcategories').hide();
  
  $('#products').hide();

  const url = new URLSearchParams(window.location.search);

  if(url.has('cat')) {
    $('#subcategories').show();
  }

  if(url.has('sub')) {
    $('#products').show();
  }

  $('#modal').on('hidden.bs.modal',function(event){
    $('#modalForm').find('input','textarea','select').removeAttr('required').val('');
    $('#modalForm')[0].reset();
    $('#imageList').html('');
    $('#imageAdd').html('');
    $('#recordId').val('');
    $('#set').val('');
    window.location.href = window.location.href;
  });

  $('#modal').on('shown.bs.modal',function(event){
    if(!$('#product').hasClass("d-none")) {
      $('#categorySelect').change(function () {
        $.ajax({
          url: '/components/control.cfc?method=getSubcategory',
          type: 'GET',
          data: {
            "category": $('#categorySelect').val()
          },
          success: function(data){
            let subcategoryObj = JSON.parse(data);
            $('#subcategorySelect').html('<option value=""></option>');
            $.each(subcategoryObj, function(_, category) {
              $('#subcategorySelect').append(
                $('<option>', {
                  value: category.id,
                  text: category.name,
                  selected: category.id == url.get('sub')
                })
              );
            });
          }
        });
      });
    }
    $('#addImagebtn').off('click').click(function () { 
      $('#imageAdd').append(
        $('<input>').attr({
          type: 'file',
          name: 'productPics',
          class: 'form-control text-warning',
          accept: 'image/*'
        })
      ); 
    });
  });

  $('#modal').on('show.bs.modal',function(event){
    let button = $(event.relatedTarget);
    $('.categoryText').hide();
    $('.categorySelect').hide();
    $('.subcategoryText').hide();
    $('.subcategorySelect').hide();
    if(!$('#product').hasClass("d-none"))
      $('#product').addClass("d-none");
    $('#imageModify').hide();
    $('#okbtn').hide();
    if(!$('.delete-mode').hasClass("d-none"))
      $('.delete-mode').addClass("d-none");
    $('#dltbtn').hide();
    if(button.data("bs-action") != "delete") {
      $('#okbtn').show();
      if(button.data("bs-set") === "category" && button.data("bs-action") === "add") {
        $('.categoryText').show();
        $('#categoryText').attr('required', 'true');
      }
      else {
        let categorydataObj = button.data("bs-set") === "category" 
          ? { "category": button.data("bs-id") }
          : {};
        $.ajax({
          url: '/components/control.cfc?method=getCategory',
          type: 'GET',
          data:  categorydataObj,
          success: function(data){
            let categoryObj = JSON.parse(data);
            if(button.data("bs-set") === "category") {
              $('.categoryText').show();
              $('#categoryText').val(categoryObj[0].name).attr('required', 'true');
              $('#recordId').val(categoryObj[0].id);
            }
            else {
              $('.categorySelect').show();
              $('#categorySelect').attr('required', 'true').html('<option value=""></option>');
              $.each(categoryObj, function(_, category) {
                $('#categorySelect').append(
                  $('<option>', { value: category.id, text: category.name, selected: category.id == url.get('cat') })
                );
              });
              if(button.data("bs-set") === "subcategory" && button.data("bs-action") === "add") {
                $('.subcategoryText').show();
                $('#subcategoryText').attr('required', 'true');
              }
              else {
                let subcategorydataObj = button.data("bs-set") == "subcategory"
                  ? {
                    "category": url.get('cat'),
                    "subcategory":  button.data("bs-id")
                  }
                  : {
                    "category": url.get('cat')
                  };
                  $.ajax({
                    url: '/components/control.cfc?method=getSubcategory',
                    type: 'GET',
                    data: subcategorydataObj,
                    success: function(data){
                      let subcategoryObj = JSON.parse(data);
                      if (button.data("bs-set") === "subcategory") {
                        $('.subcategoryText').show();
                        $('#subcategoryText').val(subcategoryObj[0].name).attr('required', 'true');
                        $('#recordId').val(subcategoryObj[0].id);
                      }
                      else {
                        $('.subcategorySelect').show();
                        $('#subcategorySelect').attr('required', 'true').html('<option value=""></option>');
                        $.each(subcategoryObj, function(_, category) {
                          $('#subcategorySelect').append(
                            $('<option>', { value: category.id, text: category.name, selected: category.id == url.get('sub') })
                          );
                        });
                        if(button.data("bs-set") === "product" && button.data("bs-action") === "add") {
                          $('#product').removeClass("d-none").find('input','textarea','select').attr('required', 'true');
                        }
                        else {
                          $('#product').removeClass("d-none");
                          $.ajax({
                            url: '/components/control.cfc?method=getProduct',
                            type: 'GET',
                            data: {
                              "subcategory": url.get('sub'),
                              "product":  button.data("bs-id")
                            },
                            success: function(data){
                              let productObj = JSON.parse(data);
                              $('#productName').val(productObj[0].name);
                              $('#productDesc').val(productObj[0].description);
                              $('#price').val(productObj[0].price);
                              $('#tax').val(productObj[0].tax);
                              $('#recordId').val(productObj[0].id);
                              $('#product').find('input','textarea','select').attr('required', 'true');
                              $('#imageModify').show();
                              $.each(productObj[0].images, function(_, value) {
                                $('#imageList').append(
                                  $('<li>').attr({
                                      class: 'col-3 card',
                                      id: `image-${value.id}`,
                                    }).append(
                                      $('<img>').attr({
                                        src: `/uploads/${value.image}`,
                                        class: 'img-thumbnail',
                                        alt: 'viewImage',
                                        'data-bs-theme': 'dark',
                                        width: 100
                                      })
                                    ).append(
                                      $('<button>').attr({
                                        type: 'button',
                                        class: 'btn btn-danger',
                                        onclick: `removeImage(${value.id})`
                                      }).html('Remove')
                                    )
                                );
                              });
                            }
                          });
                        }
                      }
                    }
                  });
              }
            }
          }
        });
      }
      if(button.data("bs-action") == "edit") {
        $('#okbtn').html('Update');
      }
      else if (button.data("bs-action") == "add") {
        $('#okbtn').html('Save');
      }
    }
    else {
      $('.delete-mode').removeClass("d-none");
      $('#dltbtn').show();
      $('#recordId').val(button.data("bs-id"));
      $('#set').val(button.data("bs-set"));
    }
	});
});