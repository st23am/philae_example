defmodule Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def up do
     [ "CREATE TABLE IF NOT EXISTS players(id serial primary key, name text, score integer, mongo_id text)",
      "INSERT INTO players (name) VALUES ('inserted')" ]
  end

  def down do
    "DROP TABLE players"
  end
end
