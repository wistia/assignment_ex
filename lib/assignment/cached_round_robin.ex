defmodule Assignment.CachedRoundRobin do
  @moduledoc """
  Like `Assignment.RoundRobin` but updates/checks a cache for destination assignments and prefers
  the cached destination over blindly round-robining to a destination
  """

  @type state :: %{
    cache: {atom, any()},
    destinations: [any()],
    round_robin: Assignment.RoundRobin.state
  }

  def assign(_, _, opts \\ %{})

  @spec assign(list(any()), {:state, state()}, map) :: Assignment.Result.t
  def assign(unassigned, {:state, state}, opts) do
    opts = Map.new(opts)
    opts = Map.put_new(opts, :loop, true)
    max_iterations = if opts.loop, do: :infinity, else: length(state.destinations)
    do_assign(unassigned, state, %{}, [], max_iterations)
  end

  @spec assign(list(any()), list(any()), map) :: Assignment.Result.t
  def assign(unassigned, destinations, opts) do
    opts = Map.new(opts)
    state = init(destinations, opts)
    assign(unassigned, {:state, state}, opts)
  end

  def init(destinations, opts) do
    %{cache: setup_cache(opts), round_robin: Assignment.RoundRobin.init(destinations), destinations: destinations}
  end

  defp do_assign([], state, assignments, cant_assign, _iterations_left) do
    %Assignment.Result{
      unassigned: cant_assign,
      assignments: assignments,
      destinations: state.destinations,
      state: {:state, state}
    }
  end

  defp do_assign([current_assignee|unassigned], state, assignments, cant_assign, iterations_left) do
    {cache_mod, cache} = state.cache
    cond do
      cache_mod.cached?(cache, current_assignee) ->
        cached_value = cache_mod.value(cache, current_assignee)
        new_assignment = {cached_value, current_assignee}
        new_assignments = Assignment.Result.add_assignment(assignments, new_assignment)
        do_assign(unassigned, state, new_assignments, cant_assign, iterations_left)

      iterations_left == 0 ->
        do_assign(unassigned, state, assignments, cant_assign ++ [current_assignee], iterations_left)

      true ->
        case Assignment.RoundRobin.assign_one(current_assignee, state.round_robin) do
          {:ok, {new_round_robin_state, new_assignment = {destination, ^current_assignee}}} ->
            new_state =
              state
              |> put_in([:cache], {cache_mod, cache_mod.put(cache, current_assignee, destination)})
              |> put_in([:round_robin], new_round_robin_state)
            new_assignments = Assignment.Result.add_assignment(assignments, new_assignment)
            do_assign(unassigned, new_state, new_assignments, cant_assign, Assignment.RoundRobin.decrement(iterations_left))

          {:error, :no_destinations} ->
            do_assign(unassigned, state, assignments, cant_assign ++ [current_assignee], iterations_left)
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
