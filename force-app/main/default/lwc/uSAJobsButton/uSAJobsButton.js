// Import necessary modules
import { LightningElement, api } from 'lwc';
// Import Apex method from the Apex class
import runCustomLogic from '@salesforce/apex/JobApplicationActionController.runCustomLogic';
// Import Lightning Toast for user feedback
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class JobApplicationActionButton extends LightningElement {
    // Expose recordId to the component from the record page
    @api recordId;

    // Called when the button is clicked
    handleClick() {
        // Call Apex method with the current record's ID
        runCustomLogic({ recordId: this.recordId })
            .then(() => {
                // Show a success toast if the callout succeeds
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Custom logic executed successfully.',
                    variant: 'success'
                }));
            })
            .catch(error => {
                // Show an error toast if something goes wrong
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }));
            });
    }
}
