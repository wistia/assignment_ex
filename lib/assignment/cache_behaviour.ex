defmodule Assignment.CacheBehaviour do
  @type input :: any()
  @type key :: any()
  @type value :: any()
  @type key_fun :: (input -> key)
  @type cache :: any()

  @callback new(key_fun) :: cache
  @callback put(cache, input, value) :: cache
  @callback cached?(cache, input) :: true | false
  @callback value(cache, input) :: value
end
