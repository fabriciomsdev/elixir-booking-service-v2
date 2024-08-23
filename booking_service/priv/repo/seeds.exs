# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BookingService.Repo.insert!(%BookingService.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# inserting the first store
alias BookingService.Stores.Store

store1 = %Store{
  id: "236584ee-58e2-42fd-a4d4-e08133bbbb6b",
  name: "Cody Cookie Store",
  address: "1900-2054 Middlefield Rd, Palo Alto, CA 94301, EUA"
}
exist_store = BookingService.Repo.get(Store, store1.id)

if exist_store == nil do
  BookingService.Repo.insert!(store1)
end

classifications = [
  %BookingService.Items.Classification{
    name: "Bags Storage",
    value_to_store: 10.0
  },
  %BookingService.Items.Classification{
    name: "Boxes Storage - Business Logistics",
    value_to_store: 20.0
  },
  %BookingService.Items.Classification{
    name: "Large Items Storage - Business Logistics",
    value_to_store: 30.0
  }
]

for classification <- classifications do
  BookingService.Repo.insert!(classification)
end
