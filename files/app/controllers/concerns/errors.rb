module Errors
  extend ActiveSupport::Concern

  included do
    # 参数值不在允许的范围内
    # HTTP Status 400
    #
    #     { error: 'ParameterInvalid', message: '原因' }
    class ParameterValueNotAllowed < ActionController::ParameterMissing
      attr_reader :values

      def initialize(param, values)
        # :nodoc:
        @param = param
        @values = values
        super("param: #{param} value only allowed in: #{values}")
      end
    end

    # 认证未通过
    # HTTP Status 401
    #
    #     { error: 'Unauthorized', message: '原因'}
    class UnauthorizedToken < StandardError; end

    # 无权限返回信息
    # HTTP Status 403
    #
    #     { error: 'AccessDenied', message: '原因' }
    class AccessDenied < StandardError; end

    # 数据不存在
    # HTTP Status 404
    #
    #     { error: 'ResourceNotFound', message: '原因' }
    class PageNotFound < StandardError; end
  end
end
