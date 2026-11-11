import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import getStudents from '@salesforce/apex/MentorAllocationController.getStudents';
import getAvailableMentors from '@salesforce/apex/MentorAllocationController.getAvailableMentors';
import assignMentor from '@salesforce/apex/MentorAllocationController.assignMentor';

export default class MentorAllocation extends LightningElement {
    students = [];
    mentors = [];

    selectedStudentId = '';
    isLoading = true;

    successMessage = '';
    errorMessage = '';

    wiredMentorsResult;

    @wire(getStudents)
    wiredStudents({ data, error }) {
        if (data) {
            this.students = data;
        } else if (error) {
            this.errorMessage = this.getErrorMessage(error);
        }
    }

    @wire(getAvailableMentors)
    wiredMentors(result) {
        this.wiredMentorsResult = result;

        if (result.data) {
            this.mentors = result.data;
            this.isLoading = false;
        } else if (result.error) {
            this.errorMessage = this.getErrorMessage(result.error);
            this.isLoading = false;
        }
    }

    get studentOptions() {
        return this.students.map(student => ({
            label: `${student.First_Name__c} ${student.Last_Name__c} (${student.Name})`,
            value: student.Id
        }));
    }

    get hasMentors() {
        return this.mentors.length > 0;
    }

    handleStudentChange(event) {
        this.selectedStudentId = event.detail.value;
        this.successMessage = '';
        this.errorMessage = '';
    }

    async handleAssign(event) {
        if (!this.selectedStudentId) {
            this.errorMessage = 'Please select a student before assigning a mentor.';
            this.successMessage = '';
            return;
        }

        const mentorId = event.currentTarget.dataset.id;

        this.isLoading = true;
        this.successMessage = '';
        this.errorMessage = '';

        try {
            const result = await assignMentor({
                studentId: this.selectedStudentId,
                mentorId: mentorId
            });

            this.successMessage =
                `Mentor assigned successfully. Mentorship record ${result.Name} has been created.`;

            await refreshApex(this.wiredMentorsResult);

        } catch (error) {
            this.errorMessage = this.getErrorMessage(error);
        } finally {
            this.isLoading = false;
        }
    }

    async loadMentors() {
        this.isLoading = true;
        this.successMessage = '';
        this.errorMessage = '';

        try {
            await refreshApex(this.wiredMentorsResult);
        } catch (error) {
            this.errorMessage = this.getErrorMessage(error);
        } finally {
            this.isLoading = false;
        }
    }

    getErrorMessage(error) {
        return error?.body?.message || error?.message || 'An unexpected error occurred.';
    }
}