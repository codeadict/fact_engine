defmodule FactEngineTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias FactEngine

  describe "run/1" do
    test "prints usage with no arguments" do
      assert capture_io(fn ->
               assert {:shutdown, 0} = catch_exit(FactEngine.main([]))
             end) =~ "USAGE:"
    end

    for dir <- 1..4 do
      test "passes functional test with test/fixtures/#{dir}/in.txt" do
        dir = unquote(dir)

        output =
          capture_io(fn ->
            catch_exit(FactEngine.main(["--input", "test/fixtures/#{dir}/in.txt"]))
          end)

        expected = File.read!("test/fixtures/#{dir}/out.txt")

        assert output =~ expected
      end
    end
  end
end
