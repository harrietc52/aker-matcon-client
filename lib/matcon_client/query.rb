## MatconClient::Query
# A class for generating query strings for APIs built with Eve (http://python-eve.org)
#
# See http://python-eve.org/features.html#filtering for examples of query strings
#
# Uses builder pattern for specifying multiple parameters and allowing chaining
# Examples:
#
#   @query = MatconClient::Query.new
#
#   @query.page(2)
#         .order(city: :asc, name: :desc)
#         .where(lastname: "Doe")
#         .embed(author: 1)
#
#   @query.to_s
#   # => "page=2&sort=city,-name&where={\"lastname\": \"Doe\"}&embeddable={\"author\": 1}"

module MatconClient
  class Query

    include Enumerable

    attr_reader :params, :klass

    def initialize(options)
      @klass  = options.fetch(:klass)
      @params = initial_params
    end

    def each(&block)
      result_set.each do |result|
        block.call(result)
      end
    end

    # Executes the built query. Will return a ModelClient::ResultSet
    def result_set
      klass.requestor.get(nil, { query: to_s })
    end

    # Resets all params to nil
    def reset
      @params = initial_params
      self
    end

    # arg page_number is an Integer
    # Sets the page parameter
    # Returns self
    def page(page_number)
      params[:page] = page_number
      self
    end

    # arg max_results is an Integer
    # Sets the max_results param
    # Returns self
    def limit(max_results)
      params[:max_results] = max_results
      self
    end

    # arg order could be a Hash or a String
    # If Hash then key must be the field, and value must be :asc or :desc
    # If String then fields must be comma separated. Fields you wish to sort descending
    # should be preceeded with a minus (-)
    #
    # Sets the sort parameter
    # Returns self
    def order(order)
      params[:sort] = if order.is_a?(Hash) then
                        order.reduce([]) do |memo, obj|
                          key, value = obj

                          if (value.to_s != "asc" && value.to_s != "desc") then
                            raise ArgumentError, "Order must be either :asc or :desc"
                          end

                          key = "-#{key}" if value.to_s == "desc"
                          memo.push(key)
                        end.join(",")
                      elsif order.is_a?(String) then
                        order
                      end

      self
    end

    # arg where_params must be a Hash (can be nested)
    # Sets the where parameter
    # Returns self
    def where(where_params)
      @params[:where] = format_hash(where_params)
      self
    end

    # arg project_params is a Hash or a String
    # If Hash, keys should be field, and values should be 1 or 0 (or true or false)
    # If String, must be comma-separated fields that will be included in projection
    # Sets the projection parameter
    # Returns self
    def projection(project_params)
      @params[:projection] = convert_to_bool_valued_hash(project_params)
      self
    end
    alias_method :select, :projection

    # arg embed_params is a Hash or a String
    # If Hash, keys should be field, and values should be 1 or 0 (or true or false)
    # If String, must be comma-separated fields that will be included in embeddable
    # Sets the embeddable parameter
    # Returns self
    def embed(embed_params)
      @params[:embeddable] = convert_to_bool_valued_hash(embed_params)
      self
    end
    alias_method :include, :embed

    # Creates a String from parameters (where they're present) joining them each by an ampersand (&)
    def to_s
      params.reduce([]) do |memo, obj|
        key, value = obj
        memo.push("#{key}=#{value}") if value.present?
        memo
      end.join('&')
    end

  private

    def initial_params
      {
        page: nil,
        max_results: nil,
        sort: nil,
        where: nil,
        projection: nil,
        embeddable: nil
      }
    end

    # Takes in a String and calls convert_to_truthy_hash
    # or takes in a Hash and calls convert_values_to_int
    # Returns a formatted hash
    def convert_to_bool_valued_hash(params)
      params = if (params.is_a?(String)) then
                 convert_to_truthy_hash(params)
               else
                 convert_values_to_int(params)
               end

      format_hash(params)
    end

    # Takes a String and returns a Hash with 1 as the values
    # The String will be split on comma and each part will be a Hash key
    # Example:
    #
    # convert_to_truthy_hash('monkey,giraffe,banana')
    # #  => { monkey: 1, giraffe: 1, banana: 1}
    def convert_to_truthy_hash(str)
      str.gsub(' ', '').split(',').reduce({}) do |memo, value|
        memo[value] = 1
        memo
      end
    end

    # Turns a hash into a string with all keys being Strings and all
    # '=>'' being turned to ': '
    def format_hash(hash)
      return hash.to_json
    end

    # Takes in a Hash and converts all its values to either 1 of 0
    # If value is already 1 or 0 uses that as the value
    # If value is an Integer other than 1 or 0 raises an ArgumentError
    # If value is a String then value is 1
    # If value is an empty String then value is 0
    #
    # Example:
    #
    # convert_values_to_int(firstname: 1, lastname: "myers", address: false)
    # # => {"firstname": 1, "lastname": 1, "address": 0}
    def convert_values_to_int(hash)
      hash.reduce({}) do |memo, obj|
        key, value = obj

        if (value.is_a?(Integer)) then
          raise ArgumentError, "Value must be 1 or 0" if value != 1 && value != 0
          memo[key] = value
        else
          memo[key] = value ? 1 : 0
        end

        memo
      end
    end

  end
end