export async function showStatusLanguageModel() {
    if (window.ai && window.ai.languageModel) {
        let capabilities = await ai.languageModel.capabilities();
        return capabilities.available;
    }
}

async function showStatusSummarizer() {
    if (window.ai && window.ai.summarizer) {
        let capabilities = await ai.summarizer.capabilities();
        return capabilities.available;
    }
}

export async function stopConversationAI(response) {
    const session = await ai.languageModel.create();

    const promptText = `You are a service support specialist. You're working with drivers.
    You asked user \"Anything else I can help you with now or later?\".
     User answered \"${response}\".
     You should avoid unnecessary interaction and you should stop conversation if no action needed
     or the user has clearly indicated they have no further requests.
     If you don't have needed information you should NOT stop conversation.
     Should You stop or continue conversation? Respond with 'Stop' or 'Continue' and after give details but be brief`

    console.log("promptText", promptText);
    try {
        const result = await session.prompt(promptText);
        console.log('result', result);
        return (result && result.trim().toLowerCase().startsWith('stop'))
    }
    catch {
        return false
    }

}