def init
  id = ENV['PIXIV_ID'] or warn 'PIXIV_ID is not set'
  password = ENV['PIXIV_PASSWORD'] or warn 'PIXIV_PASSWORD is not set'
  abort unless id && password

  proxy =
    begin
      if ENV['HTTP_PROXY']
        host, port = ENV['HTTP_PROXY'].split(/:/)
        [host, (port || 80).to_i]
      else
        nil
      end
    end

  require 'bundler/setup'
  Bundler.require

  $pixiv = Pixiv.new(id, password) do |agent|
    agent.user_agent_alias = 'Mac Safari'
    agent.set_proxy(*proxy) if proxy
  end

  Kernel.const_set(:P, $pixiv)
  Kernel.const_set(:M, $pixiv.member)
end

def I(id)
  $pixiv.illust(id)
end

def M(id)
  $pixiv.member(id)
end

def BL(member_id, p = 1)
  $pixiv.bookmark_list(member_id, p)
end
