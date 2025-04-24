public class AgentSessionStartRequestDto {
    public String externalSessionKey;
    public InstanceConfig instanceConfig;
    public StreamingCapabilities streamingCapabilities;
    public Boolean bypassUser;
    public List<AgentVariableRequestDto> variables;

    public class InstanceConfig {
        public String endpoint;
    }

    public class StreamingCapabilities {
        public List<String> chunkTypes;
    }
}