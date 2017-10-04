defmodule Assignment.Result do
  @type destination :: any()
  @type assignee :: any()
  @type assignments :: %{destination => list(assignee)}
  @type assignment :: {destination, assignee}
  @type t :: %Assignment.Result{unassigned: list(assignee), assignments: assignments, destinations: list(destination)}
  defstruct [:unassigned, :assignments, :destinations]

  @spec add_assignment(assignments, assignment) :: assignments
  def add_assignment(assignments, {destination, assignee}) do
    case assignments[destination] do
      nil -> put_in(assignments[destination], [assignee])
      list when is_list(list) -> put_in(assignments[destination], list ++ [assignee])
    end
  end
end
