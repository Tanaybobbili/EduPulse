import { LightningElement, wire } from 'lwc';

import getRiskAnalytics from
    '@salesforce/apex/RiskAnalyticsController.getRiskAnalytics';

const columns = [
    {
        label: 'Student Number',
        fieldName: 'Name',
        type: 'text'
    },
    {
        label: 'Student Name',
        fieldName: 'studentName',
        type: 'text'
    },
    {
        label: 'Department',
        fieldName: 'Department__c'
    },
    {
        label: 'CGPA',
        fieldName: 'CGPA__c',
        type: 'number'
    },
    {
        label: 'Attendance',
        fieldName: 'attendanceDisplay'
    },
    {
        label: 'Risk Score',
        fieldName: 'Risk_Score__c',
        type: 'number'
    },
    {
        label: 'Risk Category',
        fieldName: 'Risk_Category__c'
    }
];

export default class RiskAnalytics extends LightningElement {

    analytics;
    students = [];
    error;
    isLoading = true;

    columns = columns;

    get lowPercentage() {
        return this.getPercentage(this.analytics?.lowRisk);
    }

    get mediumPercentage() {
        return this.getPercentage(this.analytics?.mediumRisk);
    }

    get highPercentage() {
        return this.getPercentage(this.analytics?.highRisk);
    }

    get criticalPercentage() {
        return this.getPercentage(this.analytics?.criticalRisk);
    }

    getPercentage(count) {

        if (!this.analytics || !this.analytics.totalStudents) {
            return '0.00';
        }

        return (
            (count / this.analytics.totalStudents) * 100
        ).toFixed(2);
    }

    get riskBars() {

        if (!this.analytics) {
            return [];
        }

        const total = this.analytics.totalStudents;

        const categories = [
            {
                label: 'Low',
                count: this.analytics.lowRisk
            },
            {
                label: 'Medium',
                count: this.analytics.mediumRisk
            },
            {
                label: 'High',
                count: this.analytics.highRisk
            },
            {
                label: 'Critical',
                count: this.analytics.criticalRisk
            }
        ];

        return categories.map(item => ({
            ...item,
            percentage: total > 0
                ? (item.count / total) * 100
                : 0
        }));
    }

    @wire(getRiskAnalytics)
    wiredAnalytics({ data, error }) {

        if (data) {

            this.analytics = data;

            this.students = data.highRiskStudents.map(student => ({
                ...student,
                studentName:
                    student.First_Name__c + ' ' +
                    student.Last_Name__c,
                attendanceDisplay:
                    (student.Attendance_Percentage__c ?? 0).toFixed(2) + '%'
            }));

            this.error = undefined;
            this.isLoading = false;

        } else if (error) {

            this.analytics = undefined;
            this.students = [];
            this.error = error;
            this.isLoading = false;

            console.error('Risk Analytics error:', error);
        }
    }
}