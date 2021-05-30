# ---
# Author: Matthew Might
# Translator: John Myles White
# Site:   http://matt.might.net/articles/implementation-of-rsa-public-key-cryptography-algorithm-in-scheme-dialect-of-lisp/
# ---

# ---
# Mathematical routines
# ---

# extended_gcd(a, b) -> (x, y) such that ax + by = gcd(a, b)
function extended_gcd(a::T, b::T) where {T <: Integer}
    if mod(a, b) == zero(T)
      return [zero(T), one(1)]
    else
      x, y = extended_gcd(b, mod(a, b))
      return [y, x - (y * fld(a, b))]
    end
  end

  # modulo_inverse(a, n) -> b such that a * b = 1 [mod n]
  function modulo_inverse(a::Integer, n::Integer)
    mod(first(extended_gcd(a, n)), n)
  end

  # totient(n) -> (p - 1) * (q - 1) such that pq is the prime factorization of n
  totient(p::T, q::T) where {T <: Integer} = (p - one(T)) * (q - one(T))

  # square(x) = x^2
  square(x::Integer) = x * x

  # modulo_power(base, exp, n) -> base^exp [mod n]
  function modulo_power(base::T, exp::T, n::T) where {T <: Integer}
    if exp == zero(T)
      one(T)
    else
      if isodd(exp)
        mod(base * modulo_power(base, exp - one(T), n), n)
      else
        mod(square(modulo_power(base, fld(exp, oftype(exp, 2)), n)), n)
      end
    end
  end

  # ---
  # RSA routines
  # ---

  # A legal public exponent e is between
  #  1 and totient(n), and gcd(e, totient(n)) = 1
  function is_legal_public_exponent(e::T, p::T, q::T) where {T <: Integer}
    return one(T) < e && e < totient(p, q) && one(T) == gcd(e, totient(p, q))
  end

  # The private exponent is the inverse of the public exponent [mod n]
  function private_exponent(e::T, p::T, q::T) where {T <: Integer}
    if is_legal_public_exponent(e, p, q)
      return modulo_inverse(e, totient(p, q))
    else
      error("Not a legal public exponent for that modulus")
    end
  end

  # An encrypted message is c = m^e [mod n]
  function encrypt(m::T, e::T, n::T) where {T <: Integer}
    if m > n
      error("The modulus is too small to encrypt the message")
    else
      modulo_power(m, e, n)
    end
  end

  # A decrypted message is m = c^d [mod n]
  function decrypt(c::T, d::T, n::T) where {T <: Integer}
    return modulo_power(c, d, n)
  end

  # ---
  # RSA example
  # ---

  p = BigInt(41) # A "large" prime
  q = BigInt(47) # Another "large" prime
  n = p * q      # The public modulus

  e = BigInt(7)                 # The public exponent
  d = private_exponent(e, p ,q) # The private exponent

  plaintext = BigInt(42)
  ciphertext = encrypt(plaintext, e, n)

  decrypted_ciphertext = decrypt(ciphertext, d, n)

  println("The plaintext is:            %s\n", plaintext)

  println("The ciphertext is:           %s\n", ciphertext)

  println("The decrypted ciphertext is: %s\n", decrypted_ciphertext)

  if plaintext != decrypted_ciphertext
    error("RSA fail!")
  end