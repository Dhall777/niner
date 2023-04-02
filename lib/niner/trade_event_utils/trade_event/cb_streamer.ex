defmodule Niner.Trade_Event_Utils.Trade_Event.Cb_Streamer do
  use WebSockex

  @url "wss://ws-feed.exchange.coinbase.com"

  def start_link(products \\ []) do
    {:ok, pid} = WebSockex.start_link(@url, __MODULE__, :no_state)
    subscribe(pid, products)
    {:ok, pid}
  end

  def handle_connect(_conn, state) do
    IO.puts "Connected. Initiating crypto price stream."
    {:ok, state}
  end

  def subscription_frame(products) do

    subscription_msg = %{

      type: "subscribe",
      product_ids: products,
      channels: ["matches"]

    } |> Poison.encode!()

      {:text, subscription_msg}
  end

  def subscribe(pid, products) do
    frame = subscription_frame(products)
    WebSockex.send_frame(pid, frame)
  end

  def handle_frame({:text, msg}, state) do
    handle_msg(Poison.decode!(msg), state)
  end

  def handle_msg(%{"type" => "match"} = trade, state) do
    # uncomment for debugging | prints the raw response data from coinbase's API
    # IO.inspect(trade)
    # convert raw reponse data into 'clean' map
    clean_trade = Map.new(for {key, value} <- trade, do: {String.to_atom(key), value})
    IO.inspect(clean_trade)
    # insert clean trade data in appropriate database table (trade_events)
    # Niner.Trade_Event_Utils.create_trade_event(clean_trade)
    {:ok, state}
  end

  def handle_msg(_trade, state) do
    {:ok, state}
  end

  def handle_disconnect(_conn, state) do
    IO.puts("disconnected")
    {:ok, state}
  end

end
