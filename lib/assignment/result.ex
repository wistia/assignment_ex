defmodule Assignment.Result do
  @type t :: %Assignment.Result{unassigned: list(Assignment.assignee), assignments: Assignment.assignments, destinations: list(Assignment.destination)}
  defstruct [:unassigned, :assignments, :destinations]

  @spec add_assignment(Assignment.assignments, Assignment.assignment) :: Assignment.assignments
  def add_assignment(assignments, {destination, assignee}) do
    case assignments[destination] do
      nil -> put_in(assignments[destination], [assignee])
      list when is_list(list) -> put_in(assignments[destination], list ++ [assignee])
    end
  end
end
