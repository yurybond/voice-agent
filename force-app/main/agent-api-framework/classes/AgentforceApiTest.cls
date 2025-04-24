@IsTest
private class AgentforceApiTest {
    private static final String MOCK_TOKEN = 'mock_token';
    private static final String MOCK_SESSION_ID = 'mock_session_id';
    
    @IsTest
    static void testStartSession() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceMock());
        
        // Act
        Test.startTest();
        AgentforceAPI.AgentSession session = AgentforceAPI.startSession('TestAgent');
        Test.stopTest();
        
        // Assert
        System.assertEquals(MOCK_SESSION_ID, session.sessionId);
        System.assertEquals('active', session.status);
    }
    
    @IsTest
    static void testSendMessage() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceMock());
        
        // Act
        Test.startTest();
        AgentforceAPI.AgentResponse response = AgentforceAPI.sendMessage('TestAgent', MOCK_SESSION_ID, 'Test message');
        Test.stopTest();
        
        // Assert
        System.assertEquals('Mock response', response.content);
        System.assertEquals(MOCK_SESSION_ID, response.sessionId);
    }
    
    private class AgentforceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            if (req.getEndpoint().endsWith('/sessions')) {
                res.setStatusCode(201);
                res.setBody('{"sessionId":"' + MOCK_SESSION_ID + '","status":"active"}');
            } else if (req.getEndpoint().contains('/messages')) {
                res.setStatusCode(200);
                res.setBody('{"content":"Mock response"}');
            }
            
            return res;
        }
    }
}