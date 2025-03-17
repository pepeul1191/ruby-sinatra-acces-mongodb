module UserHelper
  def random_key(length = 40)
    chars = [('a'..'z'), ('A'..'Z'), ('0'..'9')].flat_map(&:to_a)
    random_chars = Array.new(length) { chars.sample }.join
    return random_chars
  end

  def send_activation_email(email, activation_key)
    puts('Correo: ' + email + ', Activación: ' + activation_key)
  end

  def send_reset_email(email, reset_key)
    puts('Correo: ' + email + ', Reseto: ' + reset_key)
  end

  def encrypt(original_password)
    return original_password
  end

  def decrypt(password)
    return password
  end
end