defmodule SpexMap.Info do
  @moduledoc """
  Documentation for SpexMap.
  """

  def build(info) do
    %OpenApiSpex.Info{
      title: Map.get(info, :title),
      version: Map.get(info, :version),
      description: Map.get(info, :description),
      termsOfService: Map.get(info, :termsOfService),

      # todo
      contact: nil,
      license: nil
    }
  end
end
