defmodule Assignment do
  @type destination :: any()
  @type assignee :: any()
  @type assignments :: %{destination => list(assignee)}
  @type assignment :: {destination, assignee}

  @spec round_robin(list(Assignment.assignee), list(Assignment.destination), opts :: map) :: Assignment.Result.t
  def round_robin(unassigned, destinations, opts \\ []) do
    Assignment.RoundRobin.assign(unassigned, destinations, opts)
  end

  @spec cached_round_robin(list(Assignment.assignee), list(Assignment.destination), opts :: map) :: Assignment.Result.t
  def cached_round_robin(unassigned, destinations, opts \\ []) do
    Assignment.CachedRoundRobin.assign(unassigned, destinations, opts)
  end
end
