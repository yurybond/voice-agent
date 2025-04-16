public class AgentforceApi {
    private static final String BASE_URL = 'callout:AgentforceAPI';
    
    public class AgentSession {
        @AuraEnabled public String sessionId { get; set; }
        @AuraEnabled public String status { get; set; }
    }
    
    public class AgentResponse {
        @AuraEnabled public String content { get; set; }
        @AuraEnabled public String sessionId { get; set; }
    }
    
    public static AgentSession startSession(String agentName) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/agents/' + agentName + '/sessions');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + AgentforceAuthManager.getAccessToken());
        req.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 201) {
            Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            AgentSession session = new AgentSession();
            session.sessionId = (String)response.get('sessionId');
            session.status = (String)response.get('status');
            return session;
        }
        
        throw new AgentforceException('Failed to start session: ' + res.getBody());
    }
    
    @AuraEnabled
    public static AgentResponse sendMessage(String agentName, String sessionId, String message) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/agents/' + agentName + '/sessions/' + sessionId + '/messages');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + AgentforceAuthManager.getAccessToken());
        req.setHeader('Content-Type', 'application/json');
        
        Map<String, Object> body = new Map<String, Object>{
            'content' => message,
            'role' => 'user'
        };
        req.setBody(JSON.serialize(body));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            AgentResponse agentResponse = new AgentResponse();
            agentResponse.content = (String)response.get('content');
            agentResponse.sessionId = sessionId;
            return agentResponse;
        }
        
        throw new AgentforceException('Failed to send message: ' + res.getBody());
    }
    
    public class AgentforceException extends Exception {}
}