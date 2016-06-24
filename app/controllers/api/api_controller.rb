class API::APIController < ApplicationController
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
