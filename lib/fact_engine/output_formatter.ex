defmodule FactEngine.OutputFormatter do
  @moduledoc """
  Formats query outputs as io_data to be written to stdout.
  """
  @output_header "---\n"

  @doc """
  Transforms a query result to an IO List for efficient output to
  a file, socket or stdout.
  """
  @spec format(FactEngine.Types.query_result()) :: iolist()
  def format(output) do
    Enum.flat_map(output, &format_result/1)
  end

  defp format_result(result) when is_boolean(result) do
    [@output_header, to_string(result)]
  end

  defp format_result([result]) when is_boolean(result) do
    [@output_header, to_string(result)]
  end

  defp format_result(variables) do
    repeated_vars =
      variables
      |> hd()
      |> Enum.uniq_by(&elem(&1, 0))
      |> length()

    if repeated_vars > 1 do
      [@output_header | [format_multi(variables)]]
    else
      [@output_header | [format_single(variables)]]
    end
  end

  defp format_single(variables) do
    variables
    |> Enum.map_join("\n", fn [{k, v} | _] -> "#{k}: #{v}" end)
  end

  defp format_multi(variables) do
    variables
    |> hd()
    |> Enum.map_join(", ", fn {k, v} -> "#{k}: #{v}" end)
  end
end
