public without sharing class RouteEventController {

    private static final List<String> ACTIVE_ROUTE_STATUSES = new List<String>{'New', 'Assigned', 'Accepted'};
    
    @InvocableMethod(label='Create Route Event records' description='Create route event records from prompt response')
    public static List<Response> reportRouteEvent(List<Request> requests) {
        String promptResponse = requests.get(0).promptResponse;
        String routeType = parsePromptResponse(promptResponse, 'Route type -\\s*(\\w+)');
        String sequenceNumber = parsePromptResponse(promptResponse, 'stop number (\\d+)');
        String routeName = parsePromptResponse(promptResponse, '\'([^\']*-[^\']*-*[^\']*)\'');
        String routeEvent = parsePromptResponse(promptResponse, '\'([^\']*)\'');
        Decimal latitude = requests.get(0).latitude;
        Decimal longitude = requests.get(0).longitude;
        Response response = new Response();
        if (sequenceNumber != null && routeName != null && routeEvent != null) {
            response.prompt = createRoutEvent(sequenceNumber, routeName, routeEvent, routeType, promptResponse, latitude, longitude);
        } else if (sequenceNumber == null && routeName != null && routeEvent != null) {
            response.prompt = createRoutEvent(routeName, routeEvent, promptResponse, latitude, longitude);
        } else {
            response.prompt = 'It is not something I can help you with.';
        }
        
        return new List<Response> {response};
    }

    private static String parsePromptResponse(String promptResponse, String regExp) {
        Pattern pattern = Pattern.compile(regExp);
        Matcher matcher = pattern.matcher(promptResponse);

        String matchedString = null;
        if (matcher.find()) {
            matchedString = matcher.group(1);
        }

        return matchedString;
    }

    private static String createRoutEvent(
            String sequenceNumber, String routeName, String event, String routeType,
            String promptResponse, Decimal latitude, Decimal longitude
        ) {
        Integer seqNumber = Integer.valueOf(sequenceNumber);
        Stop__c stop = [SELECT Id, Route__c, Route__r.Status__c, Trip__c
                        FROM Stop__c WHERE Route__r.Name =: routeName 
                        AND Sequence_Number__c =: seqNumber LIMIT 1];
        Route_Event__c routeEvent = new Route_Event__c();
        routeEvent.Name = event;
        routeEvent.Type__c = routeType;
        routeEvent.Route__c = stop.Route__c;
        routeEvent.Stop__c = stop.Id;
        routeEvent.Description__c = event;
        routeEvent.Location__latitude__s = latitude;
        routeEvent.Location__longitude__s  = longitude;
        try {
            insert routeEvent;
        } catch (DmlException dmlEx) {
            return 'It is not something I can help you with.';
        }
        if (routeType == 'Departure')  {
            stop.Actual_Departure_Time__c = DateTime.now();
            update stop;
            if (ACTIVE_ROUTE_STATUSES.contains(stop.Route__r.Status__c)) {
                Route__c route = stop.Route__r;
                route.Status__c = 'In-Progress';
                update route;
            }
        } else if (routeType == 'Arrival' || routeType == 'Unload') {
            stop.Actual_Arrival_Time__c = DateTime.now();
            update stop;
            if (stop.Trip__c == 'Route End') {         
                Route__c route = stop.Route__r;
                route.Status__c = 'Delivered';
                update route;
            }
        }
        return promptResponse;
    }

    private static String createRoutEvent(String routeName, String event, String promptResponse, Decimal latitude, Decimal longitude) {
        Route__c route = [SELECT Id FROM Route__c WHERE Name =: routeName LIMIT 1];
        Route_Event__c routeEvent = new Route_Event__c();
        routeEvent.Name = event;
        routeEvent.Route__c = route.Id;
        routeEvent.Description__c = event;
        routeEvent.Location__latitude__s = latitude;
        routeEvent.Location__longitude__s  = longitude;
        try {
            insert routeEvent;
        } catch (DmlException dmlEx) {
            return 'It is not something I can help you with.';
        }
        return promptResponse;
    }
    
    public class Request {
        @InvocableVariable(label='Prompt Response' required=true)
        public String promptResponse;
        @InvocableVariable(label='Latitude')
        public Decimal latitude;
        @InvocableVariable(label='Longitude ')
        public Decimal longitude;
    }
    
    public class Response {
        @InvocableVariable
        public String prompt;
    }
}