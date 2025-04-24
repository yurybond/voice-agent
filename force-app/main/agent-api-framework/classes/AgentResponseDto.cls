public class AgentResponseDto {
    public String sessionId;
    public List<Message> messages;
    
    public class Message {
        public String type;
        public String id;
        public String feedbackId;
        public String planId;
        public Boolean isContentSafe;
        public String message;
        public List<Object> result;
        public List<Object> citedReferences;
    }
}