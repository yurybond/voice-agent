public without sharing class RouteDataService {

    @InvocableMethod
    public static List<Response> getDeliveryData(List<Request> requests) {
        // Retrieve inputs
        Request input = requests[0];
        Contact inputContact = input.Contact;

//        String inputAccountId = (String) [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]?.Contact.AccountId
//                ?? '001aj00000g4CyXAAU';
        //inputAccountId = inputAccountId ?? input.Account.Id;

        // Create expected response
        List<Response> responses = new List<Response>();
        Response output = new Response();
        List<Route__c> routes = [
                SELECT Id, Name, Status__c, (
                        SELECT Id, Expected_Arrival_Start_Time__c, Expected_Arrival_End_Time__c,
                                Trip__c, Sequence_Number__c, Facility__r.Address__c, Facility__r.Phone__c, Facility__r.Timezone__c
                        FROM Stops__r
                        Order By Sequence_Number__c
                )
                FROM Route__c
                WHERE Account__c = :input.Account.Id
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
                Stop stopWrapper = new Stop();
                stopWrapper.id = stop.Id;
                stopWrapper.sequenceNumber = stop.Sequence_Number__c;
                stopWrapper.expectedArrivalStartTime = stop.Expected_Arrival_Start_Time__c;
                stopWrapper.expectedArrivalEndTime = stop.Expected_Arrival_End_Time__c;
                stopWrapper.trip = stop.Trip__c;
                stopWrapper.address = String.valueOf(stop.Facility__r.Address__c);
                stopWrapper.timezone = stop.Facility__r.Timezone__c;
                stopWrapper.phone = stop.Facility__r.Phone__c;
                stopsWrapper.add(stopWrapper);
            }
            routsWrapper.add(routeWrapper);
        }

        output.Prompt = JSON.serialize(routsWrapper);
        responses.add(output);

        return responses;
    }

    // Class that represents the template inputs that are passed to the class
    public class Request {
        @InvocableVariable
                // Ensure that the input1 variable is same name with proper case as you configured in the Prompt Builder
        public Contact Contact;
        @InvocableVariable
        public Account Account;
//        @InvocableVariable
//        public String AccountId;
    }

    // Class that represents the data that will be added to the template
    // when it's resolved
    public class Response {
        @InvocableVariable
        public String Prompt;
    }

    public class Route {
        public String id;
        public String name;
        public String status;
        public List<Stop> stops;
    }

    public class Stop {
        public String id;
        public Decimal sequenceNumber;
        public DateTime expectedArrivalStartTime;
        public DateTime expectedArrivalEndTime;
        public String trip;
        public String address;
        public String timezone;
        public String phone;
    }
}