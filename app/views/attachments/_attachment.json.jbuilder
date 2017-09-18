json.title attachment.document_file_name
json.url attachment.document.url
json.type attachment.document_content_type
json.thumb attachment.document.url(:thumb)
json.attachment_path project_attachment_path(project, attachment)
json.download_attachment_path download_project_attachment_path(project, attachment)