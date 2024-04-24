**FloodZone Hospital Finder - A Routing System during Flood Conditions**

This application shows the distance to the nearest hospital during flood and non-flood conditions.
It enables users to add/ update flood polygon data into the POSTGRE database and reflect changes in hospital accessibility.

**To run the application you will need the following**
1. POSTGRE with Post GIS extension
2. OpenRoute Service API key - https://openrouteservice.org/

**Steps**

1. Create a directory for the code
        >> mkdir code
        >> cd code
   
3. Create a virtual environment
        >> python -m venv env
   
 Activating virtual environment
        >> env\Scripts\activate
        
5. Install all required packages
    pip install Flask GeoPandas psycopg2-binary
    pip install psycopg2-binary
    pip install Shapely
    pip install openrouteservice
    pip install polyline
   
7. Create a database and tables flood_zones & hospitals following instructions in the schema.sql file.
8. Change the config.py file to your db_credentails.
9. Change the API key to your API key values in the db.py file.

**To run the application:**
    >> python main.py



