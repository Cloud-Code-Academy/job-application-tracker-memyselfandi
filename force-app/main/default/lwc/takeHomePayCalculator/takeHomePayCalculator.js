import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

// Field API name to fetch Salary from Job Application object
const SALARY_FIELD = 'Job_Application__c.Salary__c'; // Update if necessary

export default class TakeHomePayCalculator extends LightningElement {
    @api recordId; // Current record Id from the page
    salary;        // Salary value
    calculated = false; // Flag to display calculation results

    // Variables to hold output values
    federalTax = 0;
    medicare = 0;
    socialSecurity = 0;
    netPayYearly = 0;
    netPaySixMonths = 0;
    netPayMonthly = 0;
    netPayBiWeekly = 0;

    // Wire adapter to fetch the Salary from the Job Application record
    @wire(getRecord, { recordId: '$recordId', fields: [SALARY_FIELD] })
    jobApplicationRecord({ error, data }) {
        if (data) {
            this.salary = data.fields.Salary__c.value; // Set the salary from record
        } else if (error) {
            console.error('Error loading Job Application record', error); // Handle errors
        }
    }

    // Event handler for salary input change
    handleSalaryChange(event) {
        this.salary = event.target.value; // Update salary as user types
    }

    // Main calculation logic triggered when button is clicked
    calculateTakeHomePay() {
        const salary = parseFloat(this.salary) || 0; // Parse salary or default to 0

        // Example tax assumptions
        this.federalTax = salary * 0.22;        // Assume 22% Federal Tax
        this.medicare = salary * 0.0145;         // 1.45% Medicare Tax
        this.socialSecurity = salary * 0.062;    // 6.2% Social Security Tax

        // Total tax deductions
        const totalTax = this.federalTax + this.medicare + this.socialSecurity;

        // Calculate net pay after deductions
        this.netPayYearly = salary - totalTax;
        this.netPaySixMonths = this.netPayYearly / 2;
        this.netPayMonthly = this.netPayYearly / 12;
        this.netPayBiWeekly = this.netPayYearly / 26;

        this.calculated = true; // Show the calculated results
    }
}
