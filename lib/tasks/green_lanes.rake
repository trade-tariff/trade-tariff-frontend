require 'csv'

namespace :green_lanes do
  desc 'Find out the categories of a list of goods.'

  task :determine_categories, [:filename] => :environment do |_, args|
    filename = args[:filename]

    if filename.nil?
      puts 'Usage: bundle exec rake green_lanes:determine_categories[filename]'
      puts 'filename is the path to a CSV file with a list of goods.'
      puts 'Important notes:'
      puts '- The CSV file must have a header row.'
      puts '- The first column of the CSV file must be the commodity code.'
      puts '- The other columns of the CSV file will be ignored.'
      exit
    end

    puts 'GoodsNomenclature, Categories'

    CSV.foreach(filename, headers: true) do |row|
      commodity_code = row[0]

      goods_nomenclature = GreenLanes::GoodsNomenclature.find(commodity_code)
      cat = GreenLanes::DetermineCategory.new(goods_nomenclature).categories

      puts "#{commodity_code}, #{cat}"
    end
  end
end
