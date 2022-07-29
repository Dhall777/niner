# Schema/Struct and changeset for the incoming API data + its fields (aka: trade_event)
# Configure validation once pipeline is complete
defmodule Niner.Trade_Event_Utils.Trade_Event do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "trade_events" do
    field(:Maker_Order_Id, :string)
    field(:Price, :float)
    field(:Product_Id, :string)
    field(:Sequence, :integer)
    field(:Side, :string)
    field(:Size, :float)
    field(:Taker_Order_Id, :string)
    field(:Trade_Id, :integer)
    field(:Type, :string)

    timestamps()
  end

  def changeset(trade_event, attrs \\ %{}) do
    trade_event
    |> cast(attrs, [
      :Maker_Order_Id,
      :Price,
      :Product_Id,
      :Sequence,
      :Side,
      :Size,
      :Taker_Order_Id,
      :Trade_Id,
      :Type,
    ])

    #    |> validate_required([
    #
    #    ])
  end
end
