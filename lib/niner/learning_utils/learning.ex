# Schema/Struct and changeset for the incoming API data + its fields (aka: learnings)
# Configure validation once pipeline is complete
defmodule Niner.Learning_Utils.Learning do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "learnings" do
    #field(:maker_order_id, :string)
    #field(:price, :float)
    #field(:product_id, :string)
    #field(:sequence, :integer)
    #field(:side, :string)
    #field(:size, :float)
    #field(:taker_order_id, :string)
    #field(:trade_id, :integer)
    #field(:type, :string)

    timestamps()
  end

  def changeset(learning, attrs \\ %{}) do
    learning
    |> cast(attrs, [
      # :maker_order_id,
      #:price,
      #:product_id,
      #:sequence,
      #:side,
      #:size,
      #:taker_order_id,
      #:trade_id,
      #:type,
    ])

    #    |> validate_required([
    #
    #    ])
  end
end
