import { LightningElement, wire, track } from 'lwc';
import pubsub from 'c/pubsub' ;
import { CurrentPageReference } from 'lightning/navigation';

export default class VoiceRecognitionErrorHandler extends LightningElement {
    @track
    errorMessage;
    @wire(CurrentPageReference) pageRef;
    connectedCallback() {
        pubsub.registerListener('voiceRecognitionErrorEvent', this.handleErrorEvent.bind(this), this);
    }

    disconnectedCallback() {
        //unsubscribe('voiceRecognitionErrorEvent', this.handleErrorEvent.bind(this));
    }

    handleErrorEvent(event) {
        this.errorMessage = event.message;
    }

    testSpeech() {
        speechSynthesis.cancel(); // Reset any messages in the queue
        speechSynthesis.speak(
            new SpeechSynthesisUtterance(
                'Hello, this is the test message!',
                'en-US'
            )
        );
    }

    get isVoiceRecognitionEnabled() {
        return window.SpeechRecognition !== undefined;
    }

    get isWebkitSpeechRecognitionEnabled() {
        return window.webkitSpeechRecognition !== undefined;
    }

    get isSpeechSynthesisUtterance() {
        return window.SpeechSynthesisUtterance !== undefined;
    }

    get isSpeechSynthesis() {
        return 'speechSynthesis' in window;
    }

    get isLocationEnabled() {
        return window.navigator.geolocation !== undefined;
    }
}