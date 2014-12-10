PlayerVoter
===========


Install the Philae hex package in your mix.exs

```elixir
defmodule PlayerVoter.Mixfile do
  use Mix.Project

  def project do
    [app: :player_voter,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:philae, git: "https//github.com/st23am/philae.git"},
     {:postgrex, ">= 0.0.0"},
     {:ecto, "~> 0.2.5"},
    ]
  end
end
```

Setup a GenServer or some module to recieve calls from Philae

```elixir
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

  def connected(_pid, _message) do
    Logger.info("Connected to the player collection")
  end

  def ready(_pid, _message) do
    Logger.info("Collection is ready")
  end

  def handle_call({:added, %{"fields" => %{"name" => name, "score" => score}, "id" => mongo_id} = message}, _from, state) do
    Logger.info "PlayerVoter recieved added msg:" <> inspect message
    player_record = %Player{name: name, score: score, mongo_id: mongo_id}
    Repo.insert(player_record)
    Logger.info "Inserted Player" <> inspect(player_record) <> "into the Repo"
    {:reply, :ok, state}
  end

  def handle_call(message, _from, state) do
    Logger.info "PlayerVoter recieved msg:" <> inspect message
    {:reply, :ok, state}
  end
end
```

Start the leaderboard app
```meteor
 ~/src/elixir/philae_example (master*) $ cd leaderboard/
 ~/src/elixir/philae_example/leaderboard (master*) $ meteor
[[[[[ ~/src/elixir/philae_example/leaderboard ]]]]]

=> Started proxy.

=> Meteor 1.0.1: Fixes a security issue in allow/deny rules that could
   result in data loss.
      More information at https://www.meteor.com/patch-1.0.1

         This release is being downloaded in the background. Update your
         app to
            Meteor 1.0.1 by running 'meteor update'.

            => Started MongoDB.
            => Started your app.

            => App running at: http://localhost:3000/

```

Start our PlayerCollectionSupervisor in IEx
```elixir
¶ ~/src/elixir/player_voter $ iex -S mix
Erlang/OTP 17 [erts-6.2] [source] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Interactive Elixir (1.0.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> PlayerCollectionSupervisor.start_link

08:54:37.566 [info]  In: {"server_id":"0"}

08:54:37.581 [info]  Unhandled message received %{"server_id" => "0"}

08:54:37.581 [info]  Out: {"version":"1","support":["1","pre2","pre1"],"msg":"connect"}

08:54:37.582 [info]  In: {"msg":"connected","session":"Hp6Q8RhrwdZHG7hr5"}

08:54:37.583 [info]  Connected to the player collection

08:54:37.583 [info]  Out: {"name":"players","msg":"sub","id":"576ba71e-2155-478d-aca6-fdaae56a8c4f"}

08:54:37.584 [info]  In: {"msg":"added","collection":"players","id":"EDwgtEt6weAn7hXXa","fields":{"name":"Ada Lovelace","score":55}}

08:54:37.594 [info]  PlayerVoter recieved added msg:%{"collection" => "players", "fields" => %{"name" => "Ada Lovelace", "score" => 55}, "id" => "EDwgtEt6weAn7hXXa", "msg" => "added"}
{:ok, #PID<0.144.0>}
iex(2)>
08:54:37.631 [info]  Inserted Player%Player{id: nil, mongo_id: "EDwgtEt6weAn7hXXa", name: "Ada Lovelace", score: 55}into the Repo

08:54:37.631 [info]  In: {"msg":"added","collection":"players","id":"4J7BzXDpupHHFyhC8","fields":{"name":"Grace Hopper","score":75}}

08:54:37.631 [info]  PlayerVoter recieved added msg:%{"collection" => "players", "fields" => %{"name" => "Grace Hopper", "score" => 75}, "id" => "4J7BzXDpupHHFyhC8", "msg" => "added"}

08:54:37.644 [info]  Inserted Player%Player{id: nil, mongo_id: "4J7BzXDpupHHFyhC8", name: "Grace Hopper", score: 75}into the Repo

08:54:37.644 [info]  In: {"msg":"added","collection":"players","id":"jbeTgrLuctE5tFjKd","fields":{"name":"Marie Curie","score":40}}

08:54:37.644 [info]  PlayerVoter recieved added msg:%{"collection" => "players", "fields" => %{"name" => "Marie Curie", "score" => 40}, "id" => "jbeTgrLuctE5tFjKd", "msg" => "added"}

08:54:37.659 [info]  Inserted Player%Player{id: nil, mongo_id: "jbeTgrLuctE5tFjKd", name: "Marie Curie", score: 40}into the Repo

08:54:37.659 [info]  In: {"msg":"added","collection":"players","id":"S8kC3ze7T8DpxLdM3","fields":{"name":"Carl Friedrich Gauss","score":60}}

08:54:37.659 [info]  PlayerVoter recieved added msg:%{"collection" => "players", "fields" => %{"name" => "Carl Friedrich Gauss", "score" => 60}, "id" => "S8kC3ze7T8DpxLdM3", "msg" => "added"}

08:54:37.671 [info]  Inserted Player%Player{id: nil, mongo_id: "S8kC3ze7T8DpxLdM3", name: "Carl Friedrich Gauss", score: 60}into the Repo

08:54:37.671 [info]  In: {"msg":"added","collection":"players","id":"AC96Gf6YhaWt74dTR","fields":{"name":"Nikola Tesla","score":70}}

08:54:37.671 [info]  PlayerVoter recieved added msg:%{"collection" => "players", "fields" => %{"name" => "Nikola Tesla", "score" => 70}, "id" => "AC96Gf6YhaWt74dTR", "msg" => "added"}

08:54:37.684 [info]  Inserted Player%Player{id: nil, mongo_id: "AC96Gf6YhaWt74dTR", name: "Nikola Tesla", score: 70}into the Repo

08:54:37.684 [info]  In: {"msg":"added","collection":"players","id":"Ya2LCwnNyFxWraDfD","fields":{"name":"Claude Shannon","score":25}}

08:54:37.684 [info]  PlayerVoter recieved added msg:%{"collection" => "players", "fields" => %{"name" => "Claude Shannon", "score" => 25}, "id" => "Ya2LCwnNyFxWraDfD", "msg" => "added"}

08:54:37.687 [info]  Inserted Player%Player{id: nil, mongo_id: "Ya2LCwnNyFxWraDfD", name: "Claude Shannon", score: 25}into the Repo

08:54:37.687 [info]  In: {"msg":"ready","subs":["576ba71e-2155-478d-aca6-fdaae56a8c4f"]}

08:54:37.687 [info]  Collection is ready

08:55:07.581 [info]  In: {"msg":"ping"}

08:55:07.582 [info]  Out: {"msg":"pong"}
```

** TODO: Add description **
