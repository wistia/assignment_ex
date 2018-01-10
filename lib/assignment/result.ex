defmodule Assignment.Result do
  @moduledoc """
  Data structure returned after assignments occur

  ## Fields

  * `assignments` - a map of destinations to input assigned to those destinations

  * `destinations` - all of the destinations provided

  * `unassigned` - input we wanted to assign but that didn't get assigned (e.g. configured not to loop)

  * `state` - allows for assignment to be continued from where it left off. This allows us to do things like ensure
      we round-robin fairly between desintations over multiple calls
  """

  @type t :: %Assignment.Result{
    unassigned: list(Assignment.assignee),
    assignments: Assignment.assignments,
    destinations: list(Assignment.destination),
    state: map :: any()
  }

  defstruct [:unassigned, :assignments, :destinations, :state]

  @spec add_assignment(Assignment.assignments, Assignment.assignment) :: Assignment.assignments
  def add_assignment(assignments, {destination, assignee}) do
    case assignments[destination] do
      nil -> put_in(assignments[destination], [assignee])
      list when is_list(list) -> put_in(assignments[destination], list ++ [assignee])
    end
  end
end
