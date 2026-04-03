from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    return {"message": "terraform_actions app is running"}


@app.get("/health")
def health_check():
    return {"status": "ok"}
