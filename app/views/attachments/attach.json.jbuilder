# TODO: Send only newly created attachments in response instead of all attachments.
json.partial! 'attachments/attachment', collection: @attachable.attachments, as: :attachment, project: @project
