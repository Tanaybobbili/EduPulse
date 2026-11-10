
public with sharing class StudentManagementController {

    @AuraEnabled(cacheable=true)
    public static List<Student__c> getStudents(
        String searchText,
        String department,
        String riskCategory
    ) {

        String query =
            'SELECT Id, Name, First_Name__c, Last_Name__c, ' +
            'Email__c, Phone__c, Department__c, Course__c, ' +
            'Current_Semester__c, CGPA__c, ' +
            'Attendance_Percentage__c, Performance_Score__c, ' +
            'Risk_Score__c, Risk_Category__c ' +
            'FROM Student__c ' +
            'WHERE Is_Active__c = true';

        // Search by student number, name or email.
        if (!String.isBlank(searchText)) {

            String searchValue =
                '%' + String.escapeSingleQuotes(searchText.trim()) + '%';

            query +=
                ' AND (First_Name__c LIKE \'' + searchValue + '\'' +
                ' OR Last_Name__c LIKE \'' + searchValue + '\'' +
                ' OR Name LIKE \'' + searchValue + '\'' +
                ' OR Email__c LIKE \'' + searchValue + '\')';
        }

        // Filter by department.
        if (!String.isBlank(department)) {

            query +=
                ' AND Department__c = \'' +
                String.escapeSingleQuotes(department) + '\'';
        }

        // Filter by risk category.
        if (!String.isBlank(riskCategory)) {

            query +=
                ' AND Risk_Category__c = \'' +
                String.escapeSingleQuotes(riskCategory) + '\'';
        }

        query += ' ORDER BY CreatedDate DESC LIMIT 200';

        return Database.query(query);
    }
}
