public with sharing class RouteTableController {
    @AuraEnabled(cacheable=true)
    public static List<Route__c> getRoutes(Id contactId) {
        if (contactId == null) {
            return [
                SELECT Id, Name, 
                    (SELECT Name, Sequence_Number__c, Trip__c, 
                    Expected_Arrival_Start_Time__c, Expected_Arrival_End_Time__c, 
                    Expected_Departure_Time__c, Facility__r.Address__City__s,
                    Facility__r.Address__StateCode__s
                    FROM Stops__r 
                    ORDER BY Sequence_Number__c) 
                FROM Route__c
            ];
        }

        return [
            SELECT Id, Name, 
                (SELECT Name, Sequence_Number__c, Trip__c, 
                Expected_Arrival_Start_Time__c, Expected_Arrival_End_Time__c, 
                Expected_Departure_Time__c, Facility__r.Address__City__s,
                Facility__r.Address__StateCode__s
                FROM Stops__r 
                ORDER BY Sequence_Number__c) 
            FROM Route__c
            WHERE Id IN (SELECT Route__c FROM Route_Assignment__c WHERE Contact__c = :contactId)
        ];
    }
}