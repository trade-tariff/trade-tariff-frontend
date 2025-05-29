class FakeUkttHttp
  def initialize(_connection, service, _version, _format)
    @service = service
  end

  def self.build(host, version, format); end

  def retrieve(resource, _query_config = {})
    json = read(resource)

    JSON.parse(json)
  end

  def config
    {}
  end

  private

  def read(fixture)
    fixture_path = Rails.root.join("spec/fixtures/#{@service}").to_s
    path = File.join(fixture_path, fixture)

    File.read(path)
  end
end
