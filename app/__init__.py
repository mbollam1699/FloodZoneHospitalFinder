from flask import Flask
from .routes import init_routes

def create_app():
    app = Flask(__name__,static_folder='static')
    init_routes(app)
    return app
