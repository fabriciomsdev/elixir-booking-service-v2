defmodule BookingService.ItemsClassification do
  @moduledoc """
    The Items Classification context, is the context responsible for managing the classification
    of items can be stored in the system.
  """
  import Ecto.Query, warn: false

  alias BookingService.Repo
  alias BookingService.Items.Classification

  def get_classification_by_name(name) do
    Repo.one(from i in ItemsClassification, where: i.name == ^name)
  end

  def create_classification(attrs) do
    Classification
    |> Classification.changeset(attrs)
    |> Repo.insert()
  end

  def update_classification(classification, attrs) do
    classification
    |> Classification.changeset(attrs)
    |> Repo.update()
  end

  def delete_classification(classification) do
    Repo.delete(classification)
  end

  def list do
    items_classification = Repo.all(Classification)
    {:ok, items_classification}
  end
end
