module RenderExtension
  extend ActiveSupport::Concern
  include Errors

  included do
    rescue_from ActionController::ParameterMissing do |err|
      render_error err.to_s, "ParameterInvalid", status: 400
    end

    rescue_from ActiveRecord::RecordInvalid do |err|
      Rails.logger.warn "ActiveRecord 错误：#{err.to_s}"
      render_error err.to_s, "RecordInvalid", status: 400
    end

    rescue_from Errors::UnauthorizedToken do |err|
      render_error err.to_s, "Unauthorized", status: 401
    end

    rescue_from Errors::AccessDenied, CanCan::AccessDenied do |err|
      render_error err.to_s, "AccessDenied", status: 403
    end

    rescue_from Errors::PageNotFound, ActiveRecord::RecordNotFound do
      render_error "ResourceNotFound", status: 404
    end
  end

  def render_success(message = "成功", flag = true, *args)
    opts = args.extract_options!
    status = opts[:status] || :ok

    respond_to do |format|
      format.html { render plain: { flag: flag, message: message }, status: status }
      format.json { render json: { flag: flag, message: message }, status: status }
    end
  end

  def render_error(message, error = 10000, *args)
    opts = args.extract_options!
    status = opts[:status] || :unprocessable_entity

    Rails.logger.info "#{Time.now} - ip:<#{request.remote_ip}> http 状态码:<#{status}> 错误:<#{error}> <#{message}>" rescue ''
    respond_to do |format|
      format.html { render plain: { error: error, message: message }, status: status }
      format.json { render json: { error: error, message: message }, status: status }
    end
  end
end
