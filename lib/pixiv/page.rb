module Pixiv
  class Page
    def self.lazy_new(attrs = {}, &doc_creator)
      self.new(doc_creator, attrs)
    end

    def initialize(doc_or_doc_creator, attrs = {})
      x = doc_or_doc_creator
      if x.respond_to?(:call)
        @doc_creator = x
      else
        @doc = x
      end
      set_attrs!(attrs)
    end

    def doc
      @doc ||= begin
                 doc = @doc_creator.call
                 @doc_creator = nil
                 doc
               end
    end

    def force
      doc
      (@@lazy_attr_readers || []).each do |reader|
        __send__(reader) if respond_to?(reader)
      end
      self
    end

    protected

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

    def set_attrs!(attrs)
      attrs.each do |name, value|
        ivar = :"@#{name.to_s.sub(/\?$/, '_q_')}"
        instance_variable_set(ivar, value)
      end
    end

    def at!(path, node = doc)
      node.at(path) || Error::NodeNotFound.new("node for `#{path}` not found").raise
    end

    def search!(path, node = doc)
      node.search(path) || Error::NodeNotFound.new("node for `#{path}` not found").raise
    end
  end
end
