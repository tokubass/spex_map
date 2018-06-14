defmodule SpexMap.Util do
  def convert_all(schema) do
    schema
    |> SpexMap.Util.RecursiveConvert.Atom.convert()
    |> SpexMap.Util.RecursiveConvert.ReferenceObject.convert()
  end

  defmodule RecursiveConvert.Atom do
    def convert(schema) when is_map(schema) do
      for {key, val} <- schema, into: %{} do
        val = convert(val)

        {String.to_atom(key), val}
      end
    end

    def convert(list) when is_list(list) do
      for schema <- list do
        convert(schema)
      end
    end

    @types ["boolean", "integer", "number", "string", "array", "object"]
    @location ["query", "path", "header", "cookie"]
    @convert_target @types ++ @location
    def convert(type) when is_binary(type) and type in @convert_target do
      String.to_atom(type)
    end

    def convert(leaf), do: leaf
  end

  defmodule RecursiveConvert.ReferenceObject do
    def convert(%{"$ref": ref_path}) do
      %OpenApiSpex.Reference{"$ref": ref_path}
    end

    def convert(schema) when is_map(schema) do
      for {key, val} <- schema, into: %{} do
        case key do
          key -> {key, convert(val)}
        end
      end
    end

    def convert(list) when is_list(list) do
      for schema <- list do
        convert(schema)
      end
    end

    def convert(leaf), do: leaf
  end
end
