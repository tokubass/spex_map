defmodule SpexMap.RequestBody do
  def build(nil), do: nil

  def build(request_body) do
    media_type = Map.keys(request_body[:content]) |> hd

    OpenApiSpex.Operation.request_body(
      request_body[:description] || "",
      media_type,
      request_body[:content][media_type][:schema],
      required: request_body[:required] || false
      # todo: example, examples
    )
  end
end
