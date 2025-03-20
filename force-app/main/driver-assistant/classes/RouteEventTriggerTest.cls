@IsTest
private class RouteEventTriggerTest {
    
    @testSetup static void testSetup() {
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        
        Route__c route = new Route__c(Status__c = 'New');
        insert route;
        
        Route_Assignment__c routeAssignment = new Route_Assignment__c(Route__c = route.Id, Contact__c = testContact.Id);
        insert routeAssignment;
        
        Facility__c facility = new Facility__c(Name = 'Test Facility');
        insert facility;
        
        List<Stop__c> stops = new List<Stop__c>();
        
        Stop__c stopOrigin = new Stop__c();
        stopOrigin.Name = 'Test stop';        
        stopOrigin.Route__c = route.Id;
        stopOrigin.Facility__c = facility.Id;
        stopOrigin.Sequence_Number__c = 1;
        stopOrigin.Trip__c = 'Origin';
        stops.add(stopOrigin);
        
        Stop__c stopDestination = new Stop__c();
        stopDestination.Name = 'Test stop';        
        stopDestination.Route__c = route.Id;
        stopDestination.Facility__c = facility.Id;
        stopDestination.Sequence_Number__c = 1;
        stopDestination.Trip__c = 'Destination';
        stops.add(stopDestination);
        
        insert stops;        
	}
    
    @IsTest
    private static void insertRouteEventWithArrivalStatus() {
        Stop__c originStop = [SELECT Id, Route__c FROM Stop__c WHERE Trip__c = 'Origin' LIMIT 1];
        
        Route_Event__c routeEvent = new Route_Event__c(Route__c = originStop.Route__c, Stop__c = originStop.Id,
                                                       Type__c = 'Arrival');
        
        Test.startTest();
        insert routeEvent;
        Test.stopTest();
        
        Route__c route = [SELECT Status__c FROM Route__c LIMIT 1];
        
        Assert.areEqual('In-Progress', route.Status__c);
    }
    
    @IsTest
    private static void insertRouteEventWithDepartureStatus() {
        Stop__c originStop = [SELECT Id, Route__c FROM Stop__c WHERE Trip__c = 'Destination' LIMIT 1];
        
        Route_Event__c routeEvent = new Route_Event__c(Route__c = originStop.Route__c, Stop__c = originStop.Id,
                                                       Type__c = 'Departure');
        
        Test.startTest();
        insert routeEvent;
        Test.stopTest();
        
        Route__c route = [SELECT Status__c FROM Route__c LIMIT 1];
        
        Assert.areEqual('Delivered', route.Status__c);
    }
}