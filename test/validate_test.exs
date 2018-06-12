defmodule SpexMap.ValidateTest do
  use ExUnit.Case

  test "validate" do
    spex = YamlElixir.read_from_file!("test/test.yaml") |> SpexMap.load()
    schema = spex.paths["/v1/foo/user"].get.responses[200].content["application/json"].schema
    params = %{url: "hog"}

    assert {:ok, data} = SpexMap.cast(spex, schema, params)
    :ok = SpexMap.validate(spex, schema, data)
  end
end
