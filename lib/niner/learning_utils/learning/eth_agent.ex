defmodule Niner.Learning_Event_Utils.Learning_Event.Eth_Agent do
  # how to use:
  # 1. run the project
  # iex -S mix
  # 2. load the data
  # eth_data = Niner.Learning_Event_Utils.Learning_Event.Eth_Agent.load_data()
  # 3. split data into training and test sets (80/20 respectively)
  # {train, test} = Niner.Learning_Event_Utils.Learning_Event.Nx_A3c.split_train_test(eth_data, 0.8)
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
    # 0. load real-time price data from our database, streamed from the streamer.ex module | eventually use as test data for y_hat predictions
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

    # 0. load ETH-USD historical data from our app's priv directory | creates batch_inputs {x} and batch_labels {y}
    # here's a function to test what the actual stream of data looks like in human-readable format:
    # data_human_readable = "/usr/local/elixir-apps/niner/priv/ETH_USD/ETH-USD-a3c.csv" |> File.stream!() |> CSV.parse_stream() |> Enum.map(fn [date, open, high, low, close, adjclose, volume] -> [Integer.parse(date) |> elem(0), Float.parse(open) |> elem(0), Float.parse(high) |> elem(0), Float.parse(low) |> elem(0), Float.parse(close) |> elem(0), Float.parse(adjclose) |> elem(0), Integer.parse(volume) |> elem(0)] end)
    # to embed the data within an Nx tensor and check the tensor shape:
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

  # 1. data preprocessing | normalization the data to ensure all features are on a similar scale, and transform the data into a a sequence of I/O pairs
  def data_preprocessing(eth_data) do
    # do some normalization here
    # transform into sequence of I/O pairs here
  end

  # 2. create LSTM model | to be used for the training loop
  # we're using a sequential model, since it's pretty simple to implement in Elixir/Axon (thanks pipe operator, such a based function)
  # model summary: utilizing LSTM hidden layers + incremental dropout
  # i don't think Axon has modules supporting graph NNs or multi-headed attention mechanisms, but keep an eye out for that
  # def create_model_lstm(eth_processed_data) do
  def create_model_lstm(eth_data) do
    # if overfitting still occurs despite the dropout layers, consider regularizing the input data before the input layer (normalizing, etc.)
    eth_model =
      # the input layer | the input data shape may vary, so consider changing the 1st shape value '1980' to 'nil'
      Axon.input("eth_usd", shape: {1980, 7})
      # the 1st LSTM layer | gradually increasing the # of neurons/units with each LSTM layer helps our model develop a hierarchical representation of the data
      |> Axon.lstm(8)
      # get the output of the LSTM layer | this is fed into the dropout layer
      |> then(fn {output, _} -> output end)
      # 1st dropout layer | helps with overfitting, don't become too dependent on a single neuron/unit! | 2% dropout rate
      # https://jmlr.org/papers/v15/srivastava14a.html
      |> Axon.dropout(rate: 0.02)
      # 2nd LSTM layer
      |> Axon.lstm(12)
      # get the output of the LSTM layer | feed into the dropout layer
      |> then(fn {output, _} -> output end)
      # 2nd dropout layer | 4% dropout rate
      |> Axon.dropout(rate: 0.04)
      # 3rd LSTM layer
      |> Axon.lstm(16)
      # get the output of the LSTM layer
      |> then(fn {output, _} -> output end)
      # 3rd dropout layer | 6% dropout rate
      |> Axon.dropout(rate: 0.06)
      # 4th LSTM layer
      |> Axon.lstm(20)
      # get the output of the LSTM layer
      |> then(fn {output, _} -> output end)
      # 4th dropout layer | 8% dropout rate
      |> Axon.dropout(rate: 0.08)
      # the 5th LSTM layer
      |> Axon.lstm(24)
      # get the output of the LSTM layer
      |> then(fn {output, _} -> output end)
      # 5th dropout layer | 10% dropout rate
      |> Axon.dropout(rate: 0.1)
      # the output layer | 
      |> Axon.dense(1980, activation: :softmax)
  end

  # 3. train LSTM model using supervised training loop
  def train_model_lstm(eth_model) do
    # we are using Axon's built in MSE loss function for now, but we will eventually replace it with our custom A3C loss function (nx_a3c.ex)
    Axon.Loop.trainer(eth_model, :mean_squared_error, Axon.Optimizers.adamw(0.005))
  end

  # 4. evaluate trained LSTM model against test data
  def evaluate_model(eth_model_state) do
    # use Axon utils to evaluate model
  end

  # 5. predict prices using our trained model
  def predict_prices(x_test) do
    # calculate y_hat given x-test
  end

end
