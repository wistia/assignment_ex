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
  unassigned: [],
  state: ...
}

# Round robin without looping destinations
iex(2)> Assignment.round_robin([1, 2, 3, 1, 1, 4, 5], [:us, :europe, :asia], loop: false)
%Assignment.Result{
  assignments: %{asia: [3], europe: [2], us: [1]},
  destinations: [:us, :europe, :asia],
  unassigned: [1, 1, 4, 5],
  state: ...
}

# Cached round robin
iex(10)> Assignment.cached_round_robin([1, 2, 3, 1, 1, 4, 5], [:us, :europe, :asia])
%Assignment.Result{
  assignments: %{asia: [3], europe: [2, 5], us: [1, 1, 1, 4]},
  destinations: [:us, :europe, :asia],
  unassigned: [],
  state: ...
}

# Cached round robin without looping destinations
iex(4)> Assignment.cached_round_robin([1, 2, 3, 1, 1, 4, 5], [:us, :europe, :asia], loop: false)
%Assignment.Result{
  assignments: %{asia: [3], europe: [2], us: [1, 1, 1]},
  destinations: [:us, :europe, :asia],
  unassigned: [4, 5],
  state: ...
}

# Cached round robin with a custom key function
iex(5)> Assignment.cached_round_robin([1, 1, 1, 2, 3, 4, 5], [:us, :europe, :asia], key_fun: fn i -> rem(i, 2) end)
%Assignment.Result{
  assignments: %{europe: [2, 4], us: [1, 1, 1, 3, 5]},
  destinations: [:us, :europe, :asia],
  unassigned: [],
  state: ...
}

# Cached round robin with a drop-in cache
iex(6)> Assignment.cached_round_robin([1, 1, 1, 2, 3, 4, 5], [:us, :europe, :asia], cache: %Assignment.Cache{key_fun: &Assignment.Cache.identity/1, data: %{1 => :asia}})
%Assignment.Result{
  assignments: %{asia: [1, 1, 1, 4], europe: [3], us: [2, 5]},
  destinations: [:us, :europe, :asia],
  unassigned: [],
  state: ...
}

# Continue with your previous state
iex(4)> result = Assignment.round_robin([1], [:us, :europe])
%Assignment.Result{
  assignments: %{us: [1]},
  destinations: [:us, :europe],
  state: {:state, %{
            destination_queue: [:europe, :us],
            destinations: [:us, :europe]
          }},
  unassigned: []
}
iex(5)> result = Assignment.round_robin([2, 3], result.state)
%Assignment.Result{
  assignments: %{europe: [2], us: [3]},
  destinations: [:us, :europe],
  state: {:state, %{
            destination_queue: [:europe, :us],
            destinations: [:us, :europe]
          }},
  unassigned: []
}

# Continue with your previous state (with caching)
# Note that 1) the cache is maintained and 2) new traffic is still fairly balanced between the destinations
iex(8)> result = Assignment.cached_round_robin([1, 2, 3], [:us, :europe])
%Assignment.Result{
  assignments: %{europe: [2], us: [1, 3]},
  destinations: [:us, :europe],
  state: {:state, %{
            cache: {Assignment.Cache, %Assignment.Cache{
                      data: %{1 => :us, 2 => :europe, 3 => :us},
                      key_fun: &Assignment.Cache.identity/1
                    }},
            destinations: [:us, :europe],
            round_robin: %{
              destination_queue: [:europe, :us],
              destinations: [:us, :europe]
            }
          }},
  unassigned: []
}
iex(9)> result = Assignment.cached_round_robin([1, 2, 3, 4], result.state)
%Assignment.Result{
  assignments: %{europe: [2, 4], us: [1, 3]},
  destinations: [:us, :europe],
  state: {:state, %{
            cache: {Assignment.Cache, %Assignment.Cache{
                      data: %{1 => :us, 2 => :europe, 3 => :us, 4 => :europe},
                      key_fun: &Assignment.Cache.identity/1
                    }},
            destinations: [:us, :europe],
            round_robin: %{
              destination_queue: [:us, :europe],
              destinations: [:us, :europe]
            }
          }},
  unassigned: []
}
```

## Using your own cache implementation

`Assignment.CacheBehaviour` defines the cache interface.
You can use this to use your own caching backend (to add key expiration for example).
You can then pass the cache module and initial state via the `:cache` option with a value like `{MyCacheMod, state}`
