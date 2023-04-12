defmodule Niner.Learning_Event_Utils.Learning_Event.Eth_Agent do
  alias Niner.Trading_Event_Utils
  alias Niner.Trade_Event_Utils.Trade_Event
  alias Niner.Repo
  # alias Niner.Learning_Utils.Learning
  import Ecto.Query
  import Axon
  import Nx
  import Bumblebee
  import TableRex
  import NimbleCSV
  import Scholar

  def eth_model do
    # load historical price data from our own DB 
    # all_trade_events = from t in Trade_Event, select:
    #   %{
    #   id: t.id,
    #   product_id: t.product_id,
    #   price: t.price,
    #   order_by: [desc: t.inserted_at]
    #   }

    # historical_data_prep = Repo.all(all_trade_events)    

    # clean historical data + create {x, y} tensors + create input stream of eth-usd price data
    # historical_data = historical_data_prep |> Enum.map(&[&1.price]) -> for internal DB queries

    # create headers {x) for eth_usd_tensor | loading historical data as it streams in
    eth_usd_headers =
      File.stream!("/usr/local/elixir-apps/niner/priv/ETH_USD/ETH-USD.csv")
      |> Enum.at(0)
      |> String.trim()
      |> String.split(",")
    # |> Enum.with_index()
    # |> Map.new(&(&1))


    # create values (y) for eth_usd_tensor | to perform trading calculations as data streams in
    # eth_usd_values = Learning.trading_algorithms functions(eth_usd_x_tensor)
    # just a raw_list of values/rows for now, the model isn't learning anything until I implement them in Learning.trading_algorithms module
    eth_usd_values_raw_a = File.stream!("/usr/local/elixir-apps/niner/priv/ETH_USD/ETH-USD.csv") |> NimbleCSV.RFC4180.parse_enumerable() |> List.flatten()

    eth_usd_values = Enum.map(eth_usd_values_raw_a, &String.to_float/1)

    # ETH_USD tensor
    eth_usd_tensor = Nx.tensor(eth_usd_values, names: [:eth_usd, nil])    

    # create data stream for model training | need to create testing and evaluation data at some point
    input_data_stream =
      Stream.repeatedly(fn ->
        xs = eth_usd_headers
        ys = eth_usd_values
        {xs, ys}
      end)

    # create the nn model input layer + optionally fill out expected tensor shape
    inp_eth_usd = Axon.input("eth_usd", shape: {nil})

    # create the rest of the nn model (hidden layers + output layer)
    model_eth_usd = inp_eth_usd
      |> Axon.dense(128, activation: :relu)
      |> Axon.batch_norm()
      |> Axon.dropout(rate: 0.8)
      |> Axon.dense(64)
      |> Axon.tanh()
      |> Axon.dense(10)
      |> Axon.activation(:softmax)

    # train nn model using various deep reinforcement learning algorithms, then apply ensemble strategy 
    # dqn = deep q-networks | ppo = proximal policy optimization | ac  = actor-critic | a3c = asynchronous advantage actor-critic, basically sgd+rmsprop | td3 = twin delayed ddpg | ens = ensemble strategy
    # placeholder training model for now
    model_state_eth_usd = model_eth_usd
      |> Axon.Loop.trainer(:mean_squared_error, Axon.Optimizers.adam(0.0777), log: 27)
      |> Axon.Loop.run(input_data_stream, %{}, epochs: 1000, iterations: 500)

  end

end
