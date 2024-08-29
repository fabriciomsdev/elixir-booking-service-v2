# LOAD TESTS

## How to run:
## Install dependencies
```bash
make setup
```

or

```bash
python3 -m venv venv && . ./venv/bin/activate && pip install -r requirements.txt
```

## Run tests
```bash
make run
```

or

```bash
locust -f load_tests.py
```