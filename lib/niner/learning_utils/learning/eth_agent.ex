defmodule Niner.Learning_Event_Utils.Learning_Event.Eth_Agent do
  alias Niner.Trading_Event_Utils
  alias Niner.Trade_Event_Utils.Trade_Event
  alias Niner.Repo
  # alias Niner.Learning_Utils.Learning.Eth_Async_Adv_Ac
  alias NimbleCSV.RFC4180, as: CSV

  import Ecto.Query
  import Axon
  import Nx
  import Bumblebee
  import TableRex
  import NimbleCSV
  import Scholar
  import Explorer

  def load_data() do
    # load real-time price data from our database, streamed from the streamer.ex module | eventually use as test data for y_hat predictions
    # all_trade_events = from t in Trade_Event, select:
    #   %{
    #   id: t.id,
    #   product_id: t.product_id,
    #   price: t.price,
    #   order_by: [desc: t.inserted_at]
    #   }

    # test_data_prep = Repo.all(all_trade_events)    

    # clean test data + create {x, y} tensors + create input stream of eth-usd price data
    # test_data = test_data_prep |> Enum.map(&[&1.price])

    # load ETH-USD historical data from our app's priv directory | creates batch_inputs {x} and batch_labels {y}
    data =
      "/usr/local/elixir-apps/niner/priv/ETH_USD/ETH-USD-a3c.csv"
      |> File.stream!()
      |> CSV.parse_stream()
      |> Stream.map(fn [date, open, high, low, close, adjclose, volume] ->
        {
          Integer.parse(date) |> elem(0),
          Float.parse(close) |> elem(0),
          Float.parse(open) |> elem(0),
          Float.parse(high) |> elem(0),
          Float.parse(low) |> elem(0),
          Float.parse(close) |> elem(0),
          Float.parse(adjclose) |> elem(0),
          Integer.parse(volume) |> elem(0)
        }
      end)
  end

  # create Axon model | to be used for the training loop
  # we're using a sequential model, since it's so simple to implement in Elixir/Axon using the pipe operator
  def create_model() do
    # use Axon utils to create sequential model from appropriate data (e.g., ETH-USD)
    # 
    Axon.input(data)
    |> Axon.lstm(50)
  end

  # train model using supervised training loop
  def train_model() do
    # use Axon utils to train model
  end

  # evaluate model against test data
  def evaluate_model(model_state) do
    # use Axon utils to evaluate model
  end
end
