defmodule FactEngine.ParserTest do
  use ExUnit.Case, async: true
  alias FactEngine.Parser

  describe "eval/1" do
    for cmd <- [:input, :query] do
      test "should parse single argument #{String.upcase(to_string(cmd))}" do
        cmd = unquote(cmd)

        assert {:ok, {^cmd, "is_odd", 1, [number: 3]}} =
                 Parser.eval("#{String.upcase(to_string(cmd))} is_odd (3)")
      end

      test "should parse multi argument #{String.upcase(to_string(cmd))}" do
        cmd = unquote(cmd)

        assert {:ok,
                {^cmd, "are_distinct", 4, [atom: :alaska, number: 0, number: 3.5, atom: :mars]}} =
                 Parser.eval(
                   "#{String.upcase(to_string(cmd))} are_distinct (alaska, 0, 3.5, mars)"
                 )
      end
    end

    test "should parse single variable QUERY" do
      assert {:ok, {:query, "is_odd", 1, [var: :X]}} = Parser.eval("QUERY is_odd (X)")
    end

    test "should parse multi variable QUERY" do
      assert {:ok, {:query, "is_same", 2, [{:var, :X}, {:var, :X}]}} =
               Parser.eval("QUERY is_same (X, X)")
    end

    test "should parse QUERY with different variables" do
      assert {:ok, {:query, "are_dudes", 3, [{:var, :X}, {:var, :Y}, {:var, :Z}]}} =
               Parser.eval("QUERY are_dudes (X, Y, Z)")
    end

    test "should parse even with extra spaces and carriage return" do
      assert {:ok, {:input, "is_odd", 1, [number: 3]}} = Parser.eval("\nINPUT\n   is_odd     (3)")
    end

    test "should error on unparseable input" do
      assert {:error, "illegal characters \"#\""} = Parser.eval("# Hey dude")
    end

    test "should error input that looks like valid" do
      assert {:error, :parse_error} = Parser.eval("INPUT 12")
    end
  end

  describe "eval!/1" do
    test "should return result without :ok tuple" do
      assert {:query, "is_odd", 1, [var: :X]} = Parser.eval!("QUERY is_odd (X)")
    end

    test "should raise error" do
      assert_raise ArgumentError, ~r/^illegal characters/, fn ->
        raise Parser.eval!("# Hey dude")
      end
    end
  end

  describe "from_file/1" do
    @tag :tmp_dir
    test "can read and parse file", ctx do
      file_name = "test.txt"

      file_content = ~S"""
      INPUT is_a_cat (lucy)
      QUERY is_a_cat (lucy)
      """

      File.cd!(ctx.tmp_dir, fn ->
        File.write!(file_name, file_content)

        assert [{:input, "is_a_cat", 1, [atom: :lucy]}, {:query, "is_a_cat", 1, [atom: :lucy]}] =
                 Parser.parse_file!(file_name)
      end)
    end
  end
end
