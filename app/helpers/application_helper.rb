module ApplicationHelper
  require 'digest'

  def hash_string_to_number(string)
    hash = Digest::SHA256.hexdigest(string)
    hash.to_i(16)
  end
end
