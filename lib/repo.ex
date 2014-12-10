defmodule Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres

  def conf do
    parse_url "ecto://localhost/player_voter_development"
  end

  def priv do
    app_dir(:player_voter, "priv/repo")
  end
end
