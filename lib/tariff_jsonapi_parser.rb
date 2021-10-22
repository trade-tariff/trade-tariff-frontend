class TariffJsonapiParser
  def initialize(attributes)
    @attributes = attributes
  end

  def parse
    return @attributes unless @attributes.is_a?(Hash) && @attributes.key?('data')

    case data
    when Hash
      parse_resource(data)
    when Array
      parse_collection(data)
    else
      data
    end
  end

  def errors
    @attributes['error'] || @attributes['errors']&.map { |error| error['detail'] }&.join(', ')
  end

  class ParsingError < StandardError; end

  private

  def data
    @attributes['data']
  end

  def parse_resource(resource)
    result = {}

    parse_top_level_attributes!(resource, result)

    parse_relationships!(resource['relationships'], result) if resource.key?('relationships')

    result
  end

  def parse_collection(collection)
    collection.map do |resource|
      parse_resource(resource)
    end
  end

  def parse_top_level_attributes!(attributes, parent)
    parent.merge!(attributes['attributes'])
  end

  def parse_relationships!(relationships, parent)
    relationships.each do |name, values|
      parent[name] = case values['data']
                     when Array
                       find_and_parse_multiple_included(name, values['data'])
                     when Hash
                       find_and_parse_included(name, values['data']['id'], values['data']['type'])
                     else
                       values['data']
                     end
    rescue NoMethodError
      raise ParsingError, "Error parsing relationship: #{name}"
    end
  end

  def find_and_parse_multiple_included(name, records)
    records.map do |record|
      find_and_parse_included(name, record['id'], record['type'])
    rescue NoMethodError
      raise ParsingError,
            "Error finding relationship '#{name}': #{record.inspect}"
    end
  end

  def find_and_parse_included(name, id, type)
    record = find_included(id, type)
    parse_record(record)
  rescue NoMethodError
    raise ParsingError,
          "Error finding relationship - '#{name}', '#{id}', '#{type}': #{record.inspect}"
  end

  def parse_record(record)
    record_attrs = record['attributes'].clone || {}
    if record.key?('relationships')
      parse_relationships!(record['relationships'], record_attrs)
    end
    record_attrs
  end

  def find_included(id, type)
    @attributes['included']&.find { |r| r['id'].to_s == id.to_s && r['type'].to_s == type.to_s } || {}
  end
end
