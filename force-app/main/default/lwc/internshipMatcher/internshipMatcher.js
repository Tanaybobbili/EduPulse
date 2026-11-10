
import { LightningElement, wire } from 'lwc';
import getStudents from '@salesforce/apex/InternshipMatchingController.getStudents';
import getOpportunities from '@salesforce/apex/InternshipMatchingController.getOpportunities';
import calculateMatch from '@salesforce/apex/InternshipMatchingController.calculateMatch';

export default class InternshipMatcher extends LightningElement {

    studentOptions = [];
    opportunityOptions = [];

    selectedStudentId = '';
    selectedOpportunityId = '';

    matchResult;
    errorMessage = '';
    isLoading = false;

    // Load active students.
    @wire(getStudents)
    wiredStudents({ data, error }) {

        if (data) {
            this.studentOptions = data.map(student => ({
                label: `${student.First_Name__c} ${student.Last_Name__c} (${student.Name})`,
                value: student.Id
            }));
        } else if (error) {
            this.showError(error);
        }
    }

    // Load active career opportunities.
    @wire(getOpportunities)
    wiredOpportunities({ data, error }) {

        if (data) {
            this.opportunityOptions = data.map(opportunity => ({
                label: `${opportunity.Opportunity_Title__c} - ${opportunity.Company__c}`,
                value: opportunity.Id
            }));
        } else if (error) {
            this.showError(error);
        }
    }

    // Handle student selection.
    handleStudentChange(event) {
        this.selectedStudentId = event.detail.value;
        this.matchResult = null;
        this.errorMessage = '';
    }

    // Handle opportunity selection.
    handleOpportunityChange(event) {
        this.selectedOpportunityId = event.detail.value;
        this.matchResult = null;
        this.errorMessage = '';
    }

    // Enable button only when both selections are available.
    get isCalculateDisabled() {
        return !this.selectedStudentId ||
            !this.selectedOpportunityId ||
            this.isLoading;
    }

    // Calculate the internship match.
    async handleCalculate() {

        this.isLoading = true;
        this.errorMessage = '';
        this.matchResult = null;

        try {

            this.matchResult = await calculateMatch({
                studentId: this.selectedStudentId,
                opportunityId: this.selectedOpportunityId
            });

        } catch (error) {
            this.showError(error);
        } finally {
            this.isLoading = false;
        }
    }

    // Extract a readable error message.
    showError(error) {

        if (error?.body?.message) {
            this.errorMessage = error.body.message;
        } else {
            this.errorMessage = 'Something went wrong while processing the request.';
        }
    }
}
