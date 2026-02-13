class Myott::StopPressPreferenceForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  SELECT_CHAPTERS = 'selectChapters'.freeze
  ALL_CHAPTERS = 'allChapters'.freeze

  attribute :preference, :string

  validates :preference, presence: { message: 'Select a subscription preference to continue' },
                         inclusion: { in: [SELECT_CHAPTERS, ALL_CHAPTERS], message: 'Select a subscription preference to continue' }

  def select_chapters?
    valid? && preference == SELECT_CHAPTERS
  end

  def all_chapters?
    valid? && preference == ALL_CHAPTERS
  end
end
