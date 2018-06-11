defmodule SpexMap.Util do
  def recursive_convert_to_atom(schema) when is_map(schema) do
    for {key, val} <- schema, into: %{} do
      val = recursive_convert_to_atom(val)

      {String.to_atom(key), val}
    end
  end

  def recursive_convert_to_atom(list) when is_list(list) do
    for schema <- list do
      recursive_convert_to_atom(schema)
    end
  end

  @types ["boolean", "integer", "number", "string", "array", "object"]
  @location  ["query", "path", "header", "cookie"]
  @convert_target @types ++ @location
  def recursive_convert_to_atom(type)
      when is_binary(type) and
             type in @convert_target do
    String.to_atom(type)
  end

  def recursive_convert_to_atom(leaf), do: leaf
end
