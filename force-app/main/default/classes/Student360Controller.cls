public with sharing class Student360Controller {

    // Wrapper containing all information for one student.
    public class Student360Data {

        @AuraEnabled
        public Student__c student { get; set; }

        @AuraEnabled
        public List<Academic_Record__c> academicRecords { get; set; }

        @AuraEnabled
        public List<Attendance_Record__c> attendanceRecords { get; set; }

        @AuraEnabled
        public List<Assessment__c> assessments { get; set; }

        @AuraEnabled
        public List<Student_Skill__c> skills { get; set; }

        @AuraEnabled
        public List<Intervention__c> interventions { get; set; }

        @AuraEnabled
        public List<Application__c> applications { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static Student360Data getStudentDetails(Id studentId) {

        if (studentId == null) {
            return null;
        }

        Student360Data data = new Student360Data();

        // Fetch the student profile.
        data.student = [
            SELECT Id,
                   Name,
                   First_Name__c,
                   Last_Name__c,
                   Email__c,
                   Phone__c,
                   Department__c,
                   Course__c,
                   Current_Semester__c,
                   CGPA__c,
                   Attendance_Percentage__c,
                   Performance_Score__c,
                   Risk_Score__c,
                   Risk_Category__c,
                   Career_Interest__c,
                   Is_Active__c
            FROM Student__c
            WHERE Id = :studentId
            LIMIT 1
        ];

        // Fetch academic history.
        data.academicRecords = [
            SELECT Id, Academic_Year__c, Semester__c,
                   SGPA__c, Credits_Earned__c, Result_Status__c
            FROM Academic_Record__c
            WHERE Student__c = :studentId
            ORDER BY Semester__c DESC
            LIMIT 10
        ];

        // Fetch attendance history.
        data.attendanceRecords = [
            SELECT Id, Month__c, Total_Classes__c,
                   Classes_Attended__c, Attendance_Percentage__c
            FROM Attendance_Record__c
            WHERE Student__c = :studentId
            ORDER BY Month__c DESC
            LIMIT 10
        ];

        // Fetch assessment history.
        data.assessments = [
            SELECT Id, Assessment_Name__c, Subject__c,
                   Assessment_Date__c, Maximum_Marks__c,
                   Marks_Obtained__c, Score_Percentage__c
            FROM Assessment__c
            WHERE Student__c = :studentId
            ORDER BY Assessment_Date__c DESC
            LIMIT 10
        ];

        // Fetch student skills.
        data.skills = [
            SELECT Id, Skill__c, Skill__r.Name,
                   Proficiency_Level__c, Experience_Years__c,
                   Is_Verified__c
            FROM Student_Skill__c
            WHERE Student__c = :studentId
            LIMIT 50
        ];

        // Fetch interventions.
        data.interventions = [
            SELECT Id, Risk_Category__c, Intervention_Type__c,
                   Status__c, Intervention_Date__c,
                   Due_Date__c, Description__c
            FROM Intervention__c
            WHERE Student__c = :studentId
            ORDER BY Intervention_Date__c DESC
            LIMIT 10
        ];

        // Fetch career applications.
        data.applications = [
            SELECT Id, Career_Opportunity__r.Opportunity_Title__c,
                   Application_Date__c, Status__c,
                   Interview_Date__c, Remarks__c
            FROM Application__c
            WHERE Student__c = :studentId
            ORDER BY Application_Date__c DESC
            LIMIT 10
        ];

        return data;
    }
}