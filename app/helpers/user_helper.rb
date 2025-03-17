module UserHelper
  def random_key(length = 40)
    chars = [('a'..'z'), ('A'..'Z'), ('0'..'9')].flat_map(&:to_a)
    random_chars = Array.new(length) { chars.sample }.join
    return random_chars
  end

  def encrypt(original_password)
    return original_password
  end

  def decrypt(password)
    return password
  end
end