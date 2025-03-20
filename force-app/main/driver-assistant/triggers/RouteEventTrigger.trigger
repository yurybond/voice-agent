trigger RouteEventTrigger on Route_Event__c (after insert) {
    RouteEventTriggerHandler.handleAfterInsert(Trigger.new);
}