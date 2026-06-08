import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import saveResolution from '@salesforce/apex/CaseResolveActionController.saveResolution';

export default class CaseResolveAction extends LightningElement {
    @api recordId;

    resolutionText = '';
    errorMessage = '';
    isSaving = false;
    updateKnowledgeBase = false;

    renderedCallback() {
        this.adjustTextareaHeight();
    }

    handleResolutionChange(event) {
        this.resolutionText = event.target.value;
        if (this.errorMessage) {
            this.errorMessage = '';
        }
        this.adjustTextareaHeight();
    }

    handleUpdateKbChange(event) {
        this.updateKnowledgeBase = event.target.checked;
    }

    adjustTextareaHeight() {
        const textarea = this.template.querySelector(
            '[data-id="resolution-textarea"]'
        );
        if (!textarea) {
            return;
        }

        textarea.style.height = 'auto';
        const maxHeightPx = 256;
        const nextHeight = Math.min(textarea.scrollHeight, maxHeightPx);
        textarea.style.height = `${nextHeight}px`;
        textarea.style.overflowY =
            textarea.scrollHeight > maxHeightPx ? 'auto' : 'hidden';
    }

    handleCancel() {
        this.closeModal();
    }

    async handleSave() {
        const trimmed = (this.resolutionText || '').trim();
        if (!trimmed) {
            this.errorMessage = 'Please enter a resolution before saving.';
            return;
        }

        this.errorMessage = '';
        this.isSaving = true;

        try {
            const result = await saveResolution({
                caseId: this.recordId,
                resolutionText: trimmed,
                createKb: this.updateKnowledgeBase
            });

            const articleMessage = this.updateKnowledgeBase ? this.buildArticleMessage(result) : '';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Case resolved',
                    message: 'Resolution saved and case closed.' + articleMessage,
                    variant: 'success'
                })
            );

            getRecordNotifyChange([{ recordId: this.recordId }]);
            this.closeModal();
        } catch (error) {
            this.isSaving = false;
            this.errorMessage =
                (error && error.body && error.body.message) ||
                'Sorry, we could not save the resolution. Please try again.';
        }
    }

    buildArticleMessage(result) {
        if (result && result.articleQueued === true) {
            return ' KB articles are being generated in the background.';
        }
        return '';
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new CustomEvent('close'));
    }
}
