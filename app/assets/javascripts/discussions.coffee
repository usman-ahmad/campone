# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  if $('#discussion_private').prop('checked')
  then $('#private-discussions').show()
  else $('#private-discussions').hide()

  $('#discussion_private').change ->
    if this.checked
      $('#private-discussions').show()
      $('.delete-user-from-discussion').prop('checked', true)
      $('.include-user-or-not').prop('checked', false)
    else
      $('#private-discussions').hide()
      $('.delete-user-from-discussion').prop('checked', false)
      $('.include-user-or-not').prop('checked', true)

  $('.include-user-or-not').change ->
    if this.checked
      $(this).siblings('.delete-user-from-discussion').prop('checked', false)
    else
      $(this).siblings('.delete-user-from-discussion').prop('checked', true)

  $(".date_picker").datepicker({
    dateFormat: "yy-mm-dd"
  });

  $('.contributors-tooltip').tooltip
    html: true
    placement: 'bottom'
    title: $('.contributors-list').html()
