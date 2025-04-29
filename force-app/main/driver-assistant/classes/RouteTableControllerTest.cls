@IsTest
private class RouteTableControllerTest {
    
    @TestSetup
    static void makeData(){
        // Create test facility
        Facility__c facility = new Facility__c(
            Name = 'Test Facility',
            Address__City__s = 'New York',
            Address__StateCode__s = 'NY',
            Address__CountryCode__s = 'US'
        );
        insert facility;
        
        // Create test route
        Route__c route = new Route__c(
            Status__c = 'New'
        );
        insert route;
        
        // Create test stops
        List<Stop__c> stops = new List<Stop__c>();
        Datetime now = System.now();
        
        stops.add(new Stop__c(
            Name = 'Origin Stop',
            Route__c = route.Id,
            Facility__c = facility.Id,
            Sequence_Number__c = 1,
            Type__c = 'Origin',
            Expected_Arrival_Start_Time__c = now,
            Expected_Arrival_End_Time__c = now.addHours(2),
            Expected_Departure_Time__c = now.addHours(3)
        ));
        
        stops.add(new Stop__c(
            Name = 'Destination Stop',
            Route__c = route.Id,
            Facility__c = facility.Id,
            Sequence_Number__c = 2,
            Type__c = 'Destination',
            Expected_Arrival_Start_Time__c = now.addDays(1),
            Expected_Arrival_End_Time__c = now.addDays(1).addHours(2),
            Expected_Departure_Time__c = now.addDays(1).addHours(3)
        ));
        
        insert stops;
    }
    
    @IsTest
    static void testGetRoutes() {
        Test.startTest();
        List<Route__c> routes = RouteTableController.getRoutes(NULL);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, routes.size(), 'Should return one route');
        System.assertEquals(2, routes[0].Stops__r.size(), 'Route should have two stops');
        
        // Verify stop details
        Stop__c originStop = routes[0].Stops__r[0];
        System.assertEquals('Origin', originStop.Type__c, 'First stop should be Origin');
        System.assertEquals(1, originStop.Sequence_Number__c, 'First stop should have sequence 1');
        System.assertEquals('New York', originStop.Facility__r.Address__City__s, 'City should match');
        System.assertEquals('NY', originStop.Facility__r.Address__StateCode__s, 'State should match');
    }
}