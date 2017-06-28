$(document).ready ->
  $('.umm-form').on 'click', '.add-another', (e) ->
    multiple = $(this).closest('.multitext')
    multipleItem = multiple.children('.multiple-item:last')

    newDiv = multipleItem.clone(true)

    timeStamp = Date.now()

    $.each $(newDiv).find('select, input, textarea'), (index, field) ->
      $(field).val ''
      id = $(field).attr('id').replace(/[\_\d]+$/, "_#{timeStamp}")
      $(field).attr('id', id)

      name = $(field).attr('name').replace(/\[[\d]+\]$/, "[#{timeStamp}]")
      $(field).attr('name', name)

    $(newDiv).insertAfter multipleItem
