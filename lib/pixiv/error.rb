module Pixiv
  class Error < StandardError; end
  class Error::LoginFailed < Error; end
  class Error::NodeNotFound < Error; end
end

