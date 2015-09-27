module ViewModel
  class Base
    extend Forwardable

    DEFAULT_AVAILABLE_PARAMS = [:format, :layout]


    attr_accessor :delegate
    def_delegator :render, :delegate

    def self.declared_params(*declared_param_keys)
      declared_param_keys.unshift(DEFAULT_AVAILABLE_PARAMS)
      self.class_variable_set(:@@declared_param_keys, declared_param_keys)
    end

    def initialize(delegate, params={})
      self.delegate = delegate
      @original_params = params
    end

    def call(other_render_params = {})
      render_params = {template: template_path,
                       formats: [format],
                       status: status,
                       locals: view_params.merge(_: self, params: view_params)}
      render_params.merge!({layout: layout}) unless layout == :no_layout_specified
      render render_params.merge(other_render_params)
    end

    def view_params
      {}
    end

    def params
      filtered_params
    end


    protected

    def format
      @original_params.fetch(:format, :html)
    end

    def layout
      :no_layout_specified
    end

    def status
      :ok
    end

    def template_path
      self.class.name.underscore
    end


    private

    def filtered_params
      @filtered_params ||= @original_params.keep_if { |k, _| self.class.class_variable_get(:@@declared_param_keys).include? k }
    end

  end
end
