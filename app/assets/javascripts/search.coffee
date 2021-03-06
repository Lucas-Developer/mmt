# Before DOM is loaded hide these elements
$(document).ready ->

  $('#search').on 'click', 'button', ->
    # Set search_type to whichever button was pressed
    name = $(this).attr('name')
    form = $(this).parents('form')
    $(form).find('#search_type').val name
    form.submit()

  $('#search').submit ->
    # The full search box might be up when clicking on Search
    # so remove the lightbox
    $('#lightbox').remove()

  # Basic lightbox functionality
  lightbox = (height) ->
    if $('#lightbox').size() == 0
      $('body').append $('<div id="lightbox"/>')
      $('#lightbox').height height
    else
      $('#lightbox').remove()

  # Handle presence of Javascript by turning off or on visibility of JS sensitive objects
  $('.js-disabled-object').css 'visibility': 'hidden'
  $('.js-enabled-object').css 'visibility': 'visible'

  # On search caret click, show search dropdown
  $('#search-drop').on 'click', ->
    if $('.search-dropdown').css('display') == 'none'
      $('.search-dropdown').css 'display': 'block'
      $('#search-drop-caret').css 'transform': 'rotate(180deg)'
      $('#search-submit-button').css 'border-bottom': '1px solid #95a5a6'
    else
      $('.search-dropdown').css 'display': 'none'
      $('#search-drop-caret').css 'transform': 'rotate(0deg)'
      $('#search-submit-button').css 'border-bottom': '1px solid transparent'

  if $('#search-submit-button').length > 0
    recordType = $('input[name="record_type"]:checked').val()
    $searchButtonSpan = $('#search-submit-button-text')

    switch recordType
      when 'variables'
        $searchButtonSpan.text('Search Variables').addClass('variable-text')
      else
        $searchButtonSpan.text('Search Collections').removeClass('variable-text')


  $('#record_type_collections').on 'click', ->
    $("#search-submit-button-text").text('Search Collections').removeClass('variable-text')

  $('#record_type_variables').on 'click', ->
    $("#search-submit-button-text").text('Search Variables').addClass('variable-text')

  # The radio button and text commented out until Services is implemented
  # $('#record_type_services').on 'click', ->
  #   $("#search-submit-button-text").html('<span style="padding-right:18px;">Search Services</span>')

  # Change focus of cursor when search link is clicked on Manage Collections, Manage Variables, or Manage Services pages.
  $('#search-focus').on 'click', ->
    $('#keyword').focus()
    $('#login-info').css 'visibility': 'hidden'
    $('#dropdown-caret').css 'transform': 'rotate(0deg)'

  # If search-box has focus then hide the user menu and flip the caret
  $('#keyword').on 'click', ->
    $('#login-info').css 'visibility': 'hidden'
    $('dropdown-caret').css 'visibility': 'rotate(0deg)'
    $('#keyword').focus()


  $(document).mouseup (e) ->
    container = $('.search-dropdown, .quick-search')
    # if the target of the click isn't the container nor a descendant of the container
    if !container.is(e.target) and container.has(e.target).length == 0
      $('.search-dropdown').css 'display': 'none'
      $('#search-drop-caret').css 'transform': 'rotate(0deg)'
      $('#search-submit-button').css 'border-bottom': '1px solid transparent'
    return
