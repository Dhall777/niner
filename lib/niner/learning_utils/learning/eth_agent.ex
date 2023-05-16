defmodule Niner.Learning_Event_Utils.Learning_Event.Eth_Agent do
  # how to use:
  # 1. run the project
  # iex -S mix
  # 2. load the data
  # data = Niner.Learning_Event_Utils.Learning_Event.Eth_Agent.load_data()
  # 3. split data into training and test sets (80/20 respectively)
  # {train, test} = Niner.Learning_Event_Utils.Learning_Event.Nx_A3c.train_test_split(data, 0.8)
  # 4. create the DNN model
  # model = 
  # 5. train the model; generates the learned parameters
  # params = Niner.Learning_Event_Utils.Learning_Event.Eth_Agent.train(train)
  # 5a. calculate MSE (on test data)
  # mse = Niner.Learning_Event_Utils.Learning_Event.Eth_Agent.mse(params, test)
  # 6. get the test data
  # {x_test, y_test} = Enum.unzip(test)
  # 7. predict some prices
  # y_hat = Niner.Learning_Event_Utils.Learning_Event.Eth_Agent.predict(params, x_test)

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
    # here's a function to test what the actual stream of data looks like in human-readable format:
    # data_human_readable = "/usr/local/elixir-apps/niner/priv/ETH_USD/ETH-USD-a3c.csv" |> File.stream!() |> CSV.parse_stream() |> Enum.map(fn [date, open, high, low, close, adjclose, volume] -> [Integer.parse(date) |> elem(0), Float.parse(open) |> elem(0), Float.parse(high) |> elem(0), Float.parse(low) |> elem(0), Float.parse(close) |> elem(0), Float.parse(adjclose) |> elem(0), Integer.parse(volume) |> elem(0)] end)
    # to embed the data within an Nx tensor and check it the tensor shape:
    # tensor_data = "/usr/local/elixir-apps/niner/priv/ETH_USD/ETH-USD-a3c.csv" |> File.stream!() |> CSV.parse_stream() |> Enum.map(fn [date, open, high, low, close, adjclose, volume] -> [Integer.parse(date) |> elem(0), Float.parse(open) |> elem(0), Float.parse(high) |> elem(0), Float.parse(low) |> elem(0), Float.parse(close) |> elem(0), Float.parse(adjclose) |> elem(0), Integer.parse(volume) |> elem(0)] end)
    # eth_usd_tensor = Nx.tensor(tensor_data)
    # eth_usd_tensor_shape = Nx.shape(eth_usd_tensor)
    eth_data =
      "/usr/local/elixir-apps/niner/priv/ETH_USD/ETH-USD-a3c.csv"
      |> File.stream!()
      |> CSV.parse_stream()
      |> Stream.map(fn [date, open, high, low, close, adjclose, volume] ->
        [
          Integer.parse(date) |> elem(0),
          Float.parse(open) |> elem(0),
          Float.parse(high) |> elem(0),
          Float.parse(low) |> elem(0),
          Float.parse(close) |> elem(0),
          Float.parse(adjclose) |> elem(0),
          Integer.parse(volume) |> elem(0)
        ]
      end)
  end

  # create Axon model | to be used for the training loop
  # we're using a sequential LSTM model, since it's pretty simple to implement in Elixir/Axon using the pipe operator
  # in the near future, i will implement a reinforcement learning model and compare its performance against the LSTM model in price prediction tasks
  # i don't think Axon has modules supporting graph NNs or multi-headed attention mechanisms, but keep an eye out for that
  def create_model_lstm(eth_data) do
    # (describe your model here)
    model = 
      Axon.input("eth_usd", shape: {1980, 7})
      |> Axon.lstm(50)
  end

  # train model using supervised training loop
  # we are using Axon's built in loss function for now, but we will eventually replace it with our custom A3C loss function (nx_a3c.ex)
  def train_model_lstm() do
    # use Axon utils to train model
  end

  # evaluate model against test data
  def evaluate_model(model_state) do
    # use Axon utils to evaluate model
  end
end
