import { LightningElement, track, api } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import { wire } from 'lwc';
import VOICE_MESSAGE_CHANNEL from '@salesforce/messageChannel/VoiceMessageChannel__c';
import processVoiceInput from '@salesforce/apex/VoiceAssistantController.processVoiceInput';

export default class VoiceAssistant extends LightningElement {
    @api agentName = ''; //reserverd for future use
    @track messages = [];
    @track buttonState = 'PUSH_TO_START';
    recognition = null;
    synthesis = null;
    firstInteraction = true;
    agentSessionId = null;

    @wire(MessageContext)
    messageContext;

    initializeSpeechCapabilities() {
        try {
            if ('SpeechRecognition' in window || 'webkitSpeechRecognition' in window) {
                this.recognition = new (window.SpeechRecognition || window.webkitSpeechRecognition)();
                this.setupRecognition();
            }
            if ('speechSynthesis' in window) {
                this.synthesis = window.speechSynthesis;
            }
        } catch (error) {
            console.error('Error initializing voice capabilities:', error);
        }
    }

    setupRecognition() {
        this.recognition.continuous = false;
        this.recognition.lang = 'en-US';
        
        this.recognition.onresult = (event) => {
            const transcript = event.results[0][0].transcript;
            this.handleVoiceInput(transcript);
        };

        this.recognition.onerror = (event) => {
            console.error('Speech recognition error:', event.error);
            this.updateButtonState('PUSH_TO_START');
        };
    }

    updateButtonState(newState) {
        this.buttonState = newState;
        const button = this.template.querySelector('.voice-button');
        if (button) {
            button.disabled = ['THINKING', 'REPLYING'].includes(newState);
        }
    }

    handleButtonClick() {
        this.dispatchMessage('System', 'Synthesis.' + this.synthesis, 'Error');
        try {
            if (!this.synthesis || !this.recognition) {
                this.initializeSpeechCapabilities();
                this.dispatchMessage('System', 'Mic initialisation.', 'Error');
            }
            navigator.mediaDevices.getUserMedia({ audio: true })
                .then(stream => {
                    stream.getTracks().forEach(track => track.stop());
                    this.processButtonClick();
                })
                .catch(error => {
                    this.dispatchMessage('System', 'Microphone access denied. Please check your settings.' + error, 'Error');
                    console.error('Microphone access denied:', error);
                });
        } catch (error) {
            this.dispatchMessage('System', 'Error accessing microphone:' + error, 'Error');
            console.error('Error accessing microphone:', error);
        }
    }

    async processButtonClick() {
        if (this.firstInteraction) {
            this.firstInteraction = false;
            await this.speakAndListen('How can I help you today?');
        } else if (this.buttonState === 'PUSH_TO_STOP') {
            this.endConversation();
        } else{
            await this.speakAndListen('Go on?');
        }
    }

    dispatchMessage(sender, text, type = 'Message') {
        const message = {
            sender: sender,
            text: text,
            type: type
        };
        
        publish(this.messageContext, VOICE_MESSAGE_CHANNEL, message);
    }

    async speakAndListen(text) {
        this.updateButtonState('REPLYING');
        this.dispatchMessage('Assistant', text);
        await this.textToSpeech(text);
        this.startListening();
    }

    startListening() {
        this.recognition.start();
        this.updateButtonState('PUSH_TO_STOP');
    }

    async handleVoiceInput(transcript) {
        try {
            this.updateButtonState('THINKING');
            this.dispatchMessage('User', transcript);

            const position = await this.getCurrentLocation();
            const response = await processVoiceInput({
                userInput: transcript,
                latitude: position.coords.latitude,
                longitude: position.coords.longitude,
                agentSessionId: this.agentSessionId
            });

            this.agentSessionId = response.agentSessionId;
            this.updateButtonState('REPLYING');
            this.dispatchMessage('Assistant', response.agentResponse);
            await this.textToSpeech(response.agentResponse);
            
            this.startListening(); // Automatically start listening after response
        } catch (error) {
            this.dispatchMessage('System', 'Error processing voice input:' + error, 'Error');
            console.error('Error processing voice input:', error);
            this.updateButtonState('PUSH_TO_START');
        }
    }

    getCurrentLocation() {
        return new Promise((resolve, reject) => {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(resolve, reject);
            } else {
                reject(new Error('Geolocation is not supported'));
            }
        });
    }

    textToSpeech(text) {
        return new Promise((resolve) => {
            if (this.synthesis) {
                const utterance = new SpeechSynthesisUtterance(text);
                utterance.lang = 'en-US';
                utterance.onend = resolve;
                this.synthesis.speak(utterance);
            } else {
                resolve();
            }
        });
    }

    endConversation() {
        this.recognition.stop();
        this.synthesis.cancel();
        this.updateButtonState('PUSH_TO_START');
    }

    addMessage(sender, text) {
        this.messages = [...this.messages, {
            id: Date.now(),
            sender,
            text,
            time: new Date().toLocaleTimeString()
        }];
    }

    get buttonText() {
        const textMap = {
            'PUSH_TO_START': 'Push To Start',
            'THINKING': 'Thinking',
            'REPLYING': 'Replying',
            'PUSH_TO_STOP': 'Push to Stop'
        };
        return textMap[this.buttonState];
    }
}