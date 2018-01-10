defmodule AssignmentTest do
  alias Assignment.Result
  import Assignment
  use ExUnit.Case
  doctest Assignment

  test "round robin" do
    result = round_robin([1, 2, 3], [:a, :b, :c])
    assert %Result{assignments: %{a: [1], b: [2], c: [3]}, unassigned: [], destinations: [:a, :b, :c], state: _} = result

    result = round_robin([1, 2, 3], [:a, :b])
    assert %Result{assignments: %{a: [1, 3], b: [2]}, destinations: [:a, :b], unassigned: [], state: _} = result

    result = round_robin([1], [:a, :b])
    assert %Result{assignments: %{a: [1]}, destinations: [:a, :b], unassigned: [], state: _} = result

    result = round_robin([1], [])
    assert %Result{assignments: %{}, destinations: [], unassigned: [1], state: _} = result

    result = round_robin([], [])
    assert %Result{assignments: %{}, destinations: [], unassigned: [], state: _} = result

    result = round_robin([], [:a, :b])
    assert %Result{assignments: %{}, destinations: [:a, :b], unassigned: [], state: _} = result

    result = round_robin([1, 2, 3], [:a, :b], loop: false)
    assert %Result{assignments: %{a: [1], b: [2]}, destinations: [:a, :b], unassigned: [3], state: _} = result

    result = round_robin([1, 2, 1], [:a, :b, :c])
    assert %Result{assignments: %{a: [1], b: [2], c: [1]}, unassigned: [], destinations: [:a, :b, :c], state: _} = result

    result = round_robin([1], [:a, :b])
    assert result.assignments == %{a: [1]}
    result = round_robin([2, 3], result.state)
    assert result.assignments == %{b: [2], a: [3]}

    result = round_robin([1, 2], [:a, :b])
    assert result.assignments == %{a: [1], b: [2]}
    result = round_robin([3, 4], result.state)
    assert result.assignments == %{a: [3], b: [4]}

    result = round_robin([1, 2, 3], [:a, :b], loop: false)
    assert result.assignments == %{a: [1], b: [2]}
    result = round_robin([4, 5, 6], result.state, loop: false)
    assert result.assignments == %{a: [4], b: [5]}

    result = round_robin([1, 2, 3], [:a, :b], loop: false)
    assert result.assignments == %{a: [1], b: [2]}
    result = round_robin([4, 5, 6], result.state)
    assert result.assignments == %{a: [4, 6], b: [5]}
  end

  @tag :focus
  test "cached round robin" do
    result = cached_round_robin([1, 2, 3], [:a, :b, :c])
    assert %Result{assignments: %{a: [1], b: [2], c: [3]}, unassigned: [], destinations: [:a, :b, :c], state: _} = result

    result = cached_round_robin([1, 2, 3], [:a, :b])
    assert %Result{assignments: %{a: [1, 3], b: [2]}, destinations: [:a, :b], unassigned: [], state: _} = result

    result = cached_round_robin([1], [:a, :b])
    assert %Result{assignments: %{a: [1]}, destinations: [:a, :b], unassigned: [], state: _} = result

    result = cached_round_robin([1], [])
    assert %Result{assignments: %{}, destinations: [], unassigned: [1], state: _} = result

    result = cached_round_robin([], [])
    assert %Result{assignments: %{}, destinations: [], unassigned: [], state: _} = result

    result = cached_round_robin([], [:a, :b])
    assert %Result{assignments: %{}, destinations: [:a, :b], unassigned: [], state: _} = result

    result = cached_round_robin([1, 2, 3], [:a, :b], loop: false)
    assert %Result{assignments: %{a: [1], b: [2]}, destinations: [:a, :b], unassigned: [3], state: _} = result

    result = cached_round_robin([1, 2, 3, 1, 2, 3], [:a, :b], loop: false)
    assert %Result{assignments: %{a: [1, 1], b: [2, 2]}, destinations: [:a, :b], unassigned: [3, 3], state: _} = result

    result = cached_round_robin([1, 2, 1], [:a, :b, :c])
    assert %Result{assignments: %{a: [1, 1], b: [2]}, unassigned: [], destinations: [:a, :b, :c], state: _} = result

    result = cached_round_robin([1, 2, 3, 1, 2, 3], [:a, :b, :c])
    assert %Result{assignments: %{a: [1, 1], b: [2, 2], c: [3, 3]}, unassigned: [], destinations: [:a, :b, :c], state: _} = result

    result = cached_round_robin([1, 1, 2], [:a, :b, :c], loop: false)
    assert %Result{assignments: %{a: [1, 1], b: [2]}, unassigned: [], destinations: [:a, :b, :c], state: _} = result

    result = cached_round_robin([1, 1, 2, 3, 4], [:a, :b, :c], loop: false)
    assert %Result{assignments: %{a: [1, 1], b: [2], c: [3]}, unassigned: [4], destinations: [:a, :b, :c], state: _} = result

    result = cached_round_robin([1, 1, 2, 2, 3, 3], [:a, :b], loop: false)
    assert %Result{assignments: %{a: [1, 1], b: [2, 2]}, unassigned: [3, 3], destinations: [:a, :b], state: _} = result

    key_fun = fn {key, _} -> key end
    result = cached_round_robin([{:josh, 1}, {:josh, 2}, {:penny, 3}, {:josh, 4}], [:a, :b], key_fun: key_fun)
    assert %Result{assignments: %{a: [{:josh, 1}, {:josh, 2}, {:josh, 4}], b: [{:penny, 3}]}, unassigned: [], destinations: [:a, :b], state: _} = result

    key_fun = fn {key, _} -> key end
    cache = %Assignment.Cache{key_fun: key_fun, data: %{josh: :b, penny: :a}}
    result = cached_round_robin([{:josh, 1}, {:josh, 2}, {:penny, 3}, {:josh, 4}], [:a, :b], cache: cache)
    assert %Result{assignments: %{a: [{:penny, 3}], b: [{:josh, 1}, {:josh, 2}, {:josh, 4}]}, unassigned: [], destinations: [:a, :b], state: _} = result

    key_fun = fn {key, _} -> key end
    cache = %Assignment.Cache{key_fun: key_fun, data: %{josh: :b, penny: :a}}
    result = cached_round_robin([{:josh, 1}, {:josh, 2}, {:penny, 3}, {:josh, 4}, {:lauren, 5}], [:a, :b], cache: cache)
    assert %Result{assignments: %{a: [{:penny, 3}, {:lauren, 5}], b: [{:josh, 1}, {:josh, 2}, {:josh, 4}]}, unassigned: [], destinations: [:a, :b], state: _} = result

    result = cached_round_robin([1], [:a, :b])
    assert result.assignments == %{a: [1]}
    result = cached_round_robin([2, 3], result.state)
    assert result.assignments == %{b: [2], a: [3]}

    result = cached_round_robin([1, 2], [:a, :b])
    assert result.assignments == %{a: [1], b: [2]}
    result = cached_round_robin([3, 4], result.state)
    assert result.assignments == %{a: [3], b: [4]}

    result = cached_round_robin([1, 2, 3], [:a, :b], loop: false)
    assert result.assignments == %{a: [1], b: [2]}
    result = cached_round_robin([4, 5, 6], result.state, loop: false)
    assert result.assignments == %{a: [4], b: [5]}

    result = cached_round_robin([1], [:a, :b])
    assert result.assignments == %{a: [1]}
    result = cached_round_robin([2, 3, 1], result.state)
    assert result.assignments == %{b: [2], a: [3, 1]}

    result = cached_round_robin([1, 2], [:a, :b])
    assert result.assignments == %{a: [1], b: [2]}
    result = cached_round_robin([3, 4, 2, 2], result.state)
    assert result.assignments == %{a: [3], b: [4, 2, 2]}
  end
end
