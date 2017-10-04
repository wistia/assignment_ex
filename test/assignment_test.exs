defmodule AssignmentTest do
  alias Assignment.Result
  import Assignment
  use ExUnit.Case
  doctest Assignment

  test "round robin" do
    assert round_robin([1, 2, 3], [:a, :b, :c]) ==
      %Result{assignments: %{a: [1], b: [2], c: [3]}, unassigned: [], destinations: [:a, :b, :c]}

    assert round_robin([1, 2, 3], [:a, :b]) ==
      %Result{assignments: %{a: [1, 3], b: [2]}, destinations: [:a, :b], unassigned: []}

    assert round_robin([1], [:a, :b]) ==
      %Result{assignments: %{a: [1]}, destinations: [:a, :b], unassigned: []}

    assert round_robin([1], []) ==
      %Result{assignments: %{}, destinations: [], unassigned: [1]}

    assert round_robin([], []) ==
      %Result{assignments: %{}, destinations: [], unassigned: []}

    assert round_robin([], [:a, :b]) ==
      %Result{assignments: %{}, destinations: [:a, :b], unassigned: []}

    assert round_robin([1, 2, 3], [:a, :b], loop: false) ==
      %Result{assignments: %{a: [1], b: [2]}, destinations: [:a, :b], unassigned: [3]}

    assert round_robin([1, 2, 1], [:a, :b, :c]) ==
      %Result{assignments: %{a: [1], b: [2], c: [1]}, unassigned: [], destinations: [:a, :b, :c]}
  end

  test "cached round robin" do
    assert cached_round_robin([1, 2, 3], [:a, :b, :c]) ==
      %Result{assignments: %{a: [1], b: [2], c: [3]}, unassigned: [], destinations: [:a, :b, :c]}

    assert cached_round_robin([1, 2, 3], [:a, :b]) ==
      %Result{assignments: %{a: [1, 3], b: [2]}, destinations: [:a, :b], unassigned: []}

    assert cached_round_robin([1], [:a, :b]) ==
      %Result{assignments: %{a: [1]}, destinations: [:a, :b], unassigned: []}

    assert cached_round_robin([1], []) ==
      %Result{assignments: %{}, destinations: [], unassigned: [1]}

    assert cached_round_robin([], []) ==
      %Result{assignments: %{}, destinations: [], unassigned: []}

    assert cached_round_robin([], [:a, :b]) ==
      %Result{assignments: %{}, destinations: [:a, :b], unassigned: []}

    assert cached_round_robin([1, 2, 3], [:a, :b], loop: false) ==
      %Result{assignments: %{a: [1], b: [2]}, destinations: [:a, :b], unassigned: [3]}

    assert cached_round_robin([1, 2, 3, 1, 2, 3], [:a, :b], loop: false) ==
      %Result{assignments: %{a: [1, 1], b: [2, 2]}, destinations: [:a, :b], unassigned: [3, 3]}

    assert cached_round_robin([1, 2, 1], [:a, :b, :c]) ==
      %Result{assignments: %{a: [1, 1], b: [2]}, unassigned: [], destinations: [:a, :b, :c]}

    assert cached_round_robin([1, 2, 3, 1, 2, 3], [:a, :b, :c]) ==
      %Result{assignments: %{a: [1, 1], b: [2, 2], c: [3, 3]}, unassigned: [], destinations: [:a, :b, :c]}

    assert cached_round_robin([1, 1, 2], [:a, :b, :c], loop: false) ==
      %Result{assignments: %{a: [1, 1], b: [2]}, unassigned: [], destinations: [:a, :b, :c]}

    assert cached_round_robin([1, 1, 2, 3, 4], [:a, :b, :c], loop: false) ==
      %Result{assignments: %{a: [1, 1], b: [2], c: [3]}, unassigned: [4], destinations: [:a, :b, :c]}

    assert cached_round_robin([1, 1, 2, 2, 3, 3], [:a, :b], loop: false) ==
      %Result{assignments: %{a: [1, 1], b: [2, 2]}, unassigned: [3, 3], destinations: [:a, :b]}

    key_fun = fn {key, _} -> key end
    assert cached_round_robin([{:josh, 1}, {:josh, 2}, {:penny, 3}, {:josh, 4}], [:a, :b], key_fun: key_fun) ==
      %Result{assignments: %{a: [{:josh, 1}, {:josh, 2}, {:josh, 4}], b: [{:penny, 3}]}, unassigned: [], destinations: [:a, :b]}

    key_fun = fn {key, _} -> key end
    cache = %Assignment.Cache{key_fun: key_fun, data: %{josh: :b, penny: :a}}
    assert cached_round_robin([{:josh, 1}, {:josh, 2}, {:penny, 3}, {:josh, 4}], [:a, :b], cache: cache) ==
      %Result{assignments: %{a: [{:penny, 3}], b: [{:josh, 1}, {:josh, 2}, {:josh, 4}]}, unassigned: [], destinations: [:a, :b]}

    key_fun = fn {key, _} -> key end
    cache = %Assignment.Cache{key_fun: key_fun, data: %{josh: :b, penny: :a}}
    assert cached_round_robin([{:josh, 1}, {:josh, 2}, {:penny, 3}, {:josh, 4}, {:lauren, 5}], [:a, :b], cache: cache) ==
      %Result{assignments: %{a: [{:penny, 3}, {:lauren, 5}], b: [{:josh, 1}, {:josh, 2}, {:josh, 4}]}, unassigned: [], destinations: [:a, :b]}
  end
end
