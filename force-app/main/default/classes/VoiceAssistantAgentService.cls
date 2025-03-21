public inherited sharing class VoiceAssistantAgentService {
    public class AgentResponse {
        @AuraEnabled
        public String command { get; set; }
        @AuraEnabled
        public String agentResponse { get; set; }
        @AuraEnabled
        public String sessionId { get; set; }
    }

    public static AgentResponse passCommandToAgentforce(Id contact, String userMessage, Location location, String sessionId) {
        AgentResponse ear = new AgentResponse();
        ear.command = userMessage;
        try {
            Invocable.Action action = Invocable.Action.createCustomAction('generateAiAgentResponse', 'Driver_Support');

            action.setInvocationParameter('userMessage', userMessage);
            action.setInvocationParameter('Latitude', location.getLatitude().toString());
            action.setInvocationParameter('Longitude', location.getLongitude().toString());
            action.setInvocationParameter('Contact', contact);

            if (!String.isBlank(sessionId)) {
                action.setInvocationParameter('SessionID', sessionId);
            }

            // Execute the action
            List<Invocable.Action.Result> results = action.invoke();
            Invocable.Action.Result result = results[0];

            // Handle the response
            if (result.isSuccess()) {
                // Retrieve the Session id and Agent Response
                Map<String, Object> agentResponse = (Map<String, Object>)JSON.deserializeUntyped((String)result.getOutputParameters().get('agentResponse'));
                ear.agentResponse = (String)agentResponse.get('value');
                ear.sessionId = (String) result.getOutputParameters().get('sessionId');
            } else {
                ear.agentResponse = 'There is a technical problem:' + JSON.serialize(result.getErrors());
            }
        } catch (Exception e) {
            ear.agentResponse = 'Error invoking Java action: ' + e.getMessage();
        }
        return ear;
    }
}