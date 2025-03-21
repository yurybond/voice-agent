// contactMapRoute.js
import {LightningElement, api, wire} from 'lwc';
import getContactAndRoutePoints from '@salesforce/apex/RouteMapController.getRoutePoints';

export default class ContactMapRoute extends LightningElement {
    @api recordId; // Contact record ID
    mapMarkers = []; // Array to hold map markers

    @wire(getContactAndRoutePoints, {routeId: '$recordId'})
    wiredRoutePoints({error, data}) {
        if (data) {
            const mapMarkers = this.createMapMarkers(data.routePoints);
            const mapEventMarkers = this.createEventMapMarkers(data.routeEvents);
            this.mapMarkers = [...mapMarkers, ...mapEventMarkers];

            // if (this.mapMarkers.length > 0) {
            //     this.center = {location: this.mapMarkers[0].location}; // Center map on the first marker
            // }
        } else if (error) {
            console.error('Error fetching contact and route points:', error);
        }
    }

    createEventMapMarkers(routePoints) {
        return routePoints.filter(point => point.Location__c)
            .map(point => ({
                    location: {
                        Latitude: point.Location__Latitude__s,
                        Longitude: point.Location__Longitude__s,
                    },
                    // mapIcon: {
                    //     path: 'M 125,5 155,90 245,90 175,145 200,230 125,180 50,230 75,145 5,90 95,90 z',
                    //     fillColor: 'gold',
                    //     fillOpacity: .8,
                    //     strokeWeight: 0,
                    //     scale: .10,
                    //     anchor: {x: 122.5, y: 115}
                    // },
                    mapIcon: {
                        path: "M-1.547 12l6.563-6.609-1.406-1.406-5.156 5.203-2.063-2.109-1.406 1.406zM0 0q2.906 0 4.945 2.039t2.039 4.945q0 1.453-0.727 3.328t-1.758 3.516-2.039 3.070-1.711 2.273l-0.75 0.797q-0.281-0.328-0.75-0.867t-1.688-2.156-2.133-3.141-1.664-3.445-0.75-3.375q0-2.906 2.039-4.945t4.945-2.039z",
                        fillColor: "blue",
                        fillOpacity: 0.6,
                        strokeWeight: 0,
                        rotation: 0,
                        scale: 2,
                        anchor: {x: 0, y: 20}//new google.maps.Point(0, 20),
                    },
                    title: point.Name, // Marker title
                    description: point.Description__c || '',

                })
            );
    }

    createMapMarkers(routePoints) {
        return routePoints.map(point => {
            return {
                location: {
                    City: point.Facility__r.Address__c?.city || '',
                    Country: point.Facility__r.Address__c?.country || '',
                    PostalCode: point.Facility__r.Address__c?.postalCode || '',
                    State: point.Facility__r.Address__c?.state || '',
                    Street: point.Facility__r.Address__c?.street || '',
                },
                title: point.Name, // Marker title
                description: `Point# ${point.Sequence_Number__c}`,

            }
        });
    }
}