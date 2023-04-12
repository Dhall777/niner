defmodule Niner.Cb_Trader do
  import Aurum

  alias Niner.Repo
  alias Niner.Raw_Data_Utils.Trade_Event

  def buy_eth do
    eth_account = Aurum.Coinbase.get("/v2/accounts/eth")
    eth_resource = eth_account["data"]["resource_path"]
    buy_string = eth_resource <> "/buys"

    # recommendation = 

    # Aurum.Coinbase.post(buy_string, %{amount: _recommendation, currency: "USD"})
    Aurum.Coinbase.post(buy_string, %{amount: 10, currency: "USD"})
  end
  
end
