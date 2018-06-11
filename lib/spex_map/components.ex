defmodule SpexMap.Components do
  alias SpexMap.Schema

  def build(components) do
    schemas = components[:schemas] |>
      Enum.reduce(%{}, fn(x, acc) ->
        {name, schema} = x
        Map.put( acc, Atom.to_string(name), Schema.build(schema) )
      end)

    %OpenApiSpex.Components{
      schemas: schemas
    }
  end
end
