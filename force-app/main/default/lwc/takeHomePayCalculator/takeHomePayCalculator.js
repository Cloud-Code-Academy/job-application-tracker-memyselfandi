import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

// Define the Salary field to retrieve from Job Application object
const SALARY_FIELD = 'Job_Application__c.Salary__c'; // Adjust field API name if needed

export default class TakeHomePayCalculator extends LightningElement {
    @api recordId; // Id of the Job Application record
    salary; // Stores the base salary value
    calculated = false; // Flag to control when to show calculated results

    // Variables to hold calculation results
    federalTax = 0;
    medicare = 0;
    socialSecurity = 0;
    netPayYearly = 0;
    netPaySixMonths = 0;
    netPayMonthly = 0;
    netPayBiWeekly = 0;

    // Wire adapter to fetch the Salary field from the Job Application record
    @wire(getRecord, { recordId: '$recordId', fields: [SALARY_FIELD] })
    jobApplicationRecord({ error, data }) {
        if (data) {
            this.salary = data.fields.Salary__c.value; // Set salary if record is successfully fetched
        } else if (error) {
            console.error('Error loading Job Application record', error); // Log error if fetch fails
        }
    }

    // Handler for when the user edits the salary input
    handleSalaryChange(event) {
        this.salary = event.target.value; // Update salary from input value
    }

    // Main method to calculate take-home pay and taxes
    calculateTakeHomePay() {
        const salary = parseFloat(this.salary) || 0; // Parse salary as float

        // Calculate deductions
        this.federalTax = salary * 0.22;
        this.medicare = salary * 0.0145;
        this.socialSecurity = salary * 0.062;

        const totalTax = this.federalTax + this.medicare + this.socialSecurity; // Sum of all taxes

        // Calculate net pay across different intervals
        this.netPayYearly = salary - totalTax;
        this.netPaySixMonths = this.netPayYearly / 2;
        this.netPayMonthly = this.netPayYearly / 12;
        this.netPayBiWeekly = this.netPayYearly / 26;

        this.calculated = true; // Enable display of calculation results
    }

    // 🎯 Helper function to format numbers as currency ($12,345.67)
    formatCurrency(value) {
        if (isNaN(value)) return ''; // Handle invalid inputs gracefully
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 2
        }).format(value);
    }

    // 🎯 Getter methods to return formatted currency values for display

    get formattedFederalTax() {
        return this.formatCurrency(this.federalTax);
    }

    get formattedMedicare() {
        return this.formatCurrency(this.medicare);
    }

    get formattedSocialSecurity() {
        return this.formatCurrency(this.socialSecurity);
    }

    get formattedNetPayYearly() {
        return this.formatCurrency(this.netPayYearly);
    }

    get formattedNetPaySixMonths() {
        return this.formatCurrency(this.netPaySixMonths);
    }

    get formattedNetPayMonthly() {
        return this.formatCurrency(this.netPayMonthly);
    }

    get formattedNetPayBiWeekly() {
        return this.formatCurrency(this.netPayBiWeekly);
    }
}
