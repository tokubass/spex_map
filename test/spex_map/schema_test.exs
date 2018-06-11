defmodule SpexMap.SchemaTest do
  use ExUnit.Case

  test "schema" do
    schema = %{
      "properties" => %{
        "content" => %{"type" => "string"},
        "cseq" => %{"type" => "integer"},
        "from" => %{
          "example" => ["9044954413554896275", "8551160555686155840"],
          "items" => %{"pattern" => "^[0-9]+", "type" => "string"},
          "type" => "array"
        },
        "profile" => %{"$ref" => "#/components/schemas/Profile"}
      },
      "type" => "object"
    }

    schema = SpexMap.Util.recursive_convert_to_atom(schema)

    assert SpexMap.Schema.build(schema) == %OpenApiSpex.Schema{
             type: :object,
             properties: %{
               content: %OpenApiSpex.Schema{type: :string},
               cseq: %OpenApiSpex.Schema{type: :integer},
               from: %OpenApiSpex.Schema{
                 example: ["9044954413554896275", "8551160555686155840"],
                 items: %{pattern: "^[0-9]+", type: :string},
                 type: :array
               },
               profile: %OpenApiSpex.Reference{"$ref": "#/components/schemas/Profile"}
             }
           }
  end
end
