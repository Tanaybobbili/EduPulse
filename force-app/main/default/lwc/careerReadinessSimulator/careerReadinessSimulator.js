import { LightningElement, wire } from 'lwc';

import getStudents
    from '@salesforce/apex/CareerReadinessController.getStudents';

import getStudentSnapshot
    from '@salesforce/apex/CareerReadinessController.getStudentSnapshot';

import calculateProjectedRisk
    from '@salesforce/apex/CareerReadinessController.calculateProjectedRisk';

export default class CareerReadinessSimulator extends LightningElement {

    studentOptions = [];
    selectedStudentId = '';
    studentData;

    projectedCGPA = 0;
    projectedAttendance = 0;
    projectedAssessment = 0;
    projectedSkill = 0;

    projectedRisk;
    careerReadiness;
    projectedRiskCategory;

    isLoading = false;
    errorMessage = '';

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

    // Load the selected student's current metrics.
    async handleStudentChange(event) {

        this.selectedStudentId = event.detail.value;
        this.studentData = null;
        this.clearProjection();
        this.errorMessage = '';
        this.isLoading = true;

        try {

            const data = await getStudentSnapshot({
                studentId: this.selectedStudentId
            });

            this.studentData = data;

            this.projectedCGPA = data.cgpa ?? 0;
            this.projectedAttendance = data.attendance ?? 0;
            this.projectedAssessment = data.assessmentScore ?? 0;
            this.projectedSkill = data.skillProficiency ?? 0;

        } catch (error) {
            this.showError(error);
        } finally {
            this.isLoading = false;
        }
    }

    // Handle CGPA slider.
    handleCGPAChange(event) {
        this.projectedCGPA = event.detail.value;
        this.clearProjection();
    }

    // Handle attendance slider.
    handleAttendanceChange(event) {
        this.projectedAttendance = event.detail.value;
        this.clearProjection();
    }

    // Handle assessment slider.
    handleAssessmentChange(event) {
        this.projectedAssessment = event.detail.value;
        this.clearProjection();
    }

    // Handle skill proficiency slider.
    handleSkillChange(event) {
        this.projectedSkill = event.detail.value;
        this.clearProjection();
    }

    // Calculate hypothetical risk and readiness.
    async handleSimulation() {

        if (!this.studentData) {
            this.errorMessage = 'Please select a student first.';
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';
        this.clearProjection();

        try {

            const risk = await calculateProjectedRisk({
                attendance: this.projectedAttendance,
                cgpa: this.projectedCGPA,
                assessmentScore: this.projectedAssessment,
                skillProficiency: this.projectedSkill
            });

            this.projectedRisk = risk;
            this.careerReadiness = Number((100 - risk).toFixed(2));

            if (risk <= 30) {
                this.projectedRiskCategory = 'Low';
            } else if (risk <= 60) {
                this.projectedRiskCategory = 'Medium';
            } else if (risk <= 80) {
                this.projectedRiskCategory = 'High';
            } else {
                this.projectedRiskCategory = 'Critical';
            }

        } catch (error) {
            this.showError(error);
        } finally {
            this.isLoading = false;
        }
    }

    // Restore the student's original values.
    handleReset() {

        if (!this.studentData) {
            return;
        }

        this.projectedCGPA = this.studentData.cgpa ?? 0;
        this.projectedAttendance = this.studentData.attendance ?? 0;
        this.projectedAssessment = this.studentData.assessmentScore ?? 0;
        this.projectedSkill = this.studentData.skillProficiency ?? 0;

        this.clearProjection();
        this.errorMessage = '';
    }

    // Clear previous calculated results.
    clearProjection() {
        this.projectedRisk = null;
        this.careerReadiness = null;
        this.projectedRiskCategory = '';
    }

    // Check whether projection results exist.
    get hasProjection() {
        return this.projectedRisk !== null &&
            this.projectedRisk !== undefined;
    }

    // Display readable error messages.
    showError(error) {

        if (error?.body?.message) {
            this.errorMessage = error.body.message;
        } else {
            this.errorMessage =
                'Unable to process the career readiness simulation.';
        }
    }
}