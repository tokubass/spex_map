defmodule SpexMapTest do
  use ExUnit.Case

  test "load spec" do
    spec = YamlElixir.read_from_file!("test/test.yaml")
    SpexMap.load(spec)
  end
end
