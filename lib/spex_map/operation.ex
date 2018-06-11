defmodule SpexMap.Operation do
  alias OpenApiSpex.{
    Callback,
    ExternalDocumentation,
    MediaType,
    Parameter,
    Reference,
    RequestBody,
    Response,
    Responses,
    Schema,
    SecurityRequirement,
    Server
  }

  def build(op) do
    %OpenApiSpex.Operation{
      responses: SpexMap.Responses.build(op[:responses]),
      requestBody: SpexMap.RequestBody.build(op[:requestBody]),
      parameters: build_parameters(op[:parameters])
    }
  end

  def build_parameters(nil), do: nil

  def build_parameters(parameters) do
    Enum.map(parameters, fn param ->
      {name, param} = Map.pop(param, :name)
      {location, param} = Map.pop(param, :in)
      {schema, param} = Map.pop(param, :schema)
      {description, param} = Map.pop(param, :description)

      OpenApiSpex.Operation.parameter(
        name |> String.to_atom(),
        # OpenApiSpex.Parameter.location
        location,
        # Reference.t | Schema.t | atom
        schema[:type],
        description,
        Enum.map(param, fn {k, v} -> {k, v} end)
      )
    end)
  end

  @doc """
  Cast params to the types defined by the schemas of the operation parameters and requestBody
  """
  @spec cast(OpenApiSpex.Operation.t(), Conn.t(), String.t() | nil, %{String.t() => Schema.t()}) ::
          {:ok, map} | {:error, String.t()}
  def cast(operation = %OpenApiSpex.Operation{}, conn = %Plug.Conn{}, content_type, schemas) do
    parameters =
      Enum.filter(operation.parameters || [], fn p ->
        Map.has_key?(conn.params, Atom.to_string(p.name))
      end)

    with :ok <- check_query_params_defined(conn, operation.parameters),
         {:ok, parameter_values} <- cast_parameters(parameters, conn.params, schemas),
         {:ok, body} <-
           cast_request_body(operation.requestBody, conn.params, content_type, schemas) do
      {:ok, Map.merge(parameter_values, body)}
    end
  end

  @spec check_query_params_defined(Conn.t(), list | nil) :: :ok | {:error, String.t()}
  defp check_query_params_defined(%Plug.Conn{} = conn, defined_params)
       when is_nil(defined_params) do
    case conn.query_params do
      %{} -> :ok
      _ -> {:error, "No query parameters defined for this operation"}
    end
  end

  defp check_query_params_defined(%Plug.Conn{} = conn, defined_params)
       when is_list(defined_params) do
    defined_query_params =
      for param <- defined_params,
          param.in == :query,
          into: MapSet.new(),
          do: to_string(param.name)

    case validate_parameter_keys(Map.keys(conn.query_params), defined_query_params) do
      {:error, param} -> {:error, "Undefined query parameter: #{inspect(param)}"}
      :ok -> :ok
    end
  end

  @spec validate_parameter_keys([String.t()], MapSet.t()) :: {:error, String.t()} | :ok
  defp validate_parameter_keys([], _defined_params), do: :ok

  defp validate_parameter_keys([param | params], defined_params) do
    case MapSet.member?(defined_params, param) do
      false -> {:error, param}
      _ -> validate_parameter_keys(params, defined_params)
    end
  end

  @spec cast_parameters([Parameter.t()], map, %{String.t() => Schema.t()}) ::
          {:ok, map} | {:error, String.t()}
  defp cast_parameters([], _params, _schemas), do: {:ok, %{}}

  defp cast_parameters([p | rest], params = %{}, schemas) do
    with {:ok, cast_val} <-
           Schema.cast(Parameter.schema(p), params[Atom.to_string(p.name)], schemas),
         {:ok, cast_tail} <- cast_parameters(rest, params, schemas) do
      {:ok, Map.put_new(cast_tail, p.name, cast_val)}
    end
  end

  @spec cast_request_body(RequestBody.t() | nil, map, String.t() | nil, %{
          String.t() => Schema.t()
        }) :: {:ok, map} | {:error, String.t()}
  defp cast_request_body(nil, _, _, _), do: {:ok, %{}}

  defp cast_request_body(%RequestBody{content: content}, params, content_type, schemas) do
    schema = content[content_type].schema
    Schema.cast(schema, params, schemas)
  end

  @doc """
  Validate params against the schemas of the operation parameters and requestBody
  """
  @spec validate(OpenApiSpex.Operation.t(), Conn.t(), String.t() | nil, %{
          String.t() => Schema.t()
        }) :: :ok | {:error, String.t()}
  def validate(operation = %OpenApiSpex.Operation{}, conn = %Plug.Conn{}, content_type, schemas) do
    with :ok <- validate_required_parameters(operation.parameters || [], conn.params),
         parameters <-
           Enum.filter(operation.parameters || [], &Map.has_key?(conn.params, &1.name)),
         {:ok, remaining} <- validate_parameter_schemas(parameters, conn.params, schemas),
         :ok <- validate_body_schema(operation.requestBody, remaining, content_type, schemas) do
      :ok
    end
  end

  @spec validate_required_parameters([Parameter.t()], map) :: :ok | {:error, String.t()}
  defp validate_required_parameters(parameter_list, params = %{}) do
    required =
      parameter_list
      |> Stream.filter(fn parameter -> parameter.required end)
      |> Enum.map(fn parameter -> parameter.name end)

    missing = required -- Map.keys(params)

    case missing do
      [] -> :ok
      _ -> {:error, "Missing required parameters: #{inspect(missing)}"}
    end
  end

  @spec validate_parameter_schemas([Parameter.t()], map, %{String.t() => Schema.t()}) ::
          {:ok, map} | {:error, String.t()}
  defp validate_parameter_schemas([], params, _schemas), do: {:ok, params}

  defp validate_parameter_schemas([p | rest], params, schemas) do
    with :ok <- Schema.validate(Parameter.schema(p), params[p.name], schemas),
         {:ok, remaining} <- validate_parameter_schemas(rest, params, schemas) do
      {:ok, Map.delete(remaining, p.name)}
    end
  end

  @spec validate_body_schema(RequestBody.t() | nil, map, String.t() | nil, %{
          String.t() => Schema.t()
        }) :: :ok | {:error, String.t()}
  defp validate_body_schema(nil, _, _, _), do: :ok

  defp validate_body_schema(%RequestBody{required: false}, params, _content_type, _schemas)
       when map_size(params) == 0 do
    :ok
  end

  defp validate_body_schema(%RequestBody{content: content}, params, content_type, schemas) do
    content
    |> Map.get(content_type)
    |> Map.get(:schema)
    |> Schema.validate(params, schemas)
  end
end
