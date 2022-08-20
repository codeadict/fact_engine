defmodule FactEngine.Types do
  @moduledoc """
  Common types used across the application.
  """

  @typedoc "An input command"
  @type input_command :: {:input, fact :: binary(), arity :: non_neg_integer(), args :: list()}

  @typedoc "A query command"
  @type query_command :: {:query, fact :: binary(), arity :: non_neg_integer(), args :: list()}

  @typedoc "Represents the result of a query"
  @type query_result :: [[boolean()] | [Keyword.t()]]

  @typedoc "Return value of a parsed fact, could be an input or a query"
  @type command :: input_command() | query_command()
end
