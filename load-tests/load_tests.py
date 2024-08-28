from locust import HttpUser, SequentialTaskSet, task, between
import time

class UserBehaviorOnCheckoutFlow(SequentialTaskSet):
    def __init__(self, parent):
        super().__init__(parent)
        self.order_id = None
        self.store_id = "236584ee-58e2-42fd-a4d4-e08133bbbb6b"

    @task(1)
    def start_checkout(self):
        response = self.client.post("/api/orders", json={
            "store_id": self.store_id
        })

        if response.status_code == 201:
            print(response.json())
            self.order_id = response.json().get("id")
            print(f"Order ID: {self.order_id}")

    @task(2)
    def get_classifications(self):
        self.client.get("/api/classifications")

    @task(3)
    def fill_checkout(self):
        if not self.order_id:
            return
        print(f"Fill form of order ID: {self.order_id}")
        time.sleep(18) # time to fill the form
        print(f"Filled form ID: {self.order_id}")
        self.client.put(f"/api/orders/{self.order_id}", json={
            "store": {
                "id": self.store_id
            },
            "items": [
                {
                    "name": "Bags Storage",
                    "quantity": 1
                }
            ],
            "customer": {
                "name": "Cody",
                "email": "fabricioms.dev@gmail.com"
            },
            "payment_order": {
                "credit_card": "1234 5678 9012 3456",
                "cvv": "123",
                "expiration_date": "12/23"
            }
        })


class WebsiteUser(HttpUser):
    tasks = [UserBehaviorOnCheckoutFlow]
    wait_time = between(1, 5)
    host = "http://localhost:4000"
