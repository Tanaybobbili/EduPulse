
public with sharing class StudentDashboardController {

    // Data returned to the LWC dashboard.
    public class DashboardData {

        @AuraEnabled
        public Integer totalStudents { get; set; }

        @AuraEnabled
        public Decimal averageCGPA { get; set; }

        @AuraEnabled
        public Decimal averageAttendance { get; set; }

        @AuraEnabled
        public Integer highRiskStudents { get; set; }

        @AuraEnabled
        public List<Student__c> students { get; set; }
    }

    // Fetch dashboard statistics and student records.
    @AuraEnabled(cacheable=true)
    public static DashboardData getDashboardData() {

        DashboardData data = new DashboardData();

        // Calculate overall student statistics.
        AggregateResult stats = [
            SELECT COUNT(Id) total,
                   AVG(CGPA__c) avgCGPA,
                   AVG(Attendance_Percentage__c) avgAttendance
            FROM Student__c
            WHERE Is_Active__c = true
        ];

        data.totalStudents = (Integer) stats.get('total');
        data.averageCGPA = (Decimal) stats.get('avgCGPA');
        data.averageAttendance =
            (Decimal) stats.get('avgAttendance');

        // Count students in High or Critical risk categories.
        data.highRiskStudents = [
            SELECT COUNT()
            FROM Student__c
            WHERE Is_Active__c = true
            AND Risk_Category__c IN ('High', 'Critical')
        ];

        // Fetch the latest student information.
        data.students = [
            SELECT Id,
                   Name,
                   First_Name__c,
                   Last_Name__c,
                   Email__c,
                   Department__c,
                   CGPA__c,
                   Attendance_Percentage__c,
                   Risk_Score__c,
                   Risk_Category__c
            FROM Student__c
            WHERE Is_Active__c = true
            ORDER BY Risk_Score__c DESC NULLS LAST
            LIMIT 50
        ];

        return data;
    }
}
