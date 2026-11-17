from flask import Flask
import redis

app = Flask(__name__)
cache = redis.Redis(host='redis-db', port=6379)

@app.route('/')
def count():
    visits = cache.incr('hits')
    return f"Live Visitor Count from Redis Database: {visits}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
