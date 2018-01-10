defmodule Assignment do
  @type destination :: any()
  @type assignee :: any()
  @type assignments :: %{destination => list(assignee)}
  @type assignment :: {destination, assignee}
  @type assignment_config :: [destination] | {:state, any()}

  @spec round_robin(list(assignee()), assignment_config(), opts :: map) :: Assignment.Result.t
  def round_robin(unassigned, config, opts \\ []) do
    Assignment.RoundRobin.assign(unassigned, config, opts)
  end

  @spec cached_round_robin(list(assignee()), assignment_config(), opts :: map) :: Assignment.Result.t
  def cached_round_robin(unassigned, config, opts \\ []) do
    Assignment.CachedRoundRobin.assign(unassigned, config, opts)
  end
end
