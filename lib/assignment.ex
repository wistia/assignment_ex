defmodule Assignment do
  @spec round_robin(list(Assignment.Result.assignee), list(Assignment.Result.destination), opts :: map) :: Assignment.Result.t
  def round_robin(unassigned, destinations, opts \\ []) do
    Assignment.RoundRobin.assign(unassigned, destinations, opts)
  end

  @spec cached_round_robin(list(Assignment.Result.assignee), list(Assignment.Result.destination), opts :: map) :: Assignment.Result.t
  def cached_round_robin(unassigned, destinations, opts \\ []) do
    Assignment.CachedRoundRobin.assign(unassigned, destinations, opts)
  end
end
