/**
 * Created by Vsevolod_Bogdanov on 2/7/2025.
 */

public without sharing class RouteMapController {
    public static String getRouteId() {
        String contactId = (String) [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]?.ContactId ?? '';
        if (!String.isBlank(contactId)) {
            String result = (String) [
                    SELECT Route__c
                    FROM Route_Assignment__c
                    WHERE Contact__c = :contactId AND Route__r.Status__c = 'In-Progress'
                    LIMIT 1
            ]?.Route__c;

            return result;
        }

        return '';
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getRoutePoints(String routeId) {
        Map<String, Object> result = new Map<String, Object>();
        if (String.isBlank(routeId)) {
            routeId = getRouteId();
        }

        if (!String.isBlank(routeId)) {

            List<Stop__c> routePoints = [
                    SELECT Name, Sequence_Number__c, Type__c, Facility__r.Address__c
                    FROM Stop__c
                    WHERE Route__c = :routeId
                    ORDER BY Sequence_Number__c
            ];
            result.put('routePoints', routePoints);

            List<Route_Event__c> routeEvents = [
                    SELECT Name, Description__c, Location__c, Location__Latitude__s, Location__Longitude__s
                    FROM Route_Event__c
                    WHERE Route__c = :routeId
            ];

            result.put('routeEvents', routeEvents);
        }

        return result;
    }

}