defmodule Niner.Learning_Event_Utils.Learning_Event.NxLinearRegression do
  # how to use:
  # 1. run the project
  # iex -S mix
  # 2. load the data 
  # data = Niner.Learning_Event_Utils.Learning_Event.Eth_Test_Agent.load_data()
  # 3. split data into training and test sets (80/20 respectively)
  # {train_set, test_set} = Niner.Learning_Event_Utils.Learning_Event.NxLinearRegression.train_test_split(data, 0.8)
  # 4. train the model; generates the learned parameters
  # params = Niner.Learning_Event_Utils.Learning_Event.Eth_Test_Agent.train(train)
  # 4a. calculate MSE (on test data)
  # mse = Niner.Learning_Event_Utils.Learning_Event.Eth_Test_Agent.mse(params, test)
  # 5. get the test data
  # {x_test, y_test} = Enum.unzip(test)
  # 6. predict some prices
  # y_hat = Niner.Learning_Event_Utils.Learning_Event.Eth_Test_Agent.predict(params, x_test)

  # Set of useful machine learning functions + parent learning agent
  alias Scholar.Preprocessing
  alias Niner.Learning_Event_Utils.Learning_Event.Eth_Test_Agent

  # This allows us to use numerical definitions and common ML tools
  import Nx.Defn
  import Scholar

  # This is the linear regression function.
  # A linear regression line has an equation of the form Y = wX + b.
  defn predict({w, b}, x) do
    w * x + b
  end

  # This calculates the mean squared error.
  # MSE calculates the difference between the predicted ETH-USD price and the actual ETH-USD price.
  defn loss(params, x, y) do
    y_hat = predict(params, x)

    (y - y_hat)
    |> Nx.pow(2)
    |> Nx.mean()
  end

  # This finds the gradient and updates w and b accordingly.
  # The gradient minimizes the distance between predicted and true outcomes based on the loss function.
  # w and b are weights that must be updated to get closer to the real value.
  # lr stands for learning rate, which is a parameter that determines the step size
  # at each iteration while moving toward a minimum of a loss function.
  defn update({w, b} = params, x, y, lr) do
    {grad_w, grad_b} = grad(params, &loss(&1, x, y))

    {
      w - grad_w * lr,
      b - grad_b * lr
    }
  end

  # This is just to generate some initial values for weights and bias.
  defn init_random_params do
    w = Nx.random_normal({}, 0.0, 0.1)
    b = Nx.random_normal({}, 0.0, 0.1)
    {w, b}
  end

  # This is for training based on the number of epochs.
  # this is now possible by using Scholar.Linear.LinearRegression I think
  @spec train(data :: tuple(), lr :: float(), epochs :: integer()) ::
          {Nx.Tensor.t(), Nx.Tensor.t()}
  def train(data, lr, epochs) do
    init_params = init_random_params()

    {x, y} = Enum.unzip(data)

    x = Preprocessing.standard_scale(Nx.tensor(x))
    y = Nx.tensor(y)

    for _ <- 1..epochs, reduce: init_params do
      acc -> update(acc, x, y, lr)
    end
  end

  # The train-test split is a technique for evaluating the performance of a machine learning algorithm.
  # It's important to simulate how a model would perform on new/unseen data.
  @spec train_test_split(data :: list(), train_size :: float()) :: tuple()
  def train_test_split(data, train_size) do
    num_examples = Enum.count(data)
    num_train = floor(train_size * num_examples)
    Enum.split(data, num_train)
  end
end
