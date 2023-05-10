defmodule Niner.Learning_Event_Utils.Learning_Event.Eth_Test_Agent do
  # how to use:
  # 1. run the project
  # iex -S mix
  # 2. load the data
  # data = Niner.Learning_Event_Utils.Learning_Event.Eth_Test_Agent.load_data()
  # 3. split data into training and test sets (80/20 respectively)
  # {train, test} = Niner.Learning_Event_Utils.Learning_Event.NxLinearRegression.train_test_split(data, 0.8)
  # 4. train the model; generates the learned parameters
  # params = Niner.Learning_Event_Utils.Learning_Event.Eth_Test_Agent.train(train)
  # 4a. calculate MSE (on test data)
  # mse = Niner.Learning_Event_Utils.Learning_Event.Eth_Test_Agent.mse(params, test)
  # 5. get the test data
  # {x_test, y_test} = Enum.unzip(test)
  # 6. predict some prices
  # y_hat = Niner.Learning_Event_Utils.Learning_Event.Eth_Test_Agent.predict(params, x_test)

  # Functions to handle CSVfiles + linear regression module
  alias NimbleCSV.RFC4180, as: CSV
  alias Niner.Learning_Event_Utils.Learning_Event.NxLinearRegression

  # Set of useful machine learning functions
  alias Scholar.Preprocessing

  # Let's define some defaults epochs and learning rate.
  @epochs 2000
  @learning_rate 0.1

  # This will call our internal training function with epochs and learning rate we defined above.
  @spec train(data :: tuple) :: {Nx.Tensor.t(), Nx.Tensor.t()}
  def train(data) do
    NxLinearRegression.train(data, @learning_rate, @epochs)
  end

  # This is going to predict based on the params previously learned.
  @spec predict(params :: tuple(), data :: list()) :: Nx.Tensor.t()
  def predict(params, data) do
    x =
      data
      |> Nx.tensor()
      |> Preprocessing.standard_scale()

    NxLinearRegression.predict(params, x)
  end

  # This is going to calculate the MSE based on the params previously learned.
  @spec mse(params :: tuple(), data :: tuple()) :: Nx.Tensor.t()
  def mse(params, data) do
    {x, y} = Enum.unzip(data)

    x = Preprocessing.standard_scale(Nx.tensor(x))
    y = Nx.tensor(y)

    NxLinearRegression.loss(params, x, y)
  end

  # This is going to load the data as streams.
  @spec load_data :: Stream.t()
  def load_data do
    "/usr/local/elixir-apps/niner/priv/ETH_USD/ETH-USD-linear-regression.csv"
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(fn [date, close] ->
      {
        Float.parse(date) |> elem(0),
        Float.parse(close) |> elem(0)
      }
    end)
  end
end
