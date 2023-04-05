# The trade_event_utils context -> stores API functions (CRUD) for incoming  "trade_event" API data, along with related changesets + pubsub utils
defmodule Niner.Trade_Event_Utils do

  import Ecto.Query, warn: false

  alias Niner.Repo
  alias Niner.Trade_Event_Utils.Trade_Event

  # topic naming for pubsub (uses the module name)
  @topic inspect(__MODULE__)

  # BEGIN API CONFIGURATION
  #
  # Returns a list of all trade_event records (GET)
  def list_trade_events do
    Repo.all(Trade_Events)
  end

  # Returns a single trade_event record (GET)
  def get_trade_event!(id), do: Repo.get!(Trade_Event, id)

  # Create trade_event and insert new record into trade_events table (CREATE)
  def create_trade_event(attrs \\ %{}) do
    %Trade_Event{}
    |> Trade_Event.changeset(attrs)
    |> Repo.insert()
  end

  # Update trade_event record (UPDATE)
  def update_trade_event(%Trade_Event{} = trade_event, attrs) do
    trade_event
    |> Trade_Event.changeset(attrs)
    |> Repo.update()
  end

  # Deletes trade_event record (DELETE)
  def delete_trade_event(%Trade_Event{} = trade_event) do
    Repo.delete(trade_event)
  end

  # Returns an Ecto changeset for tracking trade_event changes (CREATEs a changeset for the UPDATE function)
  def change_trade_event(%Trade_Event{} = trade_event, attrs \\ %{}) do
    Trade_Event.changeset(trade_event, attrs)
  end

end
