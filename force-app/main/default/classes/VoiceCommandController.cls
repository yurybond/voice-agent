public with sharing class VoiceCommandController {
    public class AgentResponse {
        @AuraEnabled
        public String command { get; set; }
        @AuraEnabled
        public String agentResponse { get; set; }
        @AuraEnabled
        public String sessionId { get; set; }
    }

    public class Result {
        public String type { get; set; }
        public String value { get; set; }
    }

    private static String getAccount() {
        return (String) [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]?.Contact.AccountId
                ?? '001aj00000g4CyXAAU';
    }

    @AuraEnabled
    public static AgentResponse passCommandToAgentforce(String command, Decimal latitude, Decimal longitude, String sessionId) {
        AgentResponse ar = new AgentResponse();
        ar.command = command;
        try {
            Invocable.Action action = Invocable.Action.createCustomAction('generateAiAgentResponse', 'Driver_Support');

            action.setInvocationParameter('userMessage', command);
            action.setInvocationParameter('Latitude', latitude.toString());
            action.setInvocationParameter('Longitude', longitude.toString());
            action.setInvocationParameter('Account', getAccount());

            if (!String.isBlank(sessionId)) {
                action.setInvocationParameter('SessionID', sessionId);
            }

            // Execute the action
            List<Invocable.Action.Result> results = action.invoke();
            Invocable.Action.Result result = results[0];

            // Handle the response
            if (result.isSuccess()) {
                // Retrieve the Session id and Agent Response
                Result agentResponse = (Result) JSON.deserialize((String) result.getOutputParameters().get('agentResponse'), Result.class);
                ar.agentResponse = agentResponse.value;
                ar.sessionId = (String) result.getOutputParameters().get('sessionId');

            } else {
                ar.agentResponse = 'There is a technical problem:' + JSON.serialize(result.getErrors());
                System.debug('Java action execution failed: ' + result.getErrors());
            }
        } catch (Exception e) {
            ar.agentResponse = 'Error invoking Java action: ' + e.getMessage();
            System.debug('Error invoking Java action: ' + e.getMessage());
        }
        return ar;
    }
}