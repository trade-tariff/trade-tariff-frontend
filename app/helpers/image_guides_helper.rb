module ImageGuidesHelper
  def image_for_guide(guide_name, **kwargs)
    guide_filename = guide_name.downcase

    image_pack_tag "guides/#{guide_filename}", **kwargs.merge(class: 'image-guide')
  rescue Webpacker::Manifest::MissingEntryError
    nil
  end
end
