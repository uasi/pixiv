module Pixiv
  class Page
    # A new Page
    # @param [Hash{Symbol=>Object}] attrs
    # @yieldreturn [Nokogiri::HTML::Document]
    def self.lazy_new(attrs = {}, &doc_creator)
      self.new(doc_creator, attrs)
    end

    # @overload initialize(doc, attrs = {})
    #   @param [Nokogiri::HTTP::Document] doc
    #   @param [Hash{Symbol=>Object}] attrs
    # @overload initialize(doc_creator, attrs = {})
    #   @param [#call] doc_creator
    #   @param [Hash{Symbol=>Object}] attrs
    def initialize(doc_or_doc_creator, attrs = {})
      x = doc_or_doc_creator
      if x.respond_to?(:call)
        @doc_creator = x
      else
        @doc = x
      end
      set_attrs!(attrs)
    end

    # Whether +attr_name+ is fetched or not
    # @param [String, Symbol] attr_name
    # @return [Boolean]
    def fetched?(attr_name = :doc)
      instance_variable_get(:"@#{attr_name}") != nil
    end

    # @return [Nokogiri::HTTP::Document]
    def doc
      @doc ||= begin
                 doc = @doc_creator.call
                 @doc_creator = nil
                 doc
               end
    end

    # Fetch +#doc+ and lazy attrs
    # @return [self]
    def force
      doc
      (@@lazy_attr_readers || []).each do |reader|
        __send__(reader) if respond_to?(reader)
      end
      self
    end

    protected

    # Defines lazy attribute reader
    # @!macro attach lazy_attr_reader
    #   @!attribute [r] $1
    #   Lazily returns $1
    def self.lazy_attr_reader(name, &reader)
      ivar = :"@#{name.to_s.sub(/\?$/, '_q_')}"
      (@@lazy_attr_readers ||= []) << ivar
      define_method(name) do
        if instance_variable_defined?(ivar)
          instance_variable_get(ivar)
        else
          instance_variable_set(ivar, instance_eval(&reader))
        end
      end
    end

    # Set attribute values
    #
    # @param [Hash{Symbol=>Object}] attrs
    #
    # If +#set_attr!+ sets a value to an attribute,
    # the lazy attr of the same name gets to return that value
    # so its block will never called.
    def set_attrs!(attrs)
      attrs.each do |name, value|
        ivar = :"@#{name.to_s.sub(/\?$/, '_q_')}"
        instance_variable_set(ivar, value)
      end
    end

    # +node.at(path)+ or raise error
    # @param [String] path XPath or CSS path
    # @return [Nokogiri::HTML::Node]
    def at!(path, node = doc)
      node.at(path) || Error::NodeNotFound.new("node for `#{path}` not found").raise
    end

    # +node.search(path) or raise error
    # @param [String] path XPath or CSS path
    # @return [Array<Nokogiri::HTML::Node>]
    def search!(path, node = doc)
      node.search(path) || Error::NodeNotFound.new("node for `#{path}` not found").raise
    end
  end
end
