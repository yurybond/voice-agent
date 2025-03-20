public without sharing class RouteEventTriggerHandler {

    private static final List<String> ACTIVE_ROUTE_STATUSES = new List<String>{'New', 'Assigned', 'Accepted'};

    public static void handleAfterInsert(List<Route_Event__c> newRouteEvents) {
        
        Map<Id, String> routesWithStatus = new Map<Id, String>();
        Set<Id> stopIds = new Set<Id>();
        for (Route_Event__c re : newRouteEvents) {
            routesWithStatus.put(re.Route__c, re.Type__c);
            stopIds.add(re.Stop__c);
        }
        
        Map<Id, Stop__c> routesWithStops = new Map<Id, Stop__c>();
        List<Stop__c> stops = [SELECT Id, Route__c, Trip__c FROM Stop__c WHERE Id IN :stopIds];
        for (Stop__c stop : stops) {
            routesWithStops.put(stop.Route__c, stop);            
        }
        List<Route__c> routes = [SELECT Id, Status__c FROM Route__c WHERE Id IN :routesWithStatus.keySet()];
        List<Route__c> routesToUpdate = new List<Route__c>();
        List<Stop__c> stopsToUpdate = new List<Stop__c>();
        for (Route__c route : routes) {
            if (routesWithStatus.get(route.Id) == 'Arrival') {
                if (routesWithStops.get(route.Id) != null) {
                    Stop__c stop = routesWithStops.get(route.Id);
                    stop.Actual_Arrival_Time__c = DateTime.now();
                    stopsToUpdate.add(stop);

                    if (routesWithStops.get(route.Id).Trip__c == 'Origin' && 
                        ACTIVE_ROUTE_STATUSES.contains(route.Status__c)) {
                        route.Status__c = 'In-Progress';
                        routesToUpdate.add(route);
                    }
                }
            } else if (
                routesWithStatus.get(route.Id) == 'Departure' ||
                routesWithStatus.get(route.Id) == 'Unload') 
            {                
                if (routesWithStops.get(route.Id) != null) {
                    Stop__c stop = routesWithStops.get(route.Id);
                    stop.Actual_Departure_Time__c = DateTime.now();
                    stopsToUpdate.add(stop);

                    if (routesWithStops.get(route.Id).Trip__c == 'Destination') {
                        route.Status__c = 'Delivered';
                        routesToUpdate.add(route);
                    }
                }
            }
        }
        
        update routesToUpdate;
        update stopsToUpdate;
    }
    
}