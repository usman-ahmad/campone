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
    modal.find('#downloadAttachmentBtn').attr('href', url)

    modal.find('.modal-body').children().hide();

    if(type.match('video.*'))
      modal.find('#attachmentVideo').attr('src', url)
      modal.find('#videoPreview').show()
    else if(type.match('image.*'))
      modal.find('#attachmentImage').attr('src', url)
      modal.find('#imagePreview').show()
    else
      modal.find('#attachmentNoPreview').show()

    return

# ---