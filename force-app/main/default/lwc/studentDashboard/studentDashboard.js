
import { LightningElement, wire } from 'lwc';
import getDashboardData from
    '@salesforce/apex/StudentDashboardController.getDashboardData';

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
        label: 'Email',
        fieldName: 'Email__c',
        type: 'email'
    },
    {
        label: 'Department',
        fieldName: 'Department__c',
        type: 'text'
    },
    {
        label: 'CGPA',
        fieldName: 'CGPA__c',
        type: 'number',
        typeAttributes: {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }
    },
    {
        label: 'Attendance',
        fieldName: 'attendanceDisplay',
        type: 'text'
    },
    {
        label: 'Risk Score',
        fieldName: 'Risk_Score__c',
        type: 'number'
    },
    {
        label: 'Risk Category',
        fieldName: 'Risk_Category__c',
        type: 'text'
    }
];

export default class StudentDashboard extends LightningElement {

    columns = columns;

    totalStudents = 0;
    averageCGPA = 0;
    averageAttendance = 0;
    highRiskStudents = 0;
    students = [];

    @wire(getDashboardData)
    wiredDashboard({ data, error }) {

        if (data) {

            this.totalStudents = data.totalStudents;

            this.averageCGPA =
                data.averageCGPA?.toFixed(2) ?? '0.00';

            this.averageAttendance =
                data.averageAttendance?.toFixed(2) ?? '0.00';

            this.highRiskStudents = data.highRiskStudents;

            this.students = data.students.map(student => ({
                ...student,
                studentName:
                    student.First_Name__c + ' ' +
                    student.Last_Name__c,
                attendanceDisplay:
                    (student.Attendance_Percentage__c ?? 0).toFixed(2) + '%'
            }));

        } else if (error) {

            console.error(
                'Error loading EduPulse dashboard:',
                error
            );

        }
    }
}
