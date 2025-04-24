public inherited sharing class AgentforceSelector {
    public List<BotDefinition> getByDevName(List<String> developerNamesList) {
    
        return [
            SELECT Id, DeveloperName, BotUserId, Description, 
                Type, AgentType, AgentTemplate
            FROM BotDefinition
            WHERE DeveloperName IN :developerNamesList
        ];
    }

    public BotDefinition getByDevName( String developerName) {
    
        List<BotDefinition> agents = getByDevName(new List<String>{developerName});
        if (agents == NULL || agents.isEmpty()) {
            return NULL;
        } 
        return agents[0];
    }
}