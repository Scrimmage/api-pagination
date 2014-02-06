module Grape
  module Pagination
    def self.included(base)
      Grape::Endpoint.class_eval do
        def paginate(collection)
          block = Proc.new do |collection|
            links = (header['Link'] || "").split(',').map(&:strip)
            url = stripped_request_url
            pages = ApiPagination.pages_from(collection)

            pages.each do |k, v|
              new_params = old_params.merge('page' => v)
              links << %(<#{url}?#{new_params.to_param}>; rel="#{k}")
            end

            header 'Link', links.join(', ') unless links.empty?
            header 'Total', ApiPagination.total_from(collection)
          end

          ApiPagination.paginate(collection, params, &block)
        end

        def paginate_timeline(collection)
          block = Proc.new do |collection|
            links = (header['Link'] || "").split(',').map(&:strip)
            url = stripped_request_url
            max_id = collection.last.id - 1

            new_params = old_params.merge('max_id' => max_id)
            links << %(<#{url}?#{new_params.to_param}>; rel="next")

            header 'Link', links.join(', ') unless links.empty?
          end

          ApiPagination.paginate_timeline(collection, params, &block)
        end

        private

        def old_params
          Rack::Utils.parse_query(request.query_string)
        end

        def stripped_request_url
          request.url.sub(/\?.*$/, '')
        end
      end

      base.class_eval do
        def self.paginate(options = {})
          options.reverse_merge!(:per_page => 10)
          params do
            optional :page,     :type => Integer, :default => 1,
                                :desc => 'Page of results to fetch.'
            optional :per_page, :type => Integer, :default => options[:per_page],
                                :desc => 'Number of results to return per page.'
          end
        end

        def self.paginate_timeline(options = {})
          options.reverse_merge!(:count => 10)
          params do
            optional :count, :type => Integer, :default => options[:count],
                                :desc => 'Number of results to return per request.'
            optional :max_id,     :type => Integer, :default => 1,
                                :desc => 'Maximum id to fetch.'
            optional :since_id,     :type => Integer, :default => 1,
                                :desc => 'Minimum id to fetch.'
          end
        end
      end
    end
  end
end
