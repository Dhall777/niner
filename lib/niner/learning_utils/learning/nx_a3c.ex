defmodule Niner.Learning_Event_Utils.Learning_Event.Nx_A3c do
  # alias parent learning agent and numerical definitions
  alias alias Niner.Learning_Event_Utils.Learning_Event.Eth_Test_Agent
  alias Nx.Defn
  # GenServer could help manage our actor/critic agents and their learning environment
  # use GenServer
  # numerical defs + ml utilities
  import Nx.Defn
  import Scholar
  import Explorer

  # A3C algorithm equation:
  # L = -log(pi(a_t | s_t; 0)) * A_t + B * MSE(V(s_t; 0_v), R_t)

  # split the data into a training set and testing set | the testing set will eventually be pulled from our own DB in real time
  # @spec create_test_data(data :: list(), train_size :: float()) :: tuple()
  def split_train_test(data, train_size) do
    num_examples = Enum.count(data)
    num_train = floor(train_size * num_examples)
    Enum.split(data, num_train)
  end

  # the a3c equation function | calculates the a3c loss, which we will use as a 'custom loss function' within Axon
  # L = -log(pi(a_t | s_t; 0)) * A_t + B * MSE(V(s_t; 0_v), R_t)
  # TODO -> find a way to represent the state-action-space (SAS); the learning agents/critics refer to this when performing their policy+value calculations
  # @spec a3c_loss_function(data :: tuple(), lr :: float(), epochs :: integer()) :: {Nx.Tensor.t(), Nx.Tensor.t()}
  defn a3c_loss_function() do
    # a3c loss function implementation here
    # reference for custom loss functions: https://hexdocs.pm/axon/custom_models_loss_optimizers.html#using-custom-loss-functions-in-training-loops    
  end
end
