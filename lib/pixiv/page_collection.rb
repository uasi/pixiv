module Pixiv
  module PageCollection
    def first?
      next_url.nil?
    end

    def last?
      prev_url.nil?
    end

    private
    def not_implemented!
      name = caller[0][/`([^']*)'/, 1]
      raise NotImplementedError,
            "unimplemented method `#{name}' for #{self}"
    end
    public

    def next_url
      not_implemented!
    end

    def prev_url
      not_implemented!
    end

    def next_attrs
      {}
    end

    def prev_attrs
      {}
    end

    def page_class
      not_implemented!
    end

    def page_hashes
      not_implemented!
    end

    def size
      page_hashes.size
    end
  end

  class PageCollection::Enumerator
    include Enumerable

    def initialize(client, collection, include_deleted_page = false)
      @client = client
      @collection = collection
      @include_deleted_page = include_deleted_page
    end

    def each_page
      each_collection do |collection|
        pages_from_collection(collection).each do |page|
          next if page.nil? && !@include_deleted_page
          yield page
        end
      end
    end

    alias each each_page

    def each_slice(n = nil)
      if n
        super
      else
        if block_given?
          each_collection do |collection|
            yield pages_from_collection(collection)
          end
        else
          ::Enumerator.new {|y|
            each_slice do |slice|
              y << (@include_deleted_page ? slice.compact : slice)
            end
          }
        end
      end
    end

    def each_collection
      collection = @collection
      loop do
        yield collection
        next_url = collection.next_url or break
        next_attrs = collection.next_attrs
        collection = collection.class.lazy_new(next_attrs) { @client.agent.get(next_url) }
      end
    end

    def size
      if @collection.first? && @collection.respond_to?(:total_count)
        @collection.total_count
      elsif @collection.respond_to?(:max_size) && @collection.respond_to?(:total_count)
        @collection.total_count - (@collection.max_size * (@collection.page - 1))
      else
        count { true }
      end
    end

    private

    def pages_from_collection(collection)
      collection.page_hashes.map {|attrs|
        if attrs
          url = attrs.delete(:url)
          collection.page_class.lazy_new(attrs) { @client.agent.get(url) }
        end
      }
    end
  end
end
