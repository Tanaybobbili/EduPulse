import { LightningElement } from 'lwc';

import getStudents from
    '@salesforce/apex/StudentManagementController.getStudents';

import { NavigationMixin } from 'lightning/navigation';

const columns = [
    {
        label: 'Student Number',
        fieldName: 'studentUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_self'
        }
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
        fieldName: 'Department__c'
    },
    {
        label: 'Course',
        fieldName: 'Course__c'
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
        label: 'Performance',
        fieldName: 'performanceDisplay'
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

export default class StudentManagement extends NavigationMixin(LightningElement) {

    students = [];

    searchText = '';
    department = '';
    riskCategory = '';

    isLoading = false;
    error;

    columns = columns;

    departmentOptions = [
        { label: 'All Departments', value: '' },
        { label: 'Computer Science', value: 'Computer Science' },
        { label: 'Information Technology', value: 'Information Technology' },
        { label: 'Electronics and Communication', value: 'Electronics and Communication' },
        { label: 'Electrical and Electronics', value: 'Electrical and Electronics' },
        { label: 'Mechanical', value: 'Mechanical' },
        { label: 'Civil', value: 'Civil' },
        { label: 'Other', value: 'Other' }
    ];

    riskOptions = [
        { label: 'All Risk Categories', value: '' },
        { label: 'Low', value: 'Low' },
        { label: 'Medium', value: 'Medium' },
        { label: 'High', value: 'High' },
        { label: 'Critical', value: 'Critical' }
    ];

    connectedCallback() {
        this.loadStudents();
    }

    get studentCount() {
        return this.students.length;
    }

    get hasStudents() {
        return !this.isLoading && this.students.length > 0;
    }

    get showEmpty() {
        return !this.isLoading &&
            !this.error &&
            this.students.length === 0;
    }

    handleSearch(event) {
        this.searchText = event.target.value;
        this.loadStudents();
    }

    handleDepartmentChange(event) {
        this.department = event.detail.value;
        this.loadStudents();
    }

    handleRiskChange(event) {
        this.riskCategory = event.detail.value;
        this.loadStudents();
    }

    resetFilters() {
        this.searchText = '';
        this.department = '';
        this.riskCategory = '';
        this.loadStudents();
    }

    async loadStudents() {

        this.isLoading = true;
        this.error = undefined;

        try {

            const result = await getStudents({
                searchText: this.searchText,
                department: this.department,
                riskCategory: this.riskCategory
            });

            this.students = result.map(student => ({

                ...student,

                studentUrl: '/lightning/r/Student__c/' +
                    student.Id + '/view',

                studentName:
                    student.First_Name__c + ' ' +
                    student.Last_Name__c,

                attendanceDisplay:
                    (student.Attendance_Percentage__c ?? 0).toFixed(2) + '%',

                performanceDisplay:
                    (student.Performance_Score__c ?? 0).toFixed(2) + '%'

            }));

        } catch (error) {

            this.error = error;
            this.students = [];

            console.error('Student Management error:', error);

        } finally {

            this.isLoading = false;

        }
    }
}