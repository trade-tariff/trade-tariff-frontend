module PaasConfig
  module_function

  def redis
    url = begin
      # TODO: !Important
      # need to fetch by service name if we use multiple redis services
      JSON.parse(ENV['VCAP_SERVICES'])['redis'][0]['credentials']['uri']
    rescue
      ENV['REDIS_URL']
    end

    { url:, db: 0, id: nil }
  end

  def space
    JSON.parse(ENV['VCAP_APPLICATION'])['space_name']
  rescue
    Rails.env
  end
end
