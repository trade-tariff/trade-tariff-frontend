# As best as I can tell there is a Rails bug - it calculates size of the
# encrypted cookie jar pre-encoding, and without cookie name + flags
#
# Both firefox and chrome are rejecting cookies in the ~4000 bytes range as
# as being over 4096 which I think is an artifact of encrypted cookies having
# lots of slashes, and each gets encode as %2F taking up more bytes then are
# included in Rails' calculation

ActionDispatch::Cookies.class_eval do
  remove_const 'MAX_COOKIE_SIZE' if const_defined?('MAX_COOKIE_SIZE')
  const_set 'MAX_COOKIE_SIZE', 3850
end
