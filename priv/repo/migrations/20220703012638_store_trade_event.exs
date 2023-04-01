defmodule Niner.Repo.Migrations.Store_Trade_Event do
  use Ecto.Migration

  def change do
    create table(:trade_events) do
      add :maker_order_id, :string
      add :price, :float
      add :product_id, :string
      add :sequence, :bigint
      add :side, :string
      add :size, :float
      add :taker_order_id, :string
      add :trade_id, :integer
      add :type, :string

      timestamps()
    end
  end
end
