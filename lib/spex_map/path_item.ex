defmodule SpexMap.PathItem do
  alias SpexMap.Schema

  def build(path_item) do
    struct!(
      OpenApiSpex.PathItem,
      Enum.map(path_item, fn {method, op} -> {method, SpexMap.Operation.build(op)} end)
    )
  end
end
