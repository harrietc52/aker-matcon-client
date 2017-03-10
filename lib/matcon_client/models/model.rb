require 'json'

module MatconClient
  class Model

    class_attribute :site,
                    :connection_class,
                    :connection_object,
                    :connection_options,
                    :endpoint,
                    :response_handler,
                    :requestor,
                    :query_object

    self.connection_class     = Connection
    self.connection_options   = { :headers => { "Content-Type" => "application/json", "Accept" => "application/json" } }

    attr_reader :attributes

    alias_attribute :id, :_id

    def initialize(attributes = {})
      update_attributes(attributes)
    end

    def attributes
      @attributes ||= ActiveSupport::HashWithIndifferentAccess.new
    end

    def to_json
      attributes.reject {|attr| attr[0] == '_' && attr != '_id' }.to_json
    end

    def persisted?
      has_attribute?(:_id) && @attributes[:_id].present?
    end

    def save
      if has_attribute?(:_id)
        requestor.put(@attributes[:_id], @attributes)
      else
        model = requestor.post(nil, @attributes)
        update_attributes(model.attributes)
      end
    end

    def destroy
      requestor.delete(@attributes[:_id])
      freeze
    end

    def ==(other)
        return self.id == other.id && self.class.to_s == other.class.to_s
    end

    class << self

      extend Forwardable
      def_delegators :query_object, :page, :limit, :order, :where, :projection, :embed

      def find(id)
        requestor.get(id)
      end

      def create(attrs)
        requestor.post(nil, attrs)
      end

      def destroy(id)
        requestor.delete(id)
      end

      def all
        requestor.get
      end

      def from_json(json)
        attributes = JSON.parse(json)
        new(attributes)
      end

      def connection(rebuild = false, &block)
        _build_connection(rebuild, &block)
        @connection_object
      end

      def response_handler(rebuild = false)
        _build_response_handler(rebuild)
        @response_handler
      end

      def requestor(rebuild = false)
        _build_requester(rebuild)
        @requestor
      end

      def query_object
        @query_object ||= MatconClient::Query.new(klass: self)
      end

      protected

      def _build_connection(rebuild = false)
        return @connection_object unless @connection_object.nil? || rebuild
        @connection_object = connection_class.new(connection_options.merge(site: site)).tap do |conn|
          yield(conn) if block_given?
        end
      end

      def _build_response_handler(rebuild = false)
        return @response_handler unless @response_handler.nil? || rebuild
        @response_handler = MatconClient::ResponseHandlerFactory.new(model: self)
      end

      def _build_requester(rebuild = false)
        return @requestor unless @requestor.nil? || rebuild
        @requestor = MatconClient::Requestor.new(klass: self)
      end

    end

    private

    def update_attributes(attrs)
      return @attributes unless attrs.present?

      attrs.each do |key, value|
        send("#{key}=", value)
      end
    end

    def method_missing(method, *args, &block)
      normalized_method = method.to_s

      # If it contains an equals after some letter(s)...
      if normalized_method =~ /^(.*)=$/
        set_attribute($1, args.first)

      elsif has_attribute?(normalized_method)
        attributes[method]
      else
        super
      end

    end

    def set_attribute(name, value)
      attributes[name] = value
    end

    def has_attribute?(attribute)
      attributes.has_key?(attribute)
    end

  end
end