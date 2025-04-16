public class AgentforceAuthManager {
    private static final String NAMED_CREDENTIAL = 'AgentforceAPI';
    private static final String TOKEN_ENDPOINT = 'https://api.einstein.salesforce.com/v1/oauth2/token';
    
    @TestVisible
    private static String cachedToken;
    private static DateTime tokenExpiry;
    
    public static String getAccessToken() {
        if (isTokenValid()) {
            return cachedToken;
        }
        
        return refreshToken();
    }
    
    private static Boolean isTokenValid() {
        return cachedToken != null && tokenExpiry != null && tokenExpiry > DateTime.now();
    }
    
    private static String refreshToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        String assertion = generateJWT();
        String body = 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + assertion;
        req.setBody(body);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> tokenResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            cachedToken = (String)tokenResponse.get('access_token');
            Integer expiresIn = Integer.valueOf(tokenResponse.get('expires_in'));
            tokenExpiry = DateTime.now().addSeconds(expiresIn);
            return cachedToken;
        }
        
        throw new AgentforceException('Failed to obtain token: ' + res.getBody());
    }
    
    private static String generateJWT() {
        // Implementation depends on your JWT generation approach
        // You'll need to include your private key and other JWT claims
        return 'your_jwt_token_here';
    }
    
    public class AgentforceException extends Exception {}
}