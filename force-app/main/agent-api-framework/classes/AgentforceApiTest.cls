@IsTest
private class AgentforceApiTest {
    private static final String MOCK_SESSION_ID = '8e715939-a121-40ec-80e3-a8d1ac89da33';
    private static final String MOCK_AGENT_NAME = 'Driver_Support';
    private static final String MOCK_CONTACT_ID = '003GA00004C7RxdYAF';
    
    class SelectorMock implements System.StubProvider {

    
        public Object handleMethodCall(
            Object stubbedObject, 
            String stubbedMethodName,
            Type returnType, 
            List<Type> listOfParamTypes,
            List<String> listOfParamNames, 
            List<Object> listOfArgs) {

            return new BotDefinition(Id = '0XxGA00000008d90AA');
        }
    }

    @IsTest
    static void testStartSession() {
        // Mock the HttpCallout
        Test.setMock(HttpCalloutMock.class, new AgentforceApiMock());
        AgentforceApi api = new AgentforceApi();

        //Mock Selector
        SelectorMock selectorMock = new SelectorMock();
        Test.createStub(
            AgentforceSelector.class, 
            selectorMock
        );
        
        // Act
        Test.startTest();
        AgentResponseDto response = api
            .setAgentforceAgent(MOCK_AGENT_NAME)
            .setTimezone('America/Los_Angeles')
            .setVariable('$Context.Contact', MOCK_CONTACT_ID)
            .startSession();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, api.getAgentforceSessionId(), 'Session ID should be set');
        System.assertEquals(1, response.messages.size(), 'Should have one message');
        System.assertEquals('Inform', response.messages[0].type, 'Message type should be Inform');
    }
    
    @IsTest
    static void testSendMessage() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceApiMock());
        AgentforceApi api = new AgentforceApi();
        
        // Act
        Test.startTest();
        AgentResponseDto response = api
            .setAgentforceSessionId(MOCK_SESSION_ID)
            .setVariable('$Context.Contact', MOCK_CONTACT_ID)
            .sendMessage('Show me my routes');
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertEquals(1, response.messages.size(), 'Should have one message');
    }
    
    @IsTest
    static void testStopSession() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceApiMock());
        AgentforceApi api = new AgentforceApi();
        
        // Act
        Test.startTest();
        api.setAgentforceSessionId(MOCK_SESSION_ID)
           .stopSession();
        Test.stopTest();
    }
    
    private class AgentforceApiMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            if (req.getEndpoint().endsWith('/sessions')) {
                if (req.getMethod() == 'POST') {
                    // Start session response
                    res.setStatusCode(201);
                    res.setBody(getStartSessionResponse());
                } else if (req.getMethod() == 'DELETE') {
                    // Stop session response
                    res.setStatusCode(204);
                }
            } else if (req.getEndpoint().contains('/messages')) {
                // Send message response
                res.setStatusCode(200);
                res.setBody(getMessageResponse());
            }
            
            return res;
        }
        
        private String getStartSessionResponse() {
            AgentResponseDto response = new AgentResponseDto();
            response.sessionId = MOCK_SESSION_ID;
            response.messages = new List<AgentResponseDto.Message>{
                new AgentResponseDto.Message()
            };
            response.messages[0].type = 'Inform';
            response.messages[0].id = System.UUID.randomUUID().toString();
            response.messages[0].message = 'Session started successfully.';
            return JSON.serialize(response);
        }
        
        private String getMessageResponse() {
            AgentResponseDto response = new AgentResponseDto();
            response.messages = new List<AgentResponseDto.Message>{
                new AgentResponseDto.Message()
            };
            response.messages[0].type = 'Inform';
            response.messages[0].id = System.UUID.randomUUID().toString();
            response.messages[0].message = 'Here are your routes.';
            return JSON.serialize(response);
        }
    }
}