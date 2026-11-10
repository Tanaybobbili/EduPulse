
public with sharing class RiskAnalyticsController {

    public class RiskAnalyticsData {

        @AuraEnabled
        public Integer totalStudents { get; set; }

        @AuraEnabled
        public Integer lowRisk { get; set; }

        @AuraEnabled
        public Integer mediumRisk { get; set; }

        @AuraEnabled
        public Integer highRisk { get; set; }

        @AuraEnabled
        public Integer criticalRisk { get; set; }

        @AuraEnabled
        public List<Student__c> highRiskStudents { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static RiskAnalyticsData getRiskAnalytics() {

        RiskAnalyticsData data = new RiskAnalyticsData();

        data.lowRisk = 0;
        data.mediumRisk = 0;
        data.highRisk = 0;
        data.criticalRisk = 0;

        // Count active students.
        data.totalStudents = [
            SELECT COUNT()
            FROM Student__c
            WHERE Is_Active__c = true
        ];

        // Group students by risk category.
        List<AggregateResult> results = [
            SELECT Risk_Category__c category, COUNT(Id) total
            FROM Student__c
            WHERE Is_Active__c = true
            GROUP BY Risk_Category__c
        ];

        for (AggregateResult result : results) {

            String category = (String) result.get('category');
            Integer count = (Integer) result.get('total');

            if (category == 'Low') {
                data.lowRisk = count;
            } else if (category == 'Medium') {
                data.mediumRisk = count;
            } else if (category == 'High') {
                data.highRisk = count;
            } else if (category == 'Critical') {
                data.criticalRisk = count;
            }
        }

        // Fetch High and Critical risk students.
        data.highRiskStudents = [
            SELECT Id,
                   Name,
                   First_Name__c,
                   Last_Name__c,
                   Department__c,
                   CGPA__c,
                   Attendance_Percentage__c,
                   Risk_Score__c,
                   Risk_Category__c
            FROM Student__c
            WHERE Is_Active__c = true
            AND Risk_Category__c IN ('High', 'Critical')
            ORDER BY Risk_Score__c DESC NULLS LAST
            LIMIT 50
        ];

        return data;
    }
}
