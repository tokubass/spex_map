defmodule SpexMap.Responses do
  def build(responses) do
    Enum.reduce(responses, %{}, fn {status_code, resp}, acc ->
      content =
        if resp[:content] do
          # spex側が複数content_typeに対応してない
          first_media_type = Map.keys(resp[:content]) |> hd
          schema = resp[:content][first_media_type][:schema]
          schema = case Map.has_key?(schema, :"$ref") do
            true -> struct!(OpenApiSpex.Reference, schema)
            false -> SpexMap.Schema.build(schema)
          end

          %{
            Atom.to_string(first_media_type) => %OpenApiSpex.MediaType{
              schema: schema
              # example: opts[:example], todo
              # examples: opts[:examples]
            }
          }
        else
          nil
        end

      spex_res =
        struct!(OpenApiSpex.Response, %{
          description: resp[:description],
          # todo
          headers: nil,
          content: content,
          links: nil
        })

      {status_code, _} = status_code |> to_string |> Integer.parse()
      Map.put(acc, status_code, spex_res)
    end)
  end
end
