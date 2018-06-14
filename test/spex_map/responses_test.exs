defmodule SpexMap.ResponsesTest do
  use ExUnit.Case
  alias SpexMap.Util

  describe "responses" do
    test "normal" do
      responses = %{
        "200" => %{
          "content" => %{
            "application/json" => %{
              "schema" => %{
                "properties" => %{"code" => %{"type" => "string"}},
                "type" => "object"
              }
            }
          },
          "description" => "OK"
        },
        "404" => %{"description" => "not found"}
      }

      responses = Util.convert_all(responses)
      schema = SpexMap.Schema.build(responses[:"200"][:content][:"application/json"][:schema])

      assert SpexMap.Responses.build(responses) == %{
               200 => %OpenApiSpex.Response{
                 description: "OK",
                 content: %{
                   "application/json" => %OpenApiSpex.MediaType{schema: schema}
                 }
               },
               404 => %OpenApiSpex.Response{description: "not found"}
             }
    end
  end
end
