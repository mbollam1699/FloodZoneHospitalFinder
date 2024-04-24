from flask import render_template, request, jsonify
from .db import get_nearest_hospital_with_flood, get_nearest_hospital_without_flood,add_flood_region,fetch_flood_regions,delete_flood_region
import pandas as pd;

def init_routes(app):
    @app.route('/')
    def index():
        return render_template('index.html')

    @app.route('/search-without-flood', methods=['POST'])
    def search_hospital_without_flood():
        data = request.get_json()
        print(data);
        longitude = data['longitude']
        latitude = data['latitude']
        hospital = get_nearest_hospital_without_flood(longitude, latitude)
        return jsonify({'nearestHospital': hospital})

    @app.route('/search-with-flood', methods=['POST'])
    def search_hospital_with_flood():
        data = request.get_json()
        longitude = data['longitude']
        latitude = data['latitude']
        hospital = get_nearest_hospital_with_flood(longitude, latitude)
        return jsonify({'nearestHospital': hospital})

    @app.route('/hospital-data')
    def hospital_data():
        # Adjust the path to where your server can access the CSV file
        df = pd.read_csv('C:/Users/mveen/Downloads/filtered_hospitals.csv')
        # Convert the DataFrame to a JSON string and send it to the client
        return jsonify(df.to_dict(orient='records'))


    @app.route('/add-flood-region', methods=['POST'])
    def add_flood_region_route():
        data = request.get_json()
        wkt = data['wkt']

        add_flood_region(wkt)  # Call the function from db.py

        return jsonify({'status': 'success'})

    @app.route('/get-flood-regions', methods=['GET'])
    def get_flood_regions_route():
        regions = fetch_flood_regions()
        print(regions)
        return jsonify([{'id': row[0], 'coordinates': row[1]} for row in regions])

    @app.route('/delete-flood-region', methods=['POST'])
    def delete_flood_region_route():
        region_id = request.json['id']
        print(region_id)
        delete_flood_region(region_id)
        return jsonify({'status': 'success', 'message': 'Flood region deleted successfully'})

