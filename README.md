# Assignment

generic library for assigning things using various strategies (e.g. round robin, cached round robin)

## Installation

```ex
def deps do
  [{:assignment, github: "wistia/assignment_ex"}]
end
```

## Usage

```ex
# Simple round robin
iex(1)> Assignment.round_robin([1, 2, 3, 1, 1, 4, 5], [:us, :europe, :asia])
%Assignment.Result{
  assignments: %{asia: [3, 4], europe: [2, 1], us: [1, 1, 5]},
  destinations: [:us, :europe, :asia],
  unassigned: []
}

# Round robin without looping destinations
iex(2)> Assignment.round_robin([1, 2, 3, 1, 1, 4, 5], [:us, :europe, :asia], loop: false)
%Assignment.Result{
  assignments: %{asia: [3], europe: [2], us: [1]},
  destinations: [:us, :europe, :asia],
  unassigned: [1, 1, 4, 5]
}

# Cached round robin
iex(10)> Assignment.cached_round_robin([1, 2, 3, 1, 1, 4, 5], [:us, :europe, :asia])
%Assignment.Result{
  assignments: %{asia: [3], europe: [2, 5], us: [1, 1, 1, 4]},
  destinations: [:us, :europe, :asia],
  unassigned: []
}

# Cached round robin without looping destinations
iex(4)> Assignment.cached_round_robin([1, 2, 3, 1, 1, 4, 5], [:us, :europe, :asia], loop: false)
%Assignment.Result{
  assignments: %{asia: [3], europe: [2], us: [1, 1, 1]},
  destinations: [:us, :europe, :asia],
  unassigned: [4, 5]
}

# Cached round robin with a custom key function
iex(5)> Assignment.cached_round_robin([1, 1, 1, 2, 3, 4, 5], [:us, :europe, :asia], key_fun: fn i -> rem(i, 2) end)
%Assignment.Result{
  assignments: %{europe: [2, 4], us: [1, 1, 1, 3, 5]},
  destinations: [:us, :europe, :asia],
  unassigned: []
}

# Cached round robin with a drop-in cache
iex(6)> Assignment.cached_round_robin([1, 1, 1, 2, 3, 4, 5], [:us, :europe, :asia], cache: %Assignment.Cache{key_fun: &Assignment.Cache.identity/1, data: %{1 => :asia}})
%Assignment.Result{
  assignments: %{asia: [1, 1, 1, 4], europe: [3], us: [2, 5]},
  destinations: [:us, :europe, :asia],
  unassigned: []
}
```
