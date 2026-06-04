import { LightningElement, wire } from 'lwc';
import createSupportCase from '@salesforce/apex/CaseResolutionController.createSupportCase';
import getRecommendation from '@salesforce/apex/CaseResolutionController.getRecommendation';
import resolveCase from '@salesforce/apex/CaseResolutionController.resolveCase';
import getProductOptions from '@salesforce/apex/CaseResolutionController.getProductOptions';

const STATE = {
    INPUT: 'INPUT',
    LOADING: 'LOADING',
    RECOMMENDATION: 'RECOMMENDATION',
    RESOLVING: 'RESOLVING',
    RESOLVED: 'RESOLVED',
    CASE_CREATED: 'CASE_CREATED'
};

const POLL_INTERVAL_MS = 2500;
const MAX_POLL_ATTEMPTS = 36;
// Keep in sync with CaseResolutionController
const NO_ANSWER_MESSAGE =
    'Thank you for your question. We could not find a specific answer in our knowledge base at this time. ' +
    'Our support team will review your case and follow up with you shortly.';
const TIMEOUT_MESSAGE =
    'Thank you for your patience. We are still processing your question. ' +
    'Our support team has your case and will follow up with you shortly.';
const FALLBACK_MESSAGES = new Set([NO_ANSWER_MESSAGE, TIMEOUT_MESSAGE]);

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const BASE_INPUT_CLASS = 'cra-input';
const TEXTAREA_CLASS = 'cra-input cra-textarea';

export default class CaseResolutionAssistant extends LightningElement {
    currentState = STATE.INPUT;

    firstName = '';
    lastName = '';
    email = '';
    question = '';
    product = '';

    firstNameError = '';
    lastNameError = '';
    emailError = '';
    questionError = '';

    productOptions = [];

    recommendation = '';
    recommendationIsFallback = false;
    caseId = null;
    caseNumber = '';
    errorMessage = '';

    pollAttempts = 0;
    pollTimeoutId = null;

    @wire(getProductOptions)
    wiredProducts({ data }) {
        if (data) {
            this.productOptions = data;
        }
    }

    connectedCallback() {
        this.applyHostChrome();
    }

    renderedCallback() {
        this.applyHostChrome();
    }

    applyHostChrome() {
        this.style.display = 'block';
        this.style.width = '100%';
        this.style.minHeight = '100vh';
        this.style.backgroundColor = '#2c5282';
        this.style.boxSizing = 'border-box';
    }

    handleFirstNameChange(event) {
        this.firstName = event.target.value;
        if (this.firstNameError) {
            this.firstNameError = this.validateFirstName();
        }
    }
    handleLastNameChange(event) {
        this.lastName = event.target.value;
        if (this.lastNameError) {
            this.lastNameError = this.validateLastName();
        }
    }
    handleEmailChange(event) {
        this.email = event.target.value;
        if (this.emailError) {
            this.emailError = this.validateEmail();
        }
    }
    handleQuestionChange(event) {
        this.question = event.target.value;
        if (this.questionError) {
            this.questionError = this.validateQuestion();
        }
    }
    handleProductChange(event) {
        this.product = event.target.value;
    }

    handleFirstNameBlur() {
        this.firstNameError = this.validateFirstName();
    }
    handleLastNameBlur() {
        this.lastNameError = this.validateLastName();
    }
    handleEmailBlur() {
        this.emailError = this.validateEmail();
    }
    handleQuestionBlur() {
        this.questionError = this.validateQuestion();
    }

    validateFirstName() {
        if (!(this.firstName || '').trim()) {
            return 'First name is required.';
        }
        return '';
    }
    validateLastName() {
        if (!(this.lastName || '').trim()) {
            return 'Last name is required.';
        }
        return '';
    }
    validateEmail() {
        const value = (this.email || '').trim();
        if (!value) {
            return 'Email is required.';
        }
        if (!EMAIL_REGEX.test(value)) {
            return 'Please enter a valid email address.';
        }
        return '';
    }
    validateQuestion() {
        if (!(this.question || '').trim()) {
            return 'Please describe what you need help with.';
        }
        return '';
    }

    validateAll() {
        this.firstNameError = this.validateFirstName();
        this.lastNameError = this.validateLastName();
        this.emailError = this.validateEmail();
        this.questionError = this.validateQuestion();
        return !(
            this.firstNameError ||
            this.lastNameError ||
            this.emailError ||
            this.questionError
        );
    }

    get firstNameInputClass() {
        return this.firstNameError
            ? `${BASE_INPUT_CLASS} cra-input--error`
            : BASE_INPUT_CLASS;
    }
    get lastNameInputClass() {
        return this.lastNameError
            ? `${BASE_INPUT_CLASS} cra-input--error`
            : BASE_INPUT_CLASS;
    }
    get emailInputClass() {
        return this.emailError
            ? `${BASE_INPUT_CLASS} cra-input--error`
            : BASE_INPUT_CLASS;
    }
    get questionInputClass() {
        return this.questionError
            ? `${TEXTAREA_CLASS} cra-input--error`
            : TEXTAREA_CLASS;
    }

    get inputClass() {
        return this.classFor(STATE.INPUT);
    }
    get loadingClass() {
        return this.classFor(STATE.LOADING);
    }
    get recommendationClass() {
        return this.classFor(STATE.RECOMMENDATION);
    }
    get recommendationBadge() {
        return this.recommendationIsFallback
            ? 'WE\'LL FOLLOW UP'
            : 'KNOWLEDGE ARTICLE FOUND';
    }
    get recommendationBadgeClass() {
        return this.recommendationIsFallback
            ? 'cra-badge cra-badge--neutral'
            : 'cra-badge';
    }
    get recommendationTitle() {
        return this.recommendationIsFallback ? 'Next Steps' : 'Recommended Solution';
    }
    get resolvingClass() {
        return this.classFor(STATE.RESOLVING);
    }
    get resolvedClass() {
        return this.classFor(STATE.RESOLVED);
    }
    get caseCreatedClass() {
        return this.classFor(STATE.CASE_CREATED);
    }

    classFor(targetState) {
        return this.currentState === targetState
            ? 'cra-state'
            : 'cra-state cra-state--hidden';
    }

    get errorClass() {
        return this.errorMessage
            ? 'cra-error'
            : 'cra-error cra-error--hidden';
    }

    async handleFindSolution() {
        const isValid = this.validateAll();
        if (!isValid) {
            this.errorMessage = 'Please correct the highlighted fields before submitting.';
            return;
        }
        this.errorMessage = '';
        this.currentState = STATE.LOADING;

        try {
            const result = await createSupportCase({
                firstName: this.firstName,
                lastName: this.lastName,
                email: this.email,
                subject: this.question,
                product: this.product
            });
            this.caseId = result.caseId;
            this.caseNumber = result.caseNumber;
            this.pollAttempts = 0;
            this.scheduleNextPoll();
        } catch (error) {
            this.errorMessage =
                (error && error.body && error.body.message) ||
                'Sorry, something went wrong submitting your question. Please try again.';
            this.currentState = STATE.INPUT;
        }
    }

    scheduleNextPoll() {
        this.pollTimeoutId = setTimeout(() => this.pollOnce(), POLL_INTERVAL_MS);
    }

    async pollOnce() {
        this.pollAttempts += 1;
        try {
            const description = await getRecommendation({ caseId: this.caseId });
            if (description) {
                this.recommendation = description;
                this.recommendationIsFallback = FALLBACK_MESSAGES.has(description);
                this.currentState = STATE.RECOMMENDATION;
                return;
            }
        } catch (e) {
            // Silently swallow transient errors and keep polling.
        }

        if (this.pollAttempts >= MAX_POLL_ATTEMPTS) {
            this.recommendation = TIMEOUT_MESSAGE;
            this.recommendationIsFallback = true;
            this.currentState = STATE.RECOMMENDATION;
            return;
        }
        this.scheduleNextPoll();
    }

    async handleYes() {
        this.currentState = STATE.RESOLVING;
        try {
            await resolveCase({ caseId: this.caseId });
            this.currentState = STATE.RESOLVED;
        } catch (error) {
            this.errorMessage =
                (error && error.body && error.body.message) ||
                'Sorry, we could not close the case. Please try again.';
            this.currentState = STATE.RECOMMENDATION;
        }
    }

    handleNo() {
        this.currentState = STATE.CASE_CREATED;
    }

    handleReset() {
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.question = '';
        this.product = '';
        this.firstNameError = '';
        this.lastNameError = '';
        this.emailError = '';
        this.questionError = '';
        this.recommendation = '';
        this.recommendationIsFallback = false;
        this.caseId = null;
        this.caseNumber = '';
        this.errorMessage = '';
        this.pollAttempts = 0;
        if (this.pollTimeoutId) {
            clearTimeout(this.pollTimeoutId);
            this.pollTimeoutId = null;
        }
        this.currentState = STATE.INPUT;
    }

    disconnectedCallback() {
        if (this.pollTimeoutId) {
            clearTimeout(this.pollTimeoutId);
            this.pollTimeoutId = null;
        }
    }
}
