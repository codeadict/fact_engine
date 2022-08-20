defmodule FactEngine do
  @moduledoc """
  Prolog style, in-memory logic programming interpreter for facts and queries.
  """
  require Logger

  alias FactEngine.Engine
  alias FactEngine.OutputFormatter
  alias FactEngine.Parser

  @doc """
  Command-line entrypoint.
  """
  @spec main(any) :: no_return()
  def main(args) do
    args |> parse_args() |> run()
    exit({:shutdown, 0})
  end

  defp parse_args(args) do
    parsed_args =
      OptionParser.parse(args,
        switches: [help: :boolean],
        aliases: [h: :help]
      )

    case parsed_args do
      {[help: true], _, _} -> :help
      {[input: file_name], _, _} when file_name != true -> {:start, file_name}
      _ -> :help
    end
  end

  defp run(:help) do
    IO.puts("USAGE: fact_engine --input <path_to_file>")
  end

  defp run({:start, file_name}) do
    {:ok, _pid} = Engine.start_link()

    file_name
    |> Parser.parse_file!()
    |> Enum.each(&process_command/1)
  end

  defp process_command({:input, _, _, _} = input), do: Engine.store(input)

  defp process_command({:query, _, _, _} = query) do
    query
    |> Engine.query()
    |> OutputFormatter.format()
    |> IO.puts()
  end
end
