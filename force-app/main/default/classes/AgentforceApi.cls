public class AgentforceApi {
    private static final String BASE_URL = 'callout:AgentforceAPI';
    private static final String INSTANCE_URL = 'https://orgfarm-82d75052d9-dev-ed.develop.my.salesforce.com';

    
    
    public static AgentResponseDto startSession(String agentName, Id contactId, Location location) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/agents/' + agentName + '/sessions');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        AgentSessionStartRequestDto requestBody = new AgentSessionStartRequestDto();
        requestBody.externalSessionKey = 'session_' + System.currentTimeMillis();
        requestBody.instanceConfig = new AgentSessionStartRequestDto.InstanceConfig();
        requestBody.instanceConfig.endpoint = BASE_URL + '/agents/' + agentName;
        requestBody.streamingCapabilities = new AgentSessionStartRequestDto.StreamingCapabilities();
        requestBody.streamingCapabilities.chunkTypes = new List<String>{'Text'};
        requestBody.bypassUser = true;
        requestBody.variables = new List<AgentVariableRequestDto>();
        AgentVariableRequestDto contact = new AgentVariableRequestDto('$Conntact', contactId);
        AgentVariableRequestDto latitude = new AgentVariableRequestDto('$Latitude', location.getLatitude().toString());
        AgentVariableRequestDto longitude = new AgentVariableRequestDto('$Longitude', location.getLongitude().toString());
        requestBody.variables.add(contact);
        requestBody.variables.add(latitude);
        requestBody.variables.add(longitude);
        req.setBody(JSON.serialize(requestBody));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 201) {
            AgentResponseDto response = (AgentResponseDto)JSON.deserialize(res.getBody(), AgentResponseDto.class);
            return response;
        }
        
        throw new AgentforceException('Failed to start session: ' + res.getBody());
    }
 
    public class AgentforceException extends Exception {}
}