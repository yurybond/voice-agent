public class AgentSessionStartRequestDto {
    public String externalSessionKey = String.valueOf(System.currentTimeMillis());
    public InstanceConfig instanceConfig;
    public String tz = 'America/Chicago';
    public List<AgentVariableRequestDto> variables;
    public String featureSupport = 'Strieaming';
    public StreamingCapabilities streamingCapabilities;
    public Boolean bypassUser = true;
    public class InstanceConfig {
        public String endpoint;
    }

    public class StreamingCapabilities {
        public List<String> chunkTypes;
    }

    public AgentSessionStartRequestDto() {
        this.instanceConfig = new InstanceConfig();
        this.instanceConfig.endpoint = URL.getOrgDomainUrl().toExternalForm(); //same org
        this.streamingCapabilities = new StreamingCapabilities();
        this.streamingCapabilities.chunkTypes = new List<String>{ 'Text' };
    }
}