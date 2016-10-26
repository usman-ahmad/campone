# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('#attachmentPreviewModel').on 'show.bs.modal', (event) ->
    attachement = $(event.relatedTarget) # That triggered the modal

    title = attachement.data('title')
    url = attachement.data('url')
    type = attachement.data('type')

    modal = $(this)
    modal.find('#attachmentTitle').text title

    if(type.match('video.*'))
      modal.find('#videoPreview').attr('src', url).removeClass('hidden')
    else if(type.match('image.*'))
      modal.find('#imagePreview').attr('src', url).removeClass('hidden')
    else
      modal.find('#attachmentNoPreview').removeClass('hidden')

    return

# ---