defmodule Niner.Learning_Event_Utils.Learning_Event.Agent_Zero do
  alias Niner.Trading_Event_Utils
  alias Niner.Trade_Event_Utils.Trade_Event
  alias Niner.Repo
  import Ecto.Query
  import Axon
  import Nx
  import Bumblebee
  import TableRex
  import CSV
  # use GenServer

  def model_data do
    # load historical price data from our DB (for now); get more historical data somewhere else, or just store a ton on our NAS 
    historical_data = 
      all_trade_events = from t in Trade_Event, select:
        %{
        id: t.id,
        price: t.price,
        order_by: [desc: t.inserted_at]
        }
      Repo.all(all_trade_events)

  end    

  # clean historical data for tensor creation process

  # create the axon model

  # train axon model using different deep reinforcement learning algorithms
  # dqn = deep q-networks
  # ppo = proximal policy optimization
  # ac  = actor-critic
  # a3c = asynchronous advantage actor-critic
  # td3 = twin delayed ddpg
  
end
