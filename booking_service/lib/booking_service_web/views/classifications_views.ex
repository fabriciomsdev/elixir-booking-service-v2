defmodule BookingServiceWeb.ItemsClassificationView do
  alias BookingService.Items.Classification

  def render_classification(classification) do
    %{
      id: classification.id,
      name: classification.name,
      value_to_store: Decimal.to_float(classification.value_to_store),
      inserted_at: classification.inserted_at,
      updated_at: classification.updated_at
    }
  end

  def render("index.json", %{items_classifications: items_classifications}) do
    items_classifications
    |> Enum.map(&render_classification/1)
  end
end
