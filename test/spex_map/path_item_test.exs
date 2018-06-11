defmodule SpexMap.PathItemTest do
  use ExUnit.Case

  test "path_item" do
    schema =
      %{
        "get" => %{
          "responses" => %{
            "200" => %{
              "content" => %{
                "application/json" => %{
                  "schema" => %{
                    "properties" => %{
                      "birthdate" => %{"type" => "string"},
                      "user_id" => %{"type" => "integer"}
                    },
                    "type" => "object"
                  }
                }
              },
              "description" => "OK"
            }
          }
        },
        "post" => %{
          "requestBody" => %{
            "content" => %{
              "application/json" => %{
                "schema" => %{
                  "properties" => %{
                    "birthdate" => %{
                      "format" => "^[0-9]+$",
                      "maxLength" => 8,
                      "minLength" => 8,
                      "type" => "string"
                    }
                  },
                  "required" => ["birthdate"],
                  "type" => "object"
                }
              }
            },
            "required" => true
          },
          "responses" => %{
            "200" => %{
              "content" => %{
                "application/json" => %{"schema" => %{"type" => "object"}}
              },
              "description" => "OK"
            }
          }
        }
      }
      |> SpexMap.Util.recursive_convert_to_atom()

    path_item = SpexMap.PathItem.build(schema)
    assert path_item.get.responses |> Map.has_key?(200)
    assert path_item.post.responses |> Map.has_key?(200)
  end
end
