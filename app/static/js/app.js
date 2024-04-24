// Load flood regions and add them to the map
function loadFloodRegions() {
    console.log('Loading flood regions...');
    if (!map) {
        console.error('Map is not initialized when loading flood regions');
        return;
    }

    // Clear existing flood regions
    clearFloodRegions();

    fetch('/get-flood-regions')
    .then(response => response.json())
    .then(data => {
        data.forEach(region => {
            const geoJsonData = JSON.parse(region.coordinates);
            const layer = L.geoJSON(geoJsonData, {
                style: {
                    color: '#007FFF',
                    weight: 2,
                    opacity: 0.6,
                    fillOpacity: 0.4
                }
            }).addTo(map)
              .bindPopup(`<button onclick="removeFloodRegion(${region.id})" class="remove-flood-btn"><i class="fas fa-trash-alt"></i> Remove Flood</button>`);

            // Tag the layer with an ID for easy identification
            layer.feature = layer.feature || {}; // Ensure the feature property exists
            layer.feature.properties = { id: region.id };
        });
    })
    .catch(error => console.error('Error loading flood regions:', error));
}

// Function to clear all flood regions from the map
function clearFloodRegions() {
    map.eachLayer(function(layer) {
        if (layer.feature && layer.feature.properties && layer.feature.properties.id) {
            map.removeLayer(layer);
        }
    });
}

// Function to remove a specific flood region
function removeFloodRegion(id) {
    console.log('Attempting to remove flood region with ID:', id);
    fetch('/delete-flood-region', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ id: id })
    })
    .then(response => response.json())
    .then(data => {
        console.log('Response from server:', data);
        if (data.status === 'success') {
            console.log('Flood region removal confirmed by server, updating map...');
            map.eachLayer(function(layer) {
                if (layer.feature && layer.feature.properties && layer.feature.properties.id === id) {
                    console.log('Removing layer:', layer);
                    map.removeLayer(layer);
                }
            });
            alert('Flood region removed successfully!');

            // Reload flood regions and then search for hospitals
            loadFloodRegions().then(() => {
                const location = document.getElementById('locationDropdown').value;
                const [latitude, longitude] = location.split(', ');
                searchHospitals('/search-with-flood', longitude, latitude);
            });
        } else {
            console.error('Failed to remove flood region:', data.message);
        }
    })
    .catch(error => console.error('Error during fetch operation:', error));
}






let map;
document.addEventListener('DOMContentLoaded', function() {



function showLoader() {
    document.getElementById('loader').style.display = 'flex'; // Change to flex to center the spinner
}

function hideLoader() {
    document.getElementById('loader').style.display = 'none';
}

function fetchWithLoader(url, options) {
    showLoader();
    return fetch(url, options)
        .then(response => {
            hideLoader();
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();  // Make sure this is being called on the HTTP response
        })
        .catch(error => {
            hideLoader();
            console.error('Fetch error:', error);
            throw error;
        });
}



    function setCurrentLocationInDropdown() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                const { latitude, longitude } = position.coords;
                const locationDropdown = document.getElementById('locationDropdown');
                locationDropdown.options.length = 0; // Clear existing options
                locationDropdown.options.add(new Option(`${latitude}, ${longitude}`, `${latitude}, ${longitude}`));
                console.log("Dropdown set with: ", `${latitude}, ${longitude}`); // Debugging
                loadInitialHospitalData();
            });
        }
    }

    setCurrentLocationInDropdown(); // Set the current location on page load
    loadMap(); // Load Map, corrected function name case


    document.getElementById('setCurrentLocationButton').addEventListener('click', function() {
        setCurrentLocationInDropdown();
    });


    function setMapView(map) {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                const { latitude, longitude } = position.coords;
                // Set the map view to the current location
                map.setView([latitude, longitude], 13);
                // Add a marker at the current location
                L.marker([latitude, longitude]).addTo(map).bindPopup("You are here").openPopup();
            });
        }
    }



    function loadInitialHospitalData() {
        const location = document.getElementById('locationDropdown').value;
        console.log("LoadInitial Hospital data ",location)
        const [latitude, longitude] = location.split(', ');
        searchHospitals('/search-without-flood', longitude, latitude);
    }

    function addHospitalMarkers(map) {
    fetchWithLoader('/hospital-data')
        .then(data => {
            data.forEach(hospital => {
                L.marker([hospital.LATITUDE, hospital.LONGITUDE], { icon: hospitalIcon })
                    .addTo(map)
                    .bindPopup(`${hospital.NAME}<br>${hospital.ADDRESS}<br>${hospital.TELEPHONE}`);
            });
        })
        .catch(error => console.error('Error fetching hospital data:', error));
}

    const hospitalIcon = new L.Icon({
        iconUrl: '/static/assets/hospital.png',
        iconSize: [20, 20],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34],
        shadowSize: [41, 41]
    });

    function loadMap() {
        const mapElement = document.getElementById('map');
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                const { latitude, longitude } = position.coords;
                map = L.map('map').setView([latitude, longitude], 13);
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19 }).addTo(map);
                setMapView(map);
                addHospitalMarkers(map);
                loadFloodRegions();

                const drawnItems = new L.FeatureGroup();
                map.addLayer(drawnItems);

                const drawControl = new L.Control.Draw({
                    draw: {
                        polygon: true,
                        polyline: false,
                        rectangle: false,
                        circle: false,
                        marker: false,
                        circlemarker: false,
                    },
                    edit: {
                        featureGroup: drawnItems
                    }
                });

                map.addControl(drawControl);

                map.on('draw:created', function(event) {
                    const layer = event.layer;
                    drawnItems.addLayer(layer);
                    document.getElementById('saveRegionButton').style.display = 'block';
                });

                document.getElementById('saveRegionButton').addEventListener('click', function() {
                    drawnItems.eachLayer(function(layer) {
                        const polygon = layer.toGeoJSON();
                        const coordinates = polygon.geometry.coordinates[0].map(coord => coord.join(' ')).join(', ');
                        const wkt = `POLYGON((${coordinates}))`;

                        fetch('/add-flood-region', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                            },
                            body: JSON.stringify({ wkt })
                        })
                        .then(response => response.json())
                        .then(data => {
                            alert('Flood region added successfully!');
                            drawnItems.clearLayers();
                            clearFloodRegions();
                            loadFloodRegions();
                            const location = document.getElementById('locationDropdown').value;
                            const [latitude, longitude] = location.split(', ');
                            searchHospitals('/search-with-flood', longitude, latitude);
                        })
                        .catch(error => {
                            console.error('Failed to save flood region:', error);
                        });
                    });
                });
            }, () => {
                alert('Failed to get your location');
            });
        } else {
            alert('Geolocation is not supported by your browser');
        }
    }

    document.getElementById('searchButton').addEventListener('click', function() {
        const location = document.getElementById('locationDropdown').value;
        const [latitude, longitude] = location.split(', ');
        searchHospitals('/search-with-flood', longitude, latitude);
    });

  // Adjust other fetch calls similarly
function searchHospitals(url, longitude, latitude) {
    const options = {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ longitude, latitude })
    };
    console.log("Sending data to:", url, "Longitude:", longitude, "Latitude:", latitude);
    fetchWithLoader(url, options)
        .then(data => {  // Assuming data is already parsed JSON from 'fetchWithLoader'
            console.log("Data received from", url, ":", data);
            updateUI(data, url.includes('without-flood') ? 'withoutFlood' : 'withFlood');
            if (data.nearestHospital && data.nearestHospital.route_polyline) {
                displayRoute(data.nearestHospital.route_polyline, map, data.nearestHospital.color);
            }
        })
        .catch(error => {
            console.error('Error fetching hospital data:', error);
        });
}


function displayRoute(encodedPolyline, map, color) {
    if (!map || !encodedPolyline) {
        console.error('Map or encoded polyline data is missing.');
        return;
    }

    // Change color of all previous route polylines to red
    map.eachLayer(function(layer) {
        if (layer instanceof L.Polyline && layer.options.className === "route") {
            layer.setStyle({ color: 'red' });
        }
    });

    try {
        const latlngs = decodePolyline(encodedPolyline);
        let polyline = L.polyline(latlngs, {
            color: color,
            className: 'route'  // Add a className to identify this layer as a route
        }).addTo(map);
        let popupMessage = (color === 'red') ? 'Route Blocked' : 'Route Accessible';
        polyline.bindPopup(popupMessage);
        polyline.bringToFront(); // Ensure the new route is on top
    } catch (error) {
        console.error('Failed to decode polyline:', error);
    }
}



function decodePolyline(encoded) {
    // Custom function to decode polylines based on the encoding used (e.g., Google's polyline algorithm)
    let points = [];
    let index = 0, len = encoded.length;
    let lat = 0, lng = 0;

    while (index < len) {
        let b, shift = 0, result = 0;
        do {
            b = encoded.charAt(index++).charCodeAt(0) - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);

        let dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;

        do {
            b = encoded.charAt(index++).charCodeAt(0) - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);

        let dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        points.push([lat / 1e5, lng / 1e5]);
    }

    return points;
}








 function updateUI(data, type) {
        if (type === 'withoutFlood') {
            document.getElementById('hospitalNameWithoutFlood').textContent = data.nearestHospital.name || 'N/A';
            document.getElementById('addressWithoutFlood').textContent = data.nearestHospital.address || 'N/A';
            document.getElementById('phoneWithoutFlood').textContent = data.nearestHospital.telephone || 'N/A';
            document.getElementById('distanceWithoutFlood').textContent = data.nearestHospital.distance ? data.nearestHospital.distance + ' meters' : 'N/A';
        } else {
            document.getElementById('floodImpactHeader').style.display = '';
            document.getElementById('hospitalNameWithFlood').style.display = '';
            document.getElementById('addressWithFlood').style.display = '';
            document.getElementById('phoneWithFlood').style.display = '';
            document.getElementById('distanceWithFlood').style.display = '';

            document.getElementById('hospitalNameWithFlood').textContent = data.nearestHospital.name || 'N/A';
            document.getElementById('addressWithFlood').textContent = data.nearestHospital.address || 'N/A';
            document.getElementById('phoneWithFlood').textContent = data.nearestHospital.telephone || 'N/A';
            document.getElementById('distanceWithFlood').textContent = data.nearestHospital.distance ? data.nearestHospital.distance + ' meters' : 'N/A';

            let floodImpact = document.getElementById('hospitalNameWithoutFlood').textContent !== document.getElementById('hospitalNameWithFlood').textContent;
            let distanceDiff = parseFloat(document.getElementById('distanceWithFlood').textContent) - parseFloat(document.getElementById('distanceWithoutFlood').textContent);

            document.getElementById('floodImpactInfo').style.display = '';
            document.getElementById('floodImpactText').textContent = `********** Flood Impact Detected: ${floodImpact ? 'Yes' : 'No'} **********`;
            document.getElementById('distanceDifferenceText').textContent = `Flood has increased the distance to the nearest hospital by : ${distanceDiff.toFixed(2)} meters **********`;
        }
    }





});
