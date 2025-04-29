import { LightningElement, wire, api } from 'lwc';
import getRoutes from '@salesforce/apex/RouteTableController.getRoutes';
import { NavigationMixin } from 'lightning/navigation';

export default class RouteTable extends NavigationMixin(LightningElement) {
    @api recordId;

    routes = [];
    error;
    columns = [
        {
            label: 'Route',
            fieldName: 'url',
            type: 'url',
            sortable: true,
            typeAttributes: { label: { fieldName: 'name' } }
        },
        {
            label: 'Status',
            fieldName: 'status',
            sortable: true
        },
        {
            label: 'Origin',
            fieldName: 'originUrl',
            type: 'url',
            sortable: true,
            typeAttributes: { label: { fieldName: 'originLocation' } }
        },
        {
            label: 'Origin Arrival',
            fieldName: 'originArrival',
            type: 'date',
            sortable: true,
            typeAttributes: {
                year: "numeric",
                month: "long",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }
        },
        {
            label: 'Destination',
            fieldName: 'destinationUrl',
            type: 'url',
            sortable: true,
            typeAttributes: { label: { fieldName: 'destinationLocation' } }
        },
        {
            label: 'Destination Arrival',
            fieldName: 'destinationArrival',
            type: 'date',
            sortable: true,
            typeAttributes: {
                year: "numeric",
                month: "long",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }
        }
    ];
    sortBy = 'originArrival';
    sortDirection = 'desc';

    @wire(getRoutes, {contactId: '$recordId'})
    wiredRoutes({ error, data }) {
        if (data) {
            this.routes = data.map(route => {
                const stops = route.Stops__r || [];
                const originStop = stops.find(stop => stop.Type__c === 'Origin');
                const destinationStop = stops.find(stop => stop.Type__c === 'Destination');

                return {
                    id: route.Id,
                    name: route.Name,
                    status: route.Status__c,
                    url: this.generateUrl('/lightning/r/Route__c/' + route.Id + '/view'),
                    originLocation: originStop ? 
                        `${originStop.Facility__r.Address__City__s}, ${originStop.Facility__r.Address__StateCode__s}` : 
                        'N/A',
                    originUrl: originStop ? 
                        this.generateUrl('/lightning/r/Stop__c/' + originStop.Id + '/view') : 
                        null,
                    originArrival: originStop ? 
                        originStop.Expected_Arrival_Start_Time__c : 
                        null,
                    destinationLocation: destinationStop ? 
                        `${destinationStop.Facility__r.Address__City__s}, ${destinationStop.Facility__r.Address__StateCode__s}` : 
                        'N/A',
                    destinationUrl: destinationStop ? 
                        this.generateUrl('/lightning/r/Stop__c/' + destinationStop.Id + '/view') : 
                        null,
                    destinationArrival: destinationStop ? 
                        destinationStop.Expected_Arrival_Start_Time__c : 
                        null
                };
            });
            this.sortData(this.sortBy, this.sortDirection); 
            this.error = undefined;
        } else if (error) {
            console.error('Error loading routes:', error);
            this.error = error;
            this.routes = [];
        }
    }

    generateUrl(pageReference) {
        return pageReference;
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortBy = sortedBy;
        this.sortDirection = sortDirection;
        this.sortData(sortedBy, sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.routes));
        let keyValue = (a) => a[fieldname] ? a[fieldname].toLowerCase() : '';
        parseData.sort((a, b) => {
            let valueA = keyValue(a);
            let valueB = keyValue(b);
            return direction === 'asc' ? (valueA > valueB ? 1 : -1) : (valueA < valueB ? 1 : -1);
        });
        this.routes = parseData;
    }
}