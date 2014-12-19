require Logger

defmodule PlayerSync do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init([]) do
    {:ok, client_pid } = Philae.DDP.connect("ws://localhost:3000/websocket", __MODULE__, self)
    {collection, id} = Philae.DDP.subscribe(client_pid, "players")
    {:ok, %{client_pid: client_pid, subscription_id: id, collection: collection}}
  end

  def added(pid, message) do
    GenServer.call(pid, {:added, message})
  end

  def changed(pid, message) do
    GenServer.call(pid, {:changed, message})
  end

  def connected(_pid, _message) do
    Logger.info("Connected to the player collection")
  end

  def ready(_pid, _message) do
    Logger.info("Collection is ready")
  end

  def handle_call({:added, %{"fields" => fields, "id" => mongo_id} = message}, _from, state) do
    Logger.info "PlayerVoter recieved added msg:" <> inspect message
    Player.create_or_update_by_mongo_id(mongo_id, fields)
    {:reply, :ok, state}
  end

  def handle_call({:changed, %{"fields" => fields, "id" => mongo_id} = message}, _from, state) do
    Logger.info "PlayerVoter recieved changed msg:" <> inspect message
    Player.create_or_update_by_mongo_id(mongo_id, fields)
    {:reply, :ok, state}
  end

  def handle_call(message, _from, state) do
    Logger.info "PlayerVoter recieved msg:" <> inspect message
    {:reply, :ok, state}
  end
end

