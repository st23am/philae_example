defmodule PlayerVoter do
  use Application

  def start do
    PlayerCollectionSupervisor.start_link()
  end
end

