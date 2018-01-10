defmodule Assignment.RoundRobin do
  @moduledoc """
  Assigns a list of assignees to a list of destinations. Supports single-pass
  assignment as well as looping through the destinations
  """

  @type state :: %{
    destinations: [any()],
    destination_queue: [any()]
  }

  def assign(_, _, opts \\ %{})

  @spec assign(list(any()), {:state, state()}, map) :: Assignment.Result.t
  def assign(unassigned, {:state, state}, opts) do
    opts = Map.new(opts)
    opts = Map.put_new(opts, :loop, true)
    max_iterations = if opts.loop, do: :infinity, else: length(state.destinations)
    do_assign(unassigned, state, %{}, max_iterations)
  end

  @spec assign(list(any()), list(any()), map) :: Assignment.Result.t
  def assign(unassigned, destinations, opts) do
    state = init(destinations)
    assign(unassigned, {:state, state}, opts)
  end

  def init(destinations) do
    %{destinations: destinations, destination_queue: destinations}
  end

  defp do_assign([], state, assignments, _iterations_left) do
    %Assignment.Result{
      unassigned: [],
      assignments: assignments,
      destinations: state.destinations,
      state: {:state, state}
    }
  end

  defp do_assign(unassigned, state, assignments, 0) do
    %Assignment.Result{
      unassigned: unassigned,
      assignments: assignments,
      destinations: state.destinations,
      state: {:state, state}
    }
  end

  defp do_assign([current_assignee|unassigned], state, assignments, iterations_left) do
    case assign_one(current_assignee, state) do
      {:ok, {new_state, new_assignment}} ->
        new_assignments = Assignment.Result.add_assignment(assignments, new_assignment)
        do_assign(unassigned, new_state, new_assignments, decrement(iterations_left))

      {:error, :no_destinations} ->
        %Assignment.Result{
          unassigned: [current_assignee] ++ unassigned,
          assignments: assignments,
          destinations: state.destinations,
          state: {:state, state}
        }
    end
  end

  @spec assign_one(Assignment.Result.assignee, state()) :: {:error, :no_destinations}
  def assign_one(_current_assignee, %{destination_queue: []})  do
    {:error, :no_destinations}
  end

  @spec assign_one(Assignment.Result.assignee, state()) :: {:ok, {state(), Assignment.Result.assignment}}
  def assign_one(current_assignee, state) do
    [current_destination|rem_destinations] = state.destination_queue
    assignment = {current_destination, current_assignee}
    new_state = put_in(state[:destination_queue], rem_destinations ++ [current_destination])
    {:ok, {new_state, assignment}}
  end

  def decrement(:infinity), do: :infinity
  def decrement(n), do: n - 1
end
