defmodule Niner.Learning_Event_Utils.Learning_Event.Eth_Agent do
  # how to use:
  # 0. run the project
  # iex -S mix
  # 1. load the ETH-USD data
  # eth_data = Niner.Learning_Event_Utils.Learning_Event.Eth_Agent.load_data()
  # 2. create the model
  # eth_model = Eth_Agent.create_model()
  # 3. train the model
  # eth_model_training_params = Eth_Agent.train_model(eth_model)
  # 4. predict prices
  # eth_predictions = Eth_Agent.predict_prices(eth_model, eth_model_training_params)

  alias Niner.Trading_Event_Utils
  alias Niner.Trade_Event_Utils.Trade_Event
  alias Niner.Learning_Event_Utils.Learning_Event.Eth_Agent
  alias Niner.Repo
  alias Niner.Learning_Utils.Learning.Data_Utils
  alias NimbleCSV.RFC4180, as: CSV

  import Ecto.Query
  import Axon
  import Nx
  import NimbleCSV

  # 0. load raw ETH-USD historical data from our app's priv directory | creates batch_inputs {x} and batch_labels {y}
  def load_data() do
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
      "/usr/local/elixir-apps/niner/priv/ETH_USD/ETH-USD.csv"
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
    sequence_length = 30
    sequence_features = 2
    batch_size = 14

    eth_model =
      # the input layer | the input data shape may vary, so consider changing the 1st shape value to 'nil'
      # Axon.input("eth_usd", shape: {52, 30, 2})
      Axon.input("eth_usd", shape: {nil, sequence_length, sequence_features})
      # the 1st LSTM layer | gradually increasing the # of neurons/units with each LSTM layer helps our model develop a hierarchical representation of the data
      |> Axon.lstm(104, name: "one", activation: :sigmoid, gate: :sigmoid)
      # get the output of the LSTM layer | this is fed into the dropout layer
      |> then(fn {output, _} -> output end)
      # 1st dropout layer | helps with overfitting, don't become too dependent on a single neuron/unit! | 2% dropout rate
      # https://jmlr.org/papers/v15/srivastava14a.html
      |> Axon.dropout(rate: 0.2)
      # 2nd LSTM layer
      |> Axon.lstm(52, name: "two", activation: :sigmoid, gate: :sigmoid)
      # get the output of the LSTM layer | feed into the dropout layer
      |> then(fn {output, _} -> output end)
      # 2nd droput layer
      |> Axon.dropout(rate: 0.2)
      # 3rd LSTM layer
      |> Axon.lstm(26, name: "three", activation: :sigmoid, gate: :sigmoid)
      # get the output of the LSTM layer | feed into the dropout layer
      |> then(fn {output, _} -> output end)
      # the output layer
      # we want to use the date feature/column as the input prompt to return the predicted price data 
      # |> Axon.dense(13, activation: :sigmoid)
      # |> Axon.dense(7, activation: :sigmoid)
      |> Axon.dense(2, activation: :sigmoid)
  end

  # 2. train LSTM model
  def train_model(eth_model) do
    batch_size = 14

    # split the data into training and testing sets -> includes minimal normalization
    eth_data = Niner.Learning_Event_Utils.Learning_Event.Eth_Agent.load_data()
    {x_train_prep, y_test_prep} = Niner.Learning_Event_Utils.Learning_Event.Data_Utils.split_train_test(eth_data, 0.8)
    x_train_tensor = Nx.tensor(x_train_prep) |> Nx.divide(4000)
    y_test_tensor = Nx.tensor(y_test_prep) |> Nx.divide(4000)
    x_train = Nx.to_batched(x_train_tensor, batch_size)
    y_test = Nx.to_batched(y_test_tensor, batch_size)
    eth_data_final = Stream.zip(x_train, y_test)

    eth_model_training_params =
      # train LSTM model using supervised training loop
      # we are using Axon's built in MSE loss function for now, but we will eventually replace it with our custom A3C loss function (nx_a3c.ex)
      eth_model
      |> Axon.Loop.trainer(:mean_squared_error, Polaris.Optimizers.adamw(learning_rate: 0.0005), log: 50)
      |> Axon.Loop.run(eth_data_final, %{}, epochs: 40, compiler: EXLA, debug: true)
  end

  # 3. predict ETH prices using trained model
  def predict_prices(eth_model, eth_model_training_params) do
    # 2. predict prices using our trained model
    # calculate y_hat given x-test
    x_test = [[1980, 2012.63]] |> Enum.chunk_every(1, 1, :discard) |> Nx.tensor() |> Nx.reshape({:auto, 1, 2})
    y_hat = Axon.predict(eth_model, eth_model_training_params, x_test, compiler: EXLA)
            |> Nx.multiply(4000)
  end

end
