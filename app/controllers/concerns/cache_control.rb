module CacheControl
  extend ActiveSupport::Concern

  private

  def set_cache
    response.headers['Cache-Control'] = 'public, must-revalidate, proxy-revalidate, max-age=0'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '-1'
  end
end
