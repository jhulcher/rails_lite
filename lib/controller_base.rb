require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @route_params = route_params
    @already_built_response = false
    @session = nil
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "double render error" if already_built_response?

    @res.status = 302
    @res["Location"] = url

    @session.store_session(@res)

    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "double render error" if already_built_response?

    @res.write(content)
    @res["Content-Type"] = content_type

    @session.store_session(@res)

    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    raise "double render error" if already_built_response?

    class_name = self.class.to_s.underscore.downcase
    path = "views/#{class_name}/#{template_name}.html.erb"

    File.open("#{path}", "r") do |text|
      html_lines = []

      text.each_line do |line|
        html_lines << line
      end

      string = html_lines.join("\n")

      content = ERB.new(string).result(binding)
      render_content(content, "text/html")
    end

    @already_built_response = true
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end

end
















#
