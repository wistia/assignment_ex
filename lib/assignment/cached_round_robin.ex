defmodule Assignment.CachedRoundRobin do
  @moduledoc """
  Like `Assignment.RoundRobin` but updates/checks a cache for destination assignments and prefers
  the cached destination over blindly round-robining to a destination
  """

  alias Assignment.Cache

  @spec assign(list(any()), list(any()), map) :: Assignment.Result.t
  def assign(unassigned, destinations, opts \\ %{}) do
    opts = Map.new(opts)
    opts = Map.put_new(opts, :loop, true)
    opts = Map.put_new(opts, :key_fun, &Cache.identity/1)
    opts = Map.put_new(opts, :cache, Cache.new(opts[:key_fun]))
    do_assign(unassigned, destinations, destinations, %{}, opts[:cache], [], opts)
  end

  defp do_assign([], destinations, _destination_queue, assignments, _cache, cant_assign, _opts) do
    %Assignment.Result{unassigned: cant_assign, assignments: assignments, destinations: destinations}
  end
  defp do_assign([current_assignee|unassigned], destinations, destination_queue, assignments, cache, cant_assign, opts) do
    if Cache.cached?(cache, current_assignee) do
      new_assignment = {Cache.value(cache, current_assignee), current_assignee}
      new_assignments = Assignment.Result.add_assignment(assignments, new_assignment)
      do_assign(unassigned, destinations, destination_queue, new_assignments, cache, cant_assign, opts)
    else
      case Assignment.RoundRobin.assign_one(current_assignee, destination_queue, opts) do
        {:ok, {new_destination_queue, new_assignment = {destination, ^current_assignee}}} ->
          new_assignments = Assignment.Result.add_assignment(assignments, new_assignment)
          new_cache = Cache.put(cache, current_assignee, destination)
          do_assign(unassigned, destinations, new_destination_queue, new_assignments, new_cache, cant_assign, opts)

        {:error, :no_destinations} ->
          do_assign(unassigned, destinations, destination_queue, assignments, cache, cant_assign ++ [current_assignee], opts)
      end
    end
  end
end
