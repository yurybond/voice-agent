public class AgentVariableRequestDto {
    public String name;
    public String type;
    public String value;
    public AgentVariableRequestDto(String name, String value) {
        this.name = name;
        this.type = 'Text';
        this.value = value;

    }
}