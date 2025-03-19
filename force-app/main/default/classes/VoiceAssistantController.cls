public with sharing class VoiceAssistantController {
    @AuraEnabled
    public static String processVoiceInput(String userInput, Decimal latitude, Decimal longitude) {
        try {
            // Return the response
            return 'I have received a message: ' + userInput;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error processing voice input: ' + e.getMessage());
            throw new AuraHandledException('Error processing voice input: ' + e.getMessage());
        }
    }
}