import {LightningElement, api, wire, track} from "lwc";
import {showStatusLanguageModel, stopConversationAI} from "./localeAIUtils"
import passCommandToAgentforce from '@salesforce/apex/VoiceCommandController.passCommandToAgentforce';
import pubsub from 'c/pubsub';
import {CurrentPageReference} from 'lightning/navigation';

export default class VoiceRecognition extends LightningElement {

    recognition = new webkitSpeechRecognition();
    isListening = false;
    transcript = '';
    sessionId = '';
    @track
    status = 'idle';
    @track
    conversationLog = [];
    isSpinnerLoading = false;
    stopPhrases = ["No", "I am good", "I'm good", "No, I am good", "no I'm good", "Nothing else", "Bye", "Nope", "No thank you"];
    isLocaleAIReady = false;
    latitude = 10;
    longitude = 10;
    @wire(CurrentPageReference) pageRef;
    hasNotGreetedYet = true;

    connectedCallback() {
        this.setupRecognition();
        showStatusLanguageModel().then(result => this.isLocaleAIReady = result === 'readily');
    }

    async greetUser () {
        if (this.hasNotGreetedYet) {
            this.textToSpeech('Hello, how can I help you?');
            this.hasNotGreetedYet = false;
        }
    }

    stopConversation(response) {
        return this.stopPhrases.some((phrase) => response.trim().toLowerCase().replaceAll(".", " ").replaceAll(",", " ") === phrase.toLowerCase());
    }

    getCurrentPosition() {
        return new Promise((resolve, reject) => {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(resolve, reject);
            } else {
                publishVoiceRecognitionError('Geolocation is not supported by this browser.');
                reject(new Error('Geolocation is not supported by this browser.'));
            }
        });
    }

    async getUserLocation() {
        try {
            const position = await this.getCurrentPosition();
            this.latitude = position.coords.latitude;
            this.longitude = position.coords.longitude;
        } catch (error) {
            this.latitude = null;
            this.longitude = null;
        }
    }

    setupRecognition() {
        this.recognition.continuous = true;
        this.recognition.lang = 'en-US';
        this.recognition.interimResults = false;

        this.recognition.onresult = async (event) => {

            const currentResultIndex = event.resultIndex;
            const transcriptData = event.results[currentResultIndex][0].transcript.trim();
            this.transcript = transcriptData;

            if (!this.transcript) {
                publishVoiceRecognitionError('Transcript data is null');
                return;
            }

            // Process or display the result here
            this.conversationLog.push({isAgent: false, reply: this.transcript});
            this.processComandNoListen();
            this.isSpinnerLoading = true;

            if (this.isLocaleAIReady ? await stopConversationAI(this.transcript) : this.stopConversation(this.transcript)) {
                this.isSpinnerLoading = false;
                this.conversationLog.push({isAgent: true, reply: 'Goodbye'});
                this.endConversation();
                this.textToSpeech('Goodbye', true);
                return;
            }

            await this.getUserLocation();

            passCommandToAgentforce({
                command: transcriptData,
                latitude: this.latitude,
                longitude: this.longitude,
                sessionId: this.sessionId,
            })
                .then(response => {
                    this.sessionId = response.sessionId;
                    this.isSpinnerLoading = false;
                    this.conversationLog.push({isAgent: true, reply: response.agentResponse});
                    this.processComandNoListen();
                    if (response.agentResponse.trim().at(-1) !== '?') {
                        this.conversationLog.push({isAgent: true, reply: 'Anything else I can help you with?'});
                        this.textToSpeech(response.agentResponse + ' Anything else I can help you with?');
                    } else {
                        this.textToSpeech(response.agentResponse);
                    }

                })
                .catch(error => {
                    publishVoiceRecognitionError('Error invoking VoiceCommandController.passCommandToAgent:' + error);
                    console.error('Error invoking VoiceCommandController.passCommandToAgent:', error);
                });
        }

    }

    handleStartStopClick() {
        navigator.mediaDevices.getUserMedia({audio: true})
            .then(stream => {
                stream.getTracks().forEach(track => track.stop());
            })
            .catch(error => {
                this.publishVoiceRecognitionError('Microphone access is denied.' + error);
            });
        if (this.isListening) {
            this.endConversation();
        } else {
            this.doListen();
        }
    }

    doListen() {
        this.recognition.start();
        this.isListening = true;
        this.status = 'listening';
        this.transcript = '';
    }

    processComandNoListen() {
        this.recognition.stop();
        this.isListening = false;
        this.status = 'thinking';
    }

    endConversation() {
        this.recognition.stop();
        this.isListening = false;
        this.status = 'idle';
    }

    textToSpeech(text, stopListening = false) {
        if ('speechSynthesis' in window) {

            window.speechSynthesis.cancel(); // removes anything 'stuck'
            window.speechSynthesis.getVoices();

            const utterance = new SpeechSynthesisUtterance(text);
            utterance.lang = 'en-US';
            utterance.pitch = 1;
            utterance.rate = 1;
            utterance.volume = 1;
            utterance.onend = () => stopListening ? this.processComandNoListen : this.doListen();
            window.speechSynthesis.speak(utterance);
        } else {
            this.publishVoiceRecognitionError('Sorry, your browser does not support the Web Speech API.');
            console.error('Sorry, your browser does not support the Web Speech API.');
        }
    }

    publishVoiceRecognitionError(errorMessage) {
        pubsub.fireEvent(this.pageRef, 'voiceRecognitionErrorEvent', {message: errorMessage});
    }

    get isThinking() {
        return this.status === 'thinking';
    }

    get isIdle() {
        return this.status === 'idle';
    }

}