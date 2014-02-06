require 'support/numbers_controller'
require 'support/numbers_api'
require 'api-pagination'

# Quacks like Kaminari and will_paginate
PaginatedSet = Struct.new(:current_page, :per_page, :total_count) do
  def total_pages
    total_count.zero? ? 1 : (total_count.to_f / per_page).ceil
  end

  def first_page?() current_page == 1 end
  def last_page?() current_page == total_pages end

  def page(page)
    current_page = page
    self
  end

  def per(per)
    per_page = per
    self
  end

  def paginate(options = {})
    page(options[:page]).per(options[:per_page])
  end

  alias :total_entries :total_count
end

class NumberTimeline
  @@id = rand(1000)

  def id
    @@id
  end

  def max_id(max_value)
    self
  end

  def since_id(min_value)
    self
  end

  def limit(limit)
    self
  end

  def last
    self
  end
end

if ENV['PAGINATOR']
  ApiPagination.instance_variable_set(:@paginator, ENV['PAGINATOR'].to_sym)
else
  warn 'No PAGINATOR set. Defaulting to kaminari. To test against will_paginate, run `PAGINATOR=will_paginate bundle exec rspec`'
  ApiPagination.instance_variable_set(:@paginator, :kaminari)
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include ControllerExampleGroup, :type => :controller

  # Disable the 'should' syntax.
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  def app
    NumbersAPI
  end
end
