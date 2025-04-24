import { LightningElement, track, wire, api } from 'lwc';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import VOICE_MESSAGE_CHANNEL from '@salesforce/messageChannel/VoiceMessageChannel__c';

export default class VoiceAssistantLog extends LightningElement {
    @api isDebugMode = false;
    @track messages = [];
    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                VOICE_MESSAGE_CHANNEL,
                (message) => this.handleMessage(message)
            );
        }
    }

    handleMessage(message) {
        if ( message.type === 'Error' && !this.isDebugMode ) {
            return;
        }

        if (message.sender && message.text) {
            this.addMessage(message.sender, message.text);
        }
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    addMessage(sender, text) {
        this.messages = [...this.messages, {
            id: Date.now(),
            sender,
            text,
            time: new Date().toLocaleTimeString()
        }];
    }
}