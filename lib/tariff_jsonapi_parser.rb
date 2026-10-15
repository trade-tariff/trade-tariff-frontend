class TariffJsonapiParser
  def initialize(attributes)
    @attributes = attributes
    @cycle_count = 0
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
    key = [resource['type'].to_s, resource['id'].to_s]
    resolving << key
    result = {}

    parse_type!(resource, result)
    parse_id!(resource, result)
    parse_attributes!(resource, result) if resource.key?('attributes')
    parse_relationships!(resource['relationships'], result) if resource.key?('relationships')
    parse_meta!(resource, result) if resource.key?('meta')

    result
  ensure
    resolving.pop if key
  end

  def parse_collection(collection)
    collection.map do |resource|
      parse_resource(resource)
    end
  end

  def parse_type!(resource, parent)
    parent.merge!('resource_type' => resource['type'])
  end

  def parse_id!(resource, parent)
    parent.merge!('resource_id' => resource['id'])
  end

  def parse_attributes!(resource, parent)
    parent.merge!(resource['attributes'])
  end

  def parse_relationships!(relationships, parent)
    relationships.each do |name, values|
      parent[name] = case values['data']
                     when Array
                       find_and_parse_multiple_included(name, values['data'])
                     when Hash
                       find_and_parse_included(name, values.dig('data', 'id'), values.dig('data', 'type'))
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
    return nil if id.blank? || type.blank?

    key = [type.to_s, id.to_s]
    if resolving.include?(key)
      @cycle_count += 1
      return {}
    end
    return parsed_included_cache[key] if parsed_included_cache.key?(key)

    cycles_before = @cycle_count
    found_resource = find_included(id, type)
    result = found_resource.blank? ? {} : parse_resource(found_resource)

    # A cycle-truncated subtree depends on the current path, so do not reuse it.
    parsed_included_cache[key] = result if @cycle_count == cycles_before
    result
  rescue NoMethodError
    raise ParsingError,
          "Error finding relationship - '#{name}', '#{id}', '#{type}'"
  end

  def resolving
    @resolving ||= []
  end

  def parsed_included_cache
    @parsed_included_cache ||= {}
  end

  def parse_meta!(resource, parent)
    parent['meta'] = resource['meta']
  end

  def find_included(id, type)
    linked_resource_index[[type.to_s, id.to_s]] || {}
  end

  # The backend can serve a linked resource either as primary data or as an
  # included entry without duplicating identities across both. Resolve linkage
  # against both, keeping the existing precedence for included entries.
  def linked_resource_index
    @linked_resource_index ||= (primary_resources + Array(@attributes['included'])).index_by do |resource|
      [resource['type'].to_s, resource['id'].to_s]
    end
  end

  def primary_resources
    data = @attributes['data']
    case data
    when Hash then [data]
    when Array then data
    else []
    end.compact
  end
end
