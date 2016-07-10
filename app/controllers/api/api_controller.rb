class API::APIController < ApplicationController
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Max-Age'] = '1728000'

      render :text => '', :content_type => 'text/plain'
    end
  end

  private
  def render_400(title, detail)
    title ||= "Bad Request"
    error = { status: 400, title: title}
    error[:detail] = detail if detail

    render_error(error, :bad_request)
  end

  def render_401(title, detail)
    title ||= "Unauthorized"
    error = { status: 401, title: title}
    error[:detail] = detail if detail

    render_error(error, :unauthorized)
  end

  def render_403(title, detail)
    title ||= "Access forbidden"
    error = { status: 403, title: title}
    error[:detail] = detail if detail

    render_error(error, :forbidden)
  end

  def render_404(title, detail)
    title ||= "Resource not found"
    error = { status: 404, title: title}
    error[:detail] = detail if detail

    render_error(error, :not_found)
  end

  def render_500(title, detail)
    title ||= "Internal server error"
    error = { status: 500, title: title}
    error[:detail] = detail if detail

    render_error(error, :internal_server_error)
  end

  def render_error(error, status)
    render json: { errors: [error] }, status: status
  end
end
