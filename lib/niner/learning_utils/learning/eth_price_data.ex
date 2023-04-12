defmodule Niner.Learning_Event_Utils.Learning_Event.Eth_Price_Data do
  @moduledoc """
  Try to predict the likely fuel consumption efficiency
  https://www.kaggle.com/vinicius150987/regression-fuel-consumption
  """

  # Functions to handle CSVfiles
  # https://github.com/dashbitco/nimble_csv
  alias NimbleCSV.RFC4180, as: CSV
  alias Niner.Learning_Event_Utils.Learning_Event.NxLinearRegression

  # Set of useful machine learning functions
  # https://github.com/elixir-nx/scholar
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
    "/usr/local/elixir-apps/niner/priv/ETH_USD/FuelEconomy.csv"
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
