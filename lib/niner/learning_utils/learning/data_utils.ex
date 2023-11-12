defmodule Niner.Learning_Event_Utils.Learning_Event.Data_Utils do
  # alias parent learning agent and numerical definitions
  alias alias Niner.Learning_Event_Utils.Learning_Event.Eth_Test_Agent
  alias Nx.Defn
  # GenServer could help manage our actor/critic agents and their learning environment
  # use GenServer
  # numerical defs + ml utilities
  import Nx.Defn

  # A3C algorithm equation:
  # L = -log(pi(a_t | s_t; 0)) * A_t + B * MSE(V(s_t; 0_v), R_t)

  # split the data into a training set and testing/validation set (x_train and y_train) | the testing set will eventually be pulled from our own DB in real time
  # reference functions to convert {x} and {y} values into batched tensors for proper model training:
  # {x_train_prep, y_train_prep} = Niner.Learning_Event_Utils.Learning_Event.Nx_A3c.split_train_test(eth_data, 0.8)
  # x_train_tensor = Nx.tensor(x_train_prep)
  # y_train_tensor = Nx.tensor(y_train_prep)
  # batch_size = 128
  # x_train = Nx.to_batched(x_train_tensor, batch_size)
  # y_train = Nx.to_batched(y_train_tensor, batch_size)
  # now you can put the x_train and y_train variables in the Axon.Loop.run function to train the model :)
  def split_train_test(eth_data, train_size) do
    num_examples = Enum.count(eth_data)
    num_train = floor(train_size * num_examples)
    Enum.split(eth_data, num_train)
  end

  # the a3c equation function | calculates the a3c loss, which we will use as a 'custom loss function' within Axon
  # L = -log(pi(a_t | s_t; 0)) * A_t + B * MSE(V(s_t; 0_v), R_t)
  # TODO -> find a way to represent the state-action-space (SAS); the learning agents/critics refer to this when performing their policy+value calculations
  # this loss function will be used during the model training step, where the model refers to this loss function for improve its outputs
  # @spec a3c_loss_function(data :: tuple(), lr :: float(), epochs :: integer()) :: {Nx.Tensor.t(), Nx.Tensor.t()}
  defn a3c_loss_function() do
    # a3c loss function implementation here
    # reference custom loss functions in Axon: https://hexdocs.pm/axon/custom_models_loss_optimizers.html#using-custom-loss-functions-in-training-loops    
  end
end
