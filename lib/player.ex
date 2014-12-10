defmodule Player do
  use Ecto.Model

  schema "players" do
    field :mongo_id, :string
    field :name, :string
    field :score, :integer
  end
end
