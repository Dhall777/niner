defmodule Niner.Repo.Migrations.Store_Trade_Event do
  use Ecto.Migration

  def change do
    create table(:trade_events) do
      add :Maker_Order_Id, :string
      add :Price, :float
      add :Product_Id, :string
      add :Sequence, :bigint
      add :Side, :string
      add :Size, :float
      add :Taker_Order_Id, :string
      add :Trade_Id, :integer
      add :Type, :string

      timestamps()
    end
  end
end
