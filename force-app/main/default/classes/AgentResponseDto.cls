public class AgentResponseDto {
    public List<Message> messages;
    public Links XX_links;
    
    public class Message {
        public String type;
        public String id;
        public String feedbackId;
        public String planId;
        public Boolean isContentSafe;
        public String message;
        public List<Object> result;
    }
    
    public class Links {
        public Object self;
        public Link messages;
        public Link session;
        public Link XXend;
    }
    
    public class Link {
        public String href;
    }
}