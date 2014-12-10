defmodule PlayerVoter do
  use Application

  def start do
    PlayerVoter.Supervisor.start_link(__MODULE__, [], [])
  end
end

