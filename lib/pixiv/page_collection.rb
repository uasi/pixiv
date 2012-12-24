module Pixiv
  module PageCollection
    def first?
      raise NotImplementError
    end

    def last?
      raise NotImplementError
    end

    def next_url
      raise NotImplementError
    end

    def prev_url
      raise NotImplementError
    end

    def page_class
      raise NotImplementError
    end

    def page_urls
      raise NotImplementError
    end

    def page_hash
      page_urls.map {|url| {url: url} }
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

    private

    def pages_from_collection(collection)
      collection.page_hashes.map {|attrs|
        if attrs
          url = attrs.delete(:url)
          collection.page_class.lazy_new(attrs) { @client.agent.get(url) }
        end
      }
    end

    def each_collection(collection = @collection)
      loop do
        yield collection
        break unless collection.next_url
        collection = collection.class.new(@client.agent.get(collection.next_url))
      end
    end
  end
end
