defmodule SpexMap.OperationTest do
  use ExUnit.Case

  describe "parameters" do
    test "normal" do
      params = %{
        "parameters" => [
          %{
            "in" => "query",
            "name" => "user_id",
            "schema" => %{"type" => "string"},
            "required" => true
          },
          %{
            "in" => "query",
            "name" => "age",
            "schema" => %{"type" => "integer"}
          }
        ]
      } |>  SpexMap.Util.recursive_convert_to_atom()
      
     assert SpexMap.Operation.build_parameters(params[:parameters])  == [
               %OpenApiSpex.Parameter{
                 in: :query,
                 name: :user_id,
                 required: true,
                 schema: %OpenApiSpex.Schema{
                   type: :string
                 }
               },
               %OpenApiSpex.Parameter{
                 in: :query,
                 name: :age,
                 required: false,
                 schema: %OpenApiSpex.Schema{
                   type: :integer
                 }
               }
             ]
    end
  end
end
