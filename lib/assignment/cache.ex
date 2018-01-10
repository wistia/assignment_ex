defmodule Assignment.Cache do
  @behaviour Assignment.CacheBehaviour

  @type t :: %Assignment.Cache{key_fun: (any -> any), data: %{any => Assignment.Result.destination}}
  defstruct [:key_fun, :data]

  @doc """
  Returns a new cache with the given `key_fun`
  """
  def new(key_fun) do
    %__MODULE__{key_fun: key_fun, data: %{}}
  end

  @doc """
  Extracts a key from `input` and adds `value` to `cache` under that key
  """
  def put(cache, input, value) do
    key = cache.key_fun.(input)
    put_in(cache.data[key], value)
  end

  @doc """
  Extracts a key from `input` and returns whether or not `cache` has a value under that key
  """
  def cached?(cache, input) do
    key = cache.key_fun.(input)
    Map.has_key?(cache.data, key)
  end

  @doc """
  Extracts a key from `input` and returns the value associated with that key in `cache`
  """
  def value(cache, input) do
    key = cache.key_fun.(input)
    cache.data[key]
  end

  @doc false
  def identity(v), do: v
end
