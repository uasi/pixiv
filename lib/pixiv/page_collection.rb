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

    def initialize(client, collection)
      @client = client
      @collection = collection
    end

    def each_page
      each_collection do |collection|
        pages_from_collection(collection).each do |page|
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
          ::Enumerator.new {|y| each_slice {|slice| y << slice } }
        end
      end
    end

    private

    def pages_from_collection(collection)
      collection.page_hashes.map {|attrs|
        url = attrs.delete(:url)
        collection.page_class.lazy_new(attrs) { @client.agent.get(url) }
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