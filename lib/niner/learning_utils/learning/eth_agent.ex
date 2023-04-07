defmodule Niner.Learning_Event_Utils.Learning_Event.Eth_Agent do
  alias Niner.Trading_Event_Utils
  alias Niner.Trade_Event_Utils.Trade_Event
  alias Niner.Repo
  import Ecto.Query
  import Axon
  import Nx
  import Bumblebee
  import TableRex
  import CSV
  # use GenServer

  def eth_model do
    # load historical price data from our DB (for now) | get more historical data somewhere else for free + collect my own data using cb_streamer.ex 
    all_trade_events = from t in Trade_Event, select:
      %{
      id: t.id,
      product_id: t.product_id,
      price: t.price,
      order_by: [desc: t.inserted_at]
      }

    historical_data_prep = Repo.all(all_trade_events)    

    # clean historical data + create {x, y} tensors + create input stream of eth-usd price data
    historical_data = historical_data_prep |> Enum.map(&[&1.price])

    eth_usd_x_tensor = Nx.tensor(historical_data, names: [:eth_usd, nil])
    # (y) eventually use downloaded ETH-USD historical data for batch labels/output, just reusing input data for now
    eth_usd_y_tensor = Nx.tensor(historical_data, names: [:eth_usd, nil])

    input_data_stream =
      Stream.repeatedly(fn ->
        xs = eth_usd_x_tensor
        ys = eth_usd_y_tensor
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
      |> Axon.Loop.run(input_data_stream, %{}, epochs: 10, iterations: 500)

  end

end
