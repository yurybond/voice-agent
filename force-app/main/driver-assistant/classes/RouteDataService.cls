public without sharing class RouteDataService {

    @InvocableMethod
    public static List<Response> getDeliveryData(List<Request> requests) {
        Request input = requests[0];
        String inputContactId = input.Contact.Id;
        List<Response> responses = new List<Response>();
        Response output = new Response();
        List<Route__c> routes = [
                SELECT Id, Name, Status__c, (
                        SELECT Id, Expected_Arrival_Start_Time__c, Expected_Arrival_End_Time__c, Actual_Arrival_Time__c, Actual_Departure_Time__c,
                               Expected_Departure_Time__c, Type__c, Sequence_Number__c, Facility__r.Address__c, Facility__r.Phone__c, Facility__r.Timezone__c
                        FROM Stops__r
                        ORDER BY Sequence_Number__c
                )
                FROM Route__c
                WHERE Id IN (SELECT Route__c FROM Route_Assignment__c WHERE	Contact__c =: inputContactId)
        ];

        List<Route> routsWrapper = new List<Route>();
        for (Route__c route : routes) {
            Route routeWrapper = new Route();
            routeWrapper.id = route.Id;
            routeWrapper.name = route.Name;
            routeWrapper.status = route.Status__c;
            List<Stop> stopsWrapper = new List<Stop>();
            routeWrapper.stops = stopsWrapper;
            for (Stop__c stop : route.Stops__r) {
                if (stop.Type__c == 'Origin') {
                    routeWrapper.expectedArrivalStartTime = stop.Expected_Arrival_Start_Time__c;
                    routeWrapper.actualArrivalTime = stop.Actual_Arrival_Time__c;
                } else if (stop.Type__c == 'Destination') {
                    routeWrapper.expectedDepartureTime = stop.Expected_Departure_Time__c;
                    routeWrapper.actualDepartureTime = stop.Actual_Departure_Time__c;
                }
                Stop stopWrapper = new Stop();
                stopWrapper.id = stop.Id;
                stopWrapper.sequenceNumber = stop.Sequence_Number__c;
                stopWrapper.expectedArrivalStartTime = stop.Expected_Arrival_Start_Time__c;
                stopWrapper.expectedArrivalEndTime = stop.Expected_Arrival_End_Time__c;
                stopWrapper.type = stop.Type__c;
                stopWrapper.address = String.valueOf(stop.Facility__r.Address__c);
                stopWrapper.timezone = stop.Facility__r.Timezone__c;
                stopWrapper.phone = stop.Facility__r.Phone__c;
                stopsWrapper.add(stopWrapper);
            }
            routsWrapper.add(routeWrapper);
        }
        routsWrapper.sort(new PickUpDateCompare());
        output.Prompt = JSON.serialize(routsWrapper);
        responses.add(output);

        return responses;
    }
    
    public class Request {
        @InvocableVariable
        public Contact Contact;
        @InvocableVariable
        public Account Account;
    }
    
    public class Response {
        @InvocableVariable
        public String Prompt;
    }

    public class Route {
        public String id;
        public String name;
        public String status;
        public DateTime expectedArrivalStartTime;
        public DateTime expectedArrivalEndTime;
        public DateTime expectedDepartureTime;
        public DateTime actualArrivalTime;
        public DateTime actualDepartureTime;
        public List<Stop> stops;
    }

    public class Stop {
        public String id;
        public Decimal sequenceNumber;
        public DateTime expectedArrivalStartTime;
        public DateTime expectedArrivalEndTime;
        public String type;
        public String address;
        public String timezone;
        public String phone;
    }

    public class PickUpDateCompare implements Comparator<Route> {
        public Integer compare(Route route1, Route route2) {

            Long value1 = route1.expectedArrivalStartTime == null ? 0 : route1.expectedArrivalStartTime.getTime();
            Long value2 = route2.expectedArrivalStartTime == null ? 0 : route2.expectedArrivalStartTime.getTime();

            if (value1 == value2) {
                return 0;
            } else if (value1 > value2) {
                return 1;
            } else {
                return -1;
            }
        }
    }
}