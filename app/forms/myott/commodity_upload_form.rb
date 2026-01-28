module Myott
  class CommodityUploadForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :file

    validates :file, presence: { message: 'Select a file in a CSV or XLSX format' }
    validate :validate_file_type

    private

    def validate_file_type
      return if file.blank?

      unless file.respond_to?(:content_type)
        errors.add(:file, 'is invalid')
        return
      end

      allowed_types = [
        'text/csv',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ]

      unless allowed_types.include?(file.content_type)
        errors.add(:file, 'Selected file must be in a CSV or XLSX format')
      end
    end
  end
end
