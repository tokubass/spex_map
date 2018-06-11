defmodule SpexMap.Paths do
  def build(paths) do
    for {path, item} <- paths, into: %{} do
      {Atom.to_string(path), SpexMap.PathItem.build(item)}
    end
  end
end
