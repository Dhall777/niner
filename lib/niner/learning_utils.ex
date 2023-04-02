# The learningutils context -> stores API functions for learning models, along with related changesets + pubsub utils
defmodule Niner.Learning_Utils do

  import Ecto.Query, warn: false

  alias Niner.Repo
  # alias Niner.Learning_Utils.Learning

  # BEGIN API CONFIGURATION
  #
  # Returns a list of all learning records (GET)
  #def list_learnings do
  #  Repo.all(Learnings)
  #end

  # Returns a single learning record (GET)
  #def get_learning!(id), do: Repo.get!(Learning, id)

  # Create learning record and insert new record into learnings table (CREATE)
  #def create_learning(attrs \\ %{}) do
  #  %Learning{}
  #  |> Learning.changeset(attrs)
  #  |> Repo.insert()
  #end

  # Update learning record (UPDATE)
  #def update_learning(%Learning{} = learning, attrs) do
  #  learning
  #  |> Learning.changeset(attrs)
  #  |> Repo.update()
  #end

  # Deletes learning record (DELETE)
  #def delete_learning(%Learning{} = learning) do
  #  Repo.delete(learning)
  #end

  # Returns an Ecto changeset for tracking learning changes (CREATEs a changeset for the UPDATE function)
  #def change_learning(%Learning{} = learning, attrs \\ %{}) do
  #  Learning.changeset(learning, attrs)
  #end

end
