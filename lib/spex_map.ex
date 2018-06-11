defmodule SpexMap do
  @moduledoc """
  Documentation for SpexMap.
  """

  alias OpenApiSpex.{OpenApi, Operation, Reference, Schema, SchemaResolver}

  def load(spec) do
    spec = SpexMap.Util.recursive_convert_to_atom(spec)
    
    %OpenApiSpex.OpenApi{
      openapi: spec[:openapi],
      info: SpexMap.Info.build(spec[:info]),
      servers: [],
      paths: SpexMap.Paths.build(spec[:paths]),
      components: SpexMap.Components.build(spec[:components])
     }
  end

  @doc """
  Cast params to conform to a Schema or Operation spec.
  """

  @spec cast(OpenApi.t, Schema.t | Reference.t | Operation.t, any) :: {:ok, any} | {:error, String.t}
  def cast(spec = %OpenApi{}, schema = %Schema{}, params) do
    Schema.cast(schema, params, spec.components.schemas)
  end
  def cast(spec = %OpenApi{}, schema = %Reference{}, params) do
    Schema.cast(schema, params, spec.components.schemas)
  end
  def cast(spec = %OpenApi{}, operation = %Operation{}, conn = %Plug.Conn{}, content_type \\ nil) do
    Operation.cast(operation, conn, content_type, spec.components.schemas)
  end

  @doc """
  Validate params against a Schema or Operation spec.
  """
  def validate(spec = %OpenApi{}, schema = %Schema{}, params) do
    Schema.validate(schema, params, spec.components.schemas)
  end
  def validate(spec = %OpenApi{}, schema = %Reference{}, params) do
    Schema.validate(schema, params, spec.components.schemas)
  end
  def validate(spec = %OpenApi{}, operation = %Operation{}, conn = %Plug.Conn{}, content_type \\ nil) do
    Operation.validate(operation, conn, content_type, spec.components.schemas)
  end

end
