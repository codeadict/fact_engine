defmodule FactEngine.OutputFormatterTest do
  use ExUnit.Case, async: true
  alias FactEngine.OutputFormatter

  describe "format/1" do
    test "can format booleans" do
      assert ["---\n", "true"] == OutputFormatter.format([[true]])
      assert ["---\n", "false"] == OutputFormatter.format([[false]])
    end

    test "can format same repeated variable" do
      query_result = [[[X: :foo], [X: :bar]]]
      assert ["---\n", "X: foo\nX: bar"] == OutputFormatter.format(query_result)
    end

    test "can format multiple variables" do
      query_result = [[[X: "foo", Y: "bar"]]]
      assert ["---\n", "X: foo, Y: bar"] == OutputFormatter.format(query_result)
    end
  end
end
