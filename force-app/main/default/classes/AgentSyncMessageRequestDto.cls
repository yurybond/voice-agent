public class AgentSyncMessageRequestDto {
    public Message message;
    public List<AgentVariableRequestDto> variables;
    
    public class Message {
        public Integer sequenceId;
        public String type;
        public String text;
    }
}