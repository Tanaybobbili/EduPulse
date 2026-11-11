import { LightningElement, api, wire } from 'lwc';
import getStudentDetails from
    '@salesforce/apex/Student360Controller.getStudentDetails';

const academicColumns = [
    { label: 'Academic Year', fieldName: 'Academic_Year__c' },
    { label: 'Semester', fieldName: 'Semester__c', type: 'number' },
    { label: 'SGPA', fieldName: 'SGPA__c', type: 'number' },
    { label: 'Credits', fieldName: 'Credits_Earned__c', type: 'number' },
    { label: 'Result', fieldName: 'Result_Status__c' }
];

const attendanceColumns = [
    { label: 'Month', fieldName: 'Month__c', type: 'date' },
    { label: 'Total Classes', fieldName: 'Total_Classes__c', type: 'number' },
    { label: 'Attended', fieldName: 'Classes_Attended__c', type: 'number' },
    { label: 'Attendance', fieldName: 'attendanceDisplay' }
];

const assessmentColumns = [
    { label: 'Assessment', fieldName: 'Assessment_Name__c' },
    { label: 'Subject', fieldName: 'Subject__c' },
    { label: 'Date', fieldName: 'Assessment_Date__c', type: 'date' },
    { label: 'Marks Obtained', fieldName: 'Marks_Obtained__c', type: 'number' },
    { label: 'Maximum Marks', fieldName: 'Maximum_Marks__c', type: 'number' },
    { label: 'Score', fieldName: 'scoreDisplay' }
];

const skillColumns = [
    { label: 'Skill', fieldName: 'skillName' },
    { label: 'Proficiency', fieldName: 'Proficiency_Level__c' },
    { label: 'Experience (Years)', fieldName: 'Experience_Years__c', type: 'number' },
    { label: 'Verified', fieldName: 'Is_Verified__c', type: 'boolean' }
];

const interventionColumns = [
    { label: 'Type', fieldName: 'Intervention_Type__c' },
    { label: 'Risk', fieldName: 'Risk_Category__c' },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Date', fieldName: 'Intervention_Date__c', type: 'date' },
    { label: 'Due Date', fieldName: 'Due_Date__c', type: 'date' }
];

const applicationColumns = [
    { label: 'Opportunity', fieldName: 'opportunityTitle' },
    { label: 'Applied On', fieldName: 'Application_Date__c', type: 'date' },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Interview Date', fieldName: 'Interview_Date__c', type: 'date' }
];

export default class Student360 extends LightningElement {

    @api recordId;

    student;
    academicRecords = [];
    attendanceRecords = [];
    assessments = [];
    skills = [];
    interventions = [];
    applications = [];

    error;
    isLoading = true;

    academicColumns = academicColumns;
    attendanceColumns = attendanceColumns;
    assessmentColumns = assessmentColumns;
    skillColumns = skillColumns;
    interventionColumns = interventionColumns;
    applicationColumns = applicationColumns;

    attendanceDisplay = '0.00';
    performanceDisplay = '0.00';

    @wire(getStudentDetails, { studentId: '$recordId' })
    wiredStudent({ data, error }) {

        if (data) {

            this.student = data.student;

            this.attendanceDisplay =
                (data.student.Attendance_Percentage__c ?? 0).toFixed(2);

            this.performanceDisplay =
                (data.student.Performance_Score__c ?? 0).toFixed(2);

            this.academicRecords = data.academicRecords;
            
            this.attendanceRecords = data.attendanceRecords.map(item => ({
                ...item,
                attendanceDisplay:
                    (item.Attendance_Percentage__c ?? 0).toFixed(2) + '%'
            }));

            this.assessments = data.assessments.map(item => ({
                ...item,
                scoreDisplay:
                    (item.Score_Percentage__c ?? 0).toFixed(2) + '%'
            }));

            this.skills = data.skills.map(item => ({
                ...item,
                skillName: item.Skill__r?.Name ?? 'Not specified'
            }));

            this.interventions = data.interventions;

            this.applications = data.applications.map(item => ({
                ...item,
                opportunityTitle:
                    item.Career_Opportunity__r?.Opportunity_Title__c
                    ?? 'Not specified'
            }));

            this.error = undefined;
            this.isLoading = false;

        } else if (error) {

            this.student = undefined;
            this.error = error;
            this.isLoading = false;

            console.error('Student 360 error:', error);
        }
    }
}