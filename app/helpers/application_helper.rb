module ApplicationHelper
  def link_to_if_can(action, resource, link_name=nil, options = nil, html_options = nil, &block)
    link_to(link_name, options, html_options, &block) if can? action, resource
  end

  def button_to_if_can(action, resource, button_name = nil, options = nil, html_options = nil, &block)
    button_to(button_name, options, html_options, &block) if can? action, resource
  end

  def resource_div_id(resource)
    "#{resource.model_name.name}_#{resource.id}"
  end
end
