public class AgentforceApi {
    private static final String BASE_URL = 'callout:AgentApi';
    private String UserTimezone = 'America/Chicago';
    private String ExternalSessionKey;
    private Id AgentforceAgentId;
    private List<AgentVariableRequestDto> Variables;
    private String AgentSfOrgDomainUrl;
    private String AgentforceSessionId;

    public AgentforceApi setTimezone(String timezone) {
        this.userTimezone = timezone;
        return this;
    }

    public AgentforceApi setExternalSessionKey(String externalSessionKey) {
        this.externalSessionKey = externalSessionKey;
        return this;
    }

    public AgentforceApi setVariable(String name, String value) {
        if (this.Variables == null) {
            this.Variables = new List<AgentVariableRequestDto>();

        }
        AgentVariableRequestDto variable = new AgentVariableRequestDto(name, value);
        this.variables.add(variable);
        return this;
    }

    public AgentforceApi setVariables(Map<String, Object> variables) {
        for (String name : variables.keySet()) {
            setVariable(name, String.valueOf(variables.get(name)));

        }
        return this;
    }

    public AgentforceApi setAgentforceAgent(String agentDevName) {
        try {
            this.AgentforceAgentId = new AgentforceSelector().getByDevName(agentDevName).Id;
        } catch (Exception ex) {
            throw new AgentforceException('Could not find agentorce with name ' + agentDevName + ' : ' + ex.getMessage());
        }
        return this;
    }

    public Id getAgentforceAgentId() {
        return this.AgentforceAgentId;
    }

    public AgentforceApi setAgentforceSessionId(String sessionId) {
        this.AgentforceSessionId = sessionId;
        return this;
    }
    public String getAgentforceSessionId() {
        return this.AgentforceSessionId;
    }

    public AgentforceApi setAgentSfOrgDomainUrl(String agentSfOrgDomainUrl) {
        this.AgentSfOrgDomainUrl = agentSfOrgDomainUrl;
        return this;
    }


    public AgentResponseDto startSession() {

        if (this.AgentforceAgentId == null) {
            throw new AgentforceException('Agentforce agent ID is not set. Please use setAgentforceAgent() method to set it.');
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/agents/' + this.AgentforceAgentId + '/sessions');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        AgentSessionStartRequestDto requestBody = new AgentSessionStartRequestDto();
        requestBody.tz = this.UserTimezone;
        requestBody.externalSessionKey = this.ExternalSessionKey ?? requestBody.externalSessionKey;
        requestBody.instanceConfig.endpoint = this.AgentSfOrgDomainUrl ?? requestBody.instanceConfig.endpoint;
        requestBody.variables = this.Variables;
        req.setBody(JSON.serialize(requestBody));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() > 399) {
            throw new AgentforceException('Failed to start session: ' + res.getBody());
        }

        AgentResponseDto response = (AgentResponseDto)JSON.deserialize(res.getBody(), AgentResponseDto.class);
        this.AgentforceSessionId = response.sessionId;
        return response;
    }

    public AgentResponseDto sendMessage(String message) {

        if (this.AgentforceSessionId == null) {
            throw new AgentforceException('Agentforce session ID is not set. Please use startSession() method to set it.');
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/sessions/' + this.AgentforceSessionId + '/messages');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        AgentSyncMessageRequestDto requestBody = new AgentSyncMessageRequestDto();
        requestBody.message.text = message;
        requestBody.variables = this.Variables;
        req.setBody(JSON.serialize(requestBody));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() > 399) {
            throw new AgentforceException('Failed to send message: ' + res.getBody());
        }

        AgentResponseDto response = (AgentResponseDto)JSON.deserialize(res.getBody(), AgentResponseDto.class);
        
        return response;
    }

    public void stopSession() {
        if (this.AgentforceSessionId == null) {
            throw new AgentforceException('Agentforce session ID is not set. Please use startSession() method to set it.');
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/sessions/' + this.AgentforceSessionId);
        req.setMethod('DELETE');
        req.setHeader('x-session-end-reason', 'UserRequest');

        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() > 399) {
            throw new AgentforceException('Failed to stop session: ' + res.getBody());
        }
    }
 
    public class AgentforceException extends Exception {}
}

/**
         if (location != null) {
            dto.variables.add(new AgentVariableRequestDto('$Context.Latitude', 
                String.valueOf(location.getLatitude())));
            dto.variables.add(new AgentVariableRequestDto('$Context.Longitude', 
                String.valueOf(location.getLongitude())));
        }
        
        // Add contact if provided
        if (String.isNotBlank(contactId)) {
            dto.variables.add(new AgentVariableRequestDto('$Context.Contact', contactId));
        }
 */