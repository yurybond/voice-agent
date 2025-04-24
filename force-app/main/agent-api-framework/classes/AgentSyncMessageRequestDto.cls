public class AgentSyncMessageRequestDto {
    public Message message = new Message();
    public List<AgentVariableRequestDto> variables;
    
    public class Message {
        public Long sequenceId = System.currentTimeMillis();
        public String type = 'Text';
        public String text;
    }
}