public with sharing class VoiceAssistantController {

    @AuraEnabled
    public static VoiceAssistantAgentService.AgentResponse processVoiceInput(String agentDevName, String userInput, String agentSessionId, Decimal latitude, Decimal longitude) {
        try {

            Location location =  Location.newInstance(latitude, longitude);
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()]?.ContactId ?? NULL;
            //VoiceAssistantAgentService.AgentResponse reply = VoiceAssistantAgentService.passCommandToAgentforce(agentDevName, contactId, userInput, location, agentSessionId);
            String timezone = UserInfo.getTimeZone().getID();
            VoiceAssistantAgentService.AgentResponse reply = VoiceAssistantAgentService.passCommandToAgentforceViaApi(agentDevName, timezone, contactId, userInput, location, agentSessionId);
            return reply;
        } catch (Exception e) {
            throw new AuraHandledException('Error processing voice input: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void stopSession(String agentSessionId) {
        try {
            VoiceAssistantAgentService.stopSession(agentSessionId);
        } catch (Exception e) {
            throw new AuraHandledException('Error finishing session: ' + e.getMessage());
        }
    }
}