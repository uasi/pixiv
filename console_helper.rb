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

  $pixiv = Pixiv.client(id, password) do |agent|
    agent.user_agent_alias = 'Mac Safari'
    agent.set_proxy(*proxy) if proxy
  end

  Kernel.const_set(:P, $pixiv)
  Kernel.const_set(:M, $pixiv.member)
  Kernel.const_set(:IL, $pixiv.illust_list)
  Kernel.const_set(:BL, $pixiv.bookmark_list)
  Kernel.const_set(:PBL, $pixiv.private_bookmark_list)
  Kernel.const_set(:Is, $pixiv.illusts($pixiv.member))
  Kernel.const_set(:Bs, $pixiv.bookmarks($pixiv.member))
  Kernel.const_set(:PBs, $pixiv.private_bookmarks)
end

def I(id)
  $pixiv.illust(id)
end

def M(id)
  $pixiv.member(id)
end

def IL(member, p = 1)
  $pixiv.illust_list(member, p)
end

def BL(member, p = 1)
  $pixiv.bookmark_list(member, p)
end

def PBL(p = 1)
  $pixiv.private_bookmark_list($pixiv.member_id, p)
end

def Is(list_or_member)
  $pixiv.illusts(list_or_member)
end

def Bs(list_or_member)
  $pixiv.bookmarks(list_or_member)
end
