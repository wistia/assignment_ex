defmodule Assignment.RoundRobin do
  @moduledoc """
  Assigns a list of assignees to a list of destinations. Supports single-pass
  assignment as well as looping through the destinations
  """

  @spec assign(list(any()), list(any()), map) :: Assignment.Result.t
  def assign(unassigned, destinations, opts \\ %{}) do
    opts = Map.new(opts)
    opts = Map.put_new(opts, :loop, true)
    do_assign(unassigned, destinations, destinations, %{}, opts)
  end

  defp do_assign([], destinations, _destination_queue, assignments, _opts) do
    %Assignment.Result{unassigned: [], assignments: assignments, destinations: destinations}
  end
  defp do_assign([current_assignee|unassigned], destinations, destination_queue, assignments, opts) do
    case assign_one(current_assignee, destination_queue, opts) do
      {:ok, {new_destination_queue, new_assignment}} ->
        new_assignments = Assignment.Result.add_assignment(assignments, new_assignment)
        do_assign(unassigned, destinations, new_destination_queue, new_assignments, opts)

      {:error, :no_destinations} ->
        %Assignment.Result{unassigned: [current_assignee] ++ unassigned, assignments: assignments, destinations: destinations}
    end
  end

  @spec assign_one(Assignment.Result.assignee, list(Assignment.Result.destination), map) :: {list(Assignment.Result.destination), Assignment.Result.assignment}
  def assign_one(_current_assignee, [], _opts)  do
    {:error, :no_destinations}
  end
  def assign_one(current_assignee, [current_destination|rem_destinations], %{loop: true}) do
    {:ok, {rem_destinations ++ [current_destination], {current_destination, current_assignee}}}
  end
  def assign_one(current_assignee, [current_destination|rem_destinations], %{loop: false}) do
    {:ok, {rem_destinations, {current_destination, current_assignee}}}
  end
end
