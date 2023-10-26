defmodule Niner.Learning_Event_Utils.Learning_Event.Eth_Agent do
  # how to use:
  # 1. run the project
  # iex -S mix
  # 2. load the data
  # eth_data = Niner.Learning_Event_Utils.Learning_Event.Eth_Agent.load_data()
  # 3. split data into a training and testing/validation set (80/20 split, respectively)
  # {x_train_prep, y_train_prep} = Niner.Learning_Event_Utils.Learning_Event.Nx_A3c.split_train_test(eth_data, 0.8)
  # x_train_tensor = Nx.tensor(x_train_prep)
  # y_train_tensor = Nx.tensor(y_train_prep)
  # batch_size = 128
  # x_train = Nx.to_batched(x_train_tensor, batch_size)
  # y_train = Nx.to_batched(y_train_tensor, batch_size)
  # now you can put the x_train and y_train variables in the Axon.Loop.run function and properly train the model :)
  # 4. create and train the DNN model | example LSTM model in the create_model function below
  # eth_model = 
  # 5. calculate model MSE (not required, but useful)
  # mse = Niner.Learning_Event_Utils.Learning_Event.Eth_Agent.mse(eth_params, test)
  # 6. load the "unseen" test data to validate the model is learning instead of memorizing the training data (i.e., should be live data pulled from our DB eventually)
  # {x_test, y_test} = 
  # 7. predict some prices
  # y_hat = Niner.Learning_Event_Utils.Learning_Event.Eth_Agent.predict(eth_params, x_test)

  alias Niner.Trading_Event_Utils
  alias Niner.Trade_Event_Utils.Trade_Event
  alias Niner.Learning_Event_Utils.Learning_Event.Eth_Agent
  alias Niner.Repo
  alias Niner.Learning_Utils.Learning.Nx_a3c
  alias NimbleCSV.RFC4180, as: CSV

  import Ecto.Query
  import Axon
  import Nx
  import NimbleCSV

  # 0. load raw ETH-USD historical data from our app's priv directory | creates batch_inputs {x} and batch_labels {y}
  def load_data() do
    # load real-time price data from our database, streamed from the streamer.ex module | eventually use as test data for y_hat predictions
    # live_trade_events = from t in Trade_Event, select:
    #   %{
    #   id: t.id,
    #   product_id: t.product_id,
    #   price: t.price,
    #   order_by: [desc: t.inserted_at]
    #   }

    # test_data_prep = Repo.all(live_trade_events)    

    # clean test data + create {x, y} tensors + create input stream of eth-usd price data
    # test_data = test_data_prep |> Enum.map(&[&1.price])
    #
    # here are some functions to test what the actual stream of data looks like in human-readable format:
    # data_human_readable = "/usr/local/elixir-apps/niner/priv/ETH_USD/ETH-USD-a3c.csv" |> File.stream!() |> CSV.parse_stream() |> Enum.map(fn [date, open, high, low, close, adjclose, volume] -> [Integer.parse(date) |> elem(0), Float.parse(open) |> elem(0), Float.parse(high) |> elem(0), Float.parse(low) |> elem(0), Float.parse(close) |> elem(0), Float.parse(adjclose) |> elem(0), Integer.parse(volume) |> elem(0)] end)
    # to embed the data within an Nx tensor and check the tensor shape:
    # tensor_data = "/usr/local/elixir-apps/niner/priv/ETH_USD/ETH-USD-a3c.csv" |> File.stream!() |> CSV.parse_stream() |> Enum.map(fn [date, open, high, low, close, adjclose, volume] -> [Integer.parse(date) |> elem(0), Float.parse(open) |> elem(0), Float.parse(high) |> elem(0), Float.parse(low) |> elem(0), Float.parse(close) |> elem(0), Float.parse(adjclose) |> elem(0), Integer.parse(volume) |> elem(0)] end)
    # eth_usd_tensor = Nx.tensor(tensor_data)
    # eth_usd_tensor_shape = Nx.shape(eth_usd_tensor)
    #
    # sequence_length = 365
    # sequence_length = 180
    # sequence_length = 90
    sequence_length = 30
    # sequence_length = 1
    # sequence_features = 7
    sequence_features = 2
    # batch_size = 128
    # batch_size = 14
    # batch_size = 1
    
    eth_data =
      "/usr/local/elixir-apps/niner/priv/ETH_USD/ETH-USD-a3c.csv"
      |> File.stream!()
      |> CSV.parse_stream()
      # |> Stream.map(fn [date, open, high, low, close, adjclose, volume] ->
      |> Stream.map(fn [date, close] ->
        [
          Integer.parse(date) |> elem(0),
          # Float.parse(open) |> elem(0),
          # Float.parse(high) |> elem(0),
          # Float.parse(low) |> elem(0),
          Float.parse(close) |> elem(0)
          # Float.parse(adjclose) |> elem(0),
          # Integer.parse(volume) |> elem(0)
        ]
      end)
      |> Enum.chunk_every(sequence_length, sequence_length, :discard)
      # |> Enum.drop(-1)
      |> Nx.tensor()
      |> Nx.reshape({:auto, sequence_length, sequence_features})
      |> Nx.to_list()
  end

  # 1. create LSTM model
  # we're using a sequential model, since it's pretty simple to implement in Elixir/Axon (thanks pipe operator, based)
  # model summary: utilizing LSTM hidden layers + incremental dropout + dense layers
  def create_model() do
    # if overfitting still occurs despite the dropout layers, consider regularizing the input data before the input layer (normalizing, etc.)
    #
    # sequence_length = 365
    # sequence_length = 180
    # sequence_length = 90
    sequence_length = 30
    # sequence_length = 1
    # sequence_features = 7
    sequence_features = 2
    # batch_size = 128
    batch_size = 14
    # batch_size = 16

    eth_model =
      # the input layer | the input data shape may vary, so consider changing the 1st shape value '1980' to 'nil'
      # Axon.input("eth_usd", shape: {128, 31, 7})
      Axon.input("eth_usd", shape: {nil, sequence_length, sequence_features})
      # the 1st LSTM layer | gradually increasing the # of neurons/units with each LSTM layer helps our model develop a hierarchical representation of the data
      |> Axon.lstm(52, name: "one", activation: :linear)
      # get the output of the LSTM layer | this is fed into the dropout layer
      |> then(fn {output, _} -> output end)
      # 1st dropout layer | helps with overfitting, don't become too dependent on a single neuron/unit! | 2% dropout rate
      # https://jmlr.org/papers/v15/srivastava14a.html
      |> Axon.dropout(rate: 0.02)
      # 2nd LSTM layer
      |> Axon.lstm(26, name: "two", activation: :linear)
      # get the output of the LSTM layer | feed into the dropout layer
      |> then(fn {output, _} -> output end)
      # 2nd droput layer
      |> Axon.dropout(rate: 0.02)
      # the output layer
      # we want to use the date feature/column as the input prompt to return the predicted price data 
      # |> Axon.dense(343, activation: :linear)
      # |> Axon.dense(49, activation: :linear)
      # |> Axon.dense(7, activation: :linear)
      |> Axon.dense(2, activation: :linear)
  end

  # 2. train LSTM model
  def train_model(eth_model) do
    batch_size = 14

    eth_data = Niner.Learning_Event_Utils.Learning_Event.Eth_Agent.load_data()
    # split the data into training and testing sets + minimal normalization
    {x_train_prep, y_train_prep} = Niner.Learning_Event_Utils.Learning_Event.Nx_A3c.split_train_test(eth_data, 0.8)
    x_train_tensor = Nx.tensor(x_train_prep) |> Nx.divide(4000)
    y_train_tensor = Nx.tensor(y_train_prep) |> Nx.divide(4000)
    x_train = Nx.to_batched(x_train_tensor, batch_size)
    y_train = Nx.to_batched(y_train_tensor, batch_size)
    eth_data_final = Stream.zip(x_train, y_train)

    eth_model_training_params =
      # train LSTM model using supervised training loop
      # we are using Axon's built in MSE loss function for now, but we will eventually replace it with our custom A3C loss function (nx_a3c.ex)
      eth_model
      |> Axon.Loop.trainer(:mean_squared_error, Axon.Optimizers.adamw(0.0005), log: 50)
      |> Axon.Loop.run(eth_data_final, %{}, epochs: 40, compiler: EXLA, debug: true)
  end

  # 3. predict ETH prices using trained model
  def predict_prices(eth_model, eth_model_training_params) do
    # 2. predict prices using our trained model
    # calculate y_hat given x-test
    x_test = [[1980, 2012.63]] |> Enum.chunk_every(1, 1, :discard) |> Nx.tensor() |> Nx.reshape({:auto, 1, 2})
    y_hat = Axon.predict(eth_model, eth_model_training_params, x_test, compiler: EXLA)
  end

end
