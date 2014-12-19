require Logger

defmodule Player do
  use Ecto.Model
  import Ecto.Query

  schema "players", primary_key: {:mongo_id, :string, []} do
    field :name,  :string
    field :score, :integer
  end

  def find_player_by_mongo_id(mongoid) do
    query = from(p in Player,
                 where: p.mongo_id == ^mongoid)
    Repo.all(query)
  end

  def create_or_update_by_mongo_id(mongoid, fields) do
    fields = Map.delete(fields, :id)
    Repo.transaction(fn ->
      case find_player_by_mongo_id(mongoid) do
        [] ->
          player = Repo.insert(fields)
          Logger.info "Inserted Player" <> inspect(player) <> "into the Repo"
        [record] ->
          updated_fields = different_fields(record, atomize_keys(fields))
          player = update_player(record, updated_fields)
      end
    end)
  end

  def update_player(record, updated_fields) when updated_fields == %{} do
    record
    Logger.info "No need to update " <> inspect(record) <> " - no changes"
  end

  def update_player(record, updated_fields) do
    new_player = Map.merge(record, updated_fields)
    :ok = Repo.update(new_player)
    Logger.info "Updated Player" <> inspect(new_player) <> "into the Repo"
    new_player
  end

  def different_fields(original, updated) do
    original_hash = Map.to_list(original) |> Enum.into(HashSet.new)
    updated_hash = Map.to_list(updated) |> Enum.into(HashSet.new)
    diff_hash = Set.difference(updated_hash, original_hash)
    updated_fields = Set.to_list(diff_hash) |> Enum.into(%{})
    Map.delete(updated_fields, :id)
  end

  def atomize_keys(map) do
    map
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end
end

