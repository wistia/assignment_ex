defmodule Assignment.Cache do
  @type t :: %Assignment.Cache{key_fun: (any -> any), data: %{any => Assignment.Result.destination}}
  defstruct [:key_fun, :data]

  def new(key_fun) do
    %__MODULE__{key_fun: key_fun, data: %{}}
  end

  def put(cache, input, value) do
    key = cache.key_fun.(input)
    put_in(cache.data[key], value)
  end

  def cached?(cache, input) do
    key = cache.key_fun.(input)
    Map.has_key?(cache.data, key)
  end

  def value(cache, input) do
    key = cache.key_fun.(input)
    cache.data[key]
  end

  def identity(v), do: v
end
