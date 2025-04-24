public with sharing class VoiceAssistantController {

    @AuraEnabled
    public static VoiceAssistantAgentService.AgentResponse processVoiceInput(String userInput, String agentSessionId, Decimal latitude, Decimal longitude) {
        try {

            Location location =  Location.newInstance(latitude, longitude);
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()]?.ContactId ?? NULL;
            VoiceAssistantAgentService.AgentResponse reply = VoiceAssistantAgentService.passCommandToAgentforce(contactId, userInput, location, agentSessionId);
            system.debug(JSON.serialize(reply));
            return reply;
        } catch (Exception e) {
            throw new AuraHandledException('Error processing voice input: ' + e.getMessage());
        }
    }
}