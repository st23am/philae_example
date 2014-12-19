defmodule Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def up do
     [ "CREATE TABLE IF NOT EXISTS players(mongo_id varchar(255) primary key, name text, score integer)"]
  end

  def down do
    "DROP TABLE players"
  end
end
