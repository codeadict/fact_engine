defmodule FactEngine.Parser do
  @moduledoc """
  Parser for facts and queries, implemented using
  [Erlang parse tools](https://www.erlang.org/doc/apps/parsetools/index.html)

  See the syntax definition on [src/fact_tokenizer.xrl](src/fact_tokenizer.xrl).
  """
  require Logger

  @spec parse_file!(Path.t()) :: [FactEngine.Types.command()] | no_return()
  def parse_file!(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&eval!/1)
  end

  @spec eval!(binary()) :: FactEngine.Types.command() | no_return()
  def eval!(line) do
    case eval(line) do
      {:ok, cmd} ->
        cmd

      {:error, reason} ->
        raise(ArgumentError, reason)
    end
  end

  @spec eval(binary()) :: {:ok, FactEngine.Types.command()} | {:error, any()}
  def eval(line) do
    Logger.debug(line)

    with {:ok, tokens, _} <- :fact_tokenizer.string(to_charlist(line)),
         {:ok, command} <- do_parse(tokens, line) do
      {:ok, command}
    else
      {:error, reason} = err ->
        Logger.error("Failed to parse line: #{line}", reason: inspect(reason))
        err

      {:error, {_, :fact_tokenizer, reason}, _} ->
        friendly_reason = to_string(:fact_tokenizer.format_error(reason))
        Logger.error("Failed to parse line: #{line}", reason: friendly_reason)
        {:error, friendly_reason}
    end
  end

  defp do_parse([{:cmd, cmd}, {:fact, fact} | args], _) do
    {:ok, {cmd, fact, length(args), args}}
  end

  defp do_parse(_tokens, _) do
    {:error, :parse_error}
  end
end
