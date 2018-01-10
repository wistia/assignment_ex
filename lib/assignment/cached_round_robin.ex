defmodule Assignment.CachedRoundRobin do
  @moduledoc """
  Like `Assignment.RoundRobin` but updates/checks a cache for destination assignments and prefers
  the cached destination over blindly round-robining to a destination
  """

  @spec assign(list(any()), list(any()), map) :: Assignment.Result.t
  def assign(unassigned, destinations, opts \\ %{}) do
    opts = Map.new(opts)
    opts = Map.put_new(opts, :loop, true)
    opts = Map.put_new(opts, :key_fun, &Assignment.Cache.identity/1)
    cache = setup_cache(opts)
    do_assign(unassigned, destinations, destinations, %{}, cache, [], opts)
  end

  defp do_assign([], destinations, _destination_queue, assignments, _cache, cant_assign, _opts) do
    %Assignment.Result{unassigned: cant_assign, assignments: assignments, destinations: destinations}
  end

  defp do_assign([current_assignee|unassigned], destinations, destination_queue, assignments, {cache_mod, cache}, cant_assign, opts) do
    if cache_mod.cached?(cache, current_assignee) do
      cached_value = cache_mod.value(cache, current_assignee)
      new_assignment = {cached_value, current_assignee}
      new_assignments = Assignment.Result.add_assignment(assignments, new_assignment)
      do_assign(unassigned, destinations, destination_queue, new_assignments, {cache_mod, cache}, cant_assign, opts)
    else
      case Assignment.RoundRobin.assign_one(current_assignee, destination_queue, opts) do
        {:ok, {new_destination_queue, new_assignment = {destination, ^current_assignee}}} ->
          new_assignments = Assignment.Result.add_assignment(assignments, new_assignment)
          new_cache = cache_mod.put(cache, current_assignee, destination)
          do_assign(unassigned, destinations, new_destination_queue, new_assignments, {cache_mod, new_cache}, cant_assign, opts)

        {:error, :no_destinations} ->
          do_assign(unassigned, destinations, destination_queue, assignments, {cache_mod, cache}, cant_assign ++ [current_assignee], opts)
      end
    end
  end

  defp setup_cache(%{cache: {mod, cache}}) do
    {mod, cache}
  end

  defp setup_cache(%{cache: cache = %Assignment.Cache{}}) do
    {Assignment.Cache, cache}
  end

  defp setup_cache(%{key_fun: key_fun}) do
    {Assignment.Cache, Assignment.Cache.new(key_fun)}
  end

  defp setup_cache(_) do
    {Assignment.Cache, Assignment.Cache.new(&Assignment.Cache.identity/1)}
  end
end
