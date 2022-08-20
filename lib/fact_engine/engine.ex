defmodule FactEngine.Engine do
  @moduledoc """
  A server implementation that allows facts to be stored and retrieved via a simple API.
  """
  use GenServer

  @doc """
  Returns a specification to start under a supervisor.
  """
  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end

  @doc """
  Starts the engine linked to the current process.

  ## Examples

    iex> {:ok, pid} = FactEngine.Engine.start_link()
    {:ok, pid}
  """
  @spec start_link(GenServer.options()) :: {:ok, pid} | {:error, {:already_started, pid} | term}
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  @doc """
  Stores a fact in the program memory.

  ## Examples

    iex> {:ok, _pid} = FactEngine.Engine.start_link()
    iex> FactEngine.Engine.store({{:cmd, :store}, {:fact, "is_odd"}, 1, [{:number, 3}]})
    :ok
    iex> FactEngine.Engine.query({{:cmd, :query}, {:fact, "is_odd"}, 1, [{:number, 2}]})
    [[]]
    iex> FactEngine.Engine.query({{:cmd, :query}, {:fact, "is_odd"}, 1, [{:number, 3}]})
    [[true]]
    iex> FactEngine.Engine.query({{:cmd, :query}, {:fact, "is_odd"}, 1, [{:var, :'X'}]})
    [[[X: 3]]]
  """
  @spec store(FactEngine.Types.input_command()) :: :ok
  def store(input) do
    GenServer.call(__MODULE__, {:store, input})
  end

  @doc """
  Runs a query command and returns the matching facts.

  ## Examples

    iex> {:ok, _pid} = FactEngine.Engine.start_link()
    iex> FactEngine.Engine.query({{:cmd, :query}, {:fact, "is_odd"}, 1, [3]})
    [[false]]
  """
  @spec query(FactEngine.Types.query_command()) :: FactEngine.Types.query_result()
  def query(query) do
    GenServer.call(__MODULE__, {:q, query})
  end

  @impl true
  def init(_) do
    {:ok, []}
  end

  @impl true
  def handle_call({:store, input}, _from, state) do
    {:reply, :ok, Enum.reverse([input | state])}
  end

  def handle_call({:q, _query}, _from, [] = state) do
    {:reply, [[false]], state}
  end

  def handle_call({:q, query}, _from, state) do
    results =
      state
      |> Enum.reduce([], fn x, acc ->
        res = match_line(x, query)

        if res == :ignore or res in acc do
          acc
        else
          [res | acc]
        end
      end)

    {:reply, [Enum.reverse(results)], state}
  end

  defp match_line({_, fun, arity, args}, {_, fun, arity, args}), do: true

  defp match_line({_, fun, arity, args}, {_, fun, arity, match_args}) do
    match(args, match_args)
  end

  defp match_line(_, _), do: :ignore

  defp match(l1, l2), do: match(l1, l2, [])
  defp match([], [], []), do: true
  defp match([], [], acc), do: acc
  defp match([h | t1], [h | t2], acc), do: match(t1, t2, acc)

  defp match([{_, var_value} | t1], [{:var, var_name} | t2], acc) do
    if Keyword.has_key?(acc, var_name) and Keyword.get(acc, var_name) != var_value do
      false
    else
      match(t1, t2, Enum.reverse([{var_name, var_value} | acc]))
    end
  end

  defp match([_h1 | _], [_h2 | _], _), do: :ignore
  defp match(_, _, _), do: :ignore
end
