import psycopg2
from config import DATABASE

def get_db_connection():
    return psycopg2.connect(**DATABASE)

from shapely.wkt import loads
from shapely.geometry import LineString
import openrouteservice
import polyline


def get_nearest_hospital_with_flood(user_longitude, user_latitude):
    client = openrouteservice.Client(key='5b3ce3597851110001cf6248e4f2697d0ea245748c72ffb8ea595849')  # OpenRouteService API key
    user_coords = (user_longitude, user_latitude)

    def fetch_hospitals(offset=0):
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT name, ST_Y(location::geometry) AS lat, ST_X(location::geometry) AS lng, address, phone_no
                    FROM hospitals
                    ORDER BY location <-> ST_SetSRID(ST_Point(%s, %s), 4326)
                    LIMIT 5 OFFSET %s;
                """, (user_longitude, user_latitude, offset))
                return cur.fetchall()

    offset = 0
    flood_zones_wkt = None
    while True:
        hospitals = fetch_hospitals(offset)
        if not hospitals:
            print("No more hospitals found in database.")
            return None

        if flood_zones_wkt is None:  # Fetch flood zones only once
            with get_db_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT ST_AsText(area) FROM flood_zones")
                    flood_zones_wkt = [loads(row[0]) for row in cur.fetchall()]

        if not flood_zones_wkt:
            print("No flood zones found. Returning nearest hospital regardless of flooding.")
            hospital = hospitals[0]
            return {
                'name': hospital[0],
                'distance': float('inf'),  # Indicating no routing check was done
                'address': hospital[3],
                'telephone': hospital[4],
                'route_polyline': None
            }

        for hospital in hospitals:
            hospital_coords = (hospital[2], hospital[1])  # lng, lat
            try:
                routes = client.directions(
                    coordinates=[user_coords, hospital_coords],
                    profile='driving-car',
                    format='geojson'
                )
                route_line = LineString(routes['features'][0]['geometry']['coordinates'])
                intersects_flood_zone = any(route_line.intersects(zone) for zone in flood_zones_wkt)

                if not intersects_flood_zone:
                    distance = routes['features'][0]['properties']['segments'][0]['distance']
                    encoded_polyline = polyline.encode([(coord[1], coord[0]) for coord in route_line.coords])
                    return {
                        'name': hospital[0],
                        'distance': distance,
                        'address': hospital[3],
                        'telephone': hospital[4],
                        'route_polyline': encoded_polyline,
                        'color': 'green'
                    }
            except Exception as e:
                print(f"Error getting route for hospital {hospital[0]}: {e}")

        offset += 3


def get_nearest_hospital_without_flood(user_longitude, user_latitude):
    client = openrouteservice.Client(key='5b3ce3597851110001cf6248e4f2697d0ea245748c72ffb8ea595849')  # API key
    user_coords = (user_longitude, user_latitude)

    # Fetch flood zones once at the beginning
    flood_zones_wkt = []
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT ST_AsText(area) FROM flood_zones")
            flood_zones_wkt = [loads(row[0]) for row in cur.fetchall()]

    min_distance = float('inf')
    nearest_hospital = None

    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT h.id, h.name, h.address, h.phone_no, ST_X(h.location::geometry) as lng, ST_Y(h.location::geometry) as lat
                FROM hospitals h
                ORDER BY h.location <-> ST_SetSRID(ST_Point(%s, %s), 4326) LIMIT 5;
            """, (user_longitude, user_latitude))
            hospitals = cur.fetchall()

    for hospital in hospitals:
        hospital_coords = (hospital[4], hospital[5])  # lng, lat

        routes = client.directions(
            coordinates=[user_coords, hospital_coords],
            profile='driving-car',
            format='geojson'
        )
        distance = routes['features'][0]['properties']['segments'][0]['distance']
        if distance < min_distance:
            min_distance = distance
            route_line = LineString(routes['features'][0]['geometry']['coordinates'])

            # Check intersection with flood zones
            intersects_flood_zone = any(route_line.intersects(zone) for zone in flood_zones_wkt)
            color = 'red' if intersects_flood_zone else 'green'

            nearest_hospital = {
                'name': hospital[1],
                'distance': distance,
                'address': hospital[2],
                'telephone': hospital[3],
                'route_polyline': polyline.encode([(coord[1], coord[0]) for coord in route_line.coords]),
                'color': color  # Add color information based on flood intersection
            }

    return nearest_hospital


# db.py

def add_flood_region(wkt):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("INSERT INTO flood_zones (area) VALUES (ST_GeomFromText(%s, 4326))", (wkt,))
            conn.commit()


def fetch_flood_regions():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, ST_AsGeoJSON(area) as geojson FROM flood_zones;")
    regions = cur.fetchall()
    cur.close()
    conn.close()
    return regions

def delete_flood_region(region_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM flood_zones WHERE id = %s;", (region_id,))
    conn.commit()
    cur.close()
    conn.close()