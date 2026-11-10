
public with sharing class InternshipMatchingController {

    // Fetch active students for the selection dropdown.
    @AuraEnabled(cacheable=true)
    public static List<Student__c> getStudents() {

        return [
            SELECT Id, Name, First_Name__c, Last_Name__c,
                   CGPA__c, Risk_Category__c
            FROM Student__c
            WHERE Is_Active__c = true
            ORDER BY First_Name__c, Last_Name__c
            LIMIT 200
        ];
    }

    // Fetch active career opportunities.
    @AuraEnabled(cacheable=true)
    public static List<Career_Opportunity__c> getOpportunities() {

        return [
            SELECT Id, Name, Opportunity_Title__c,
                   Company__c, Opportunity_Type__c,
                   Career_Interest__c, Minimum_CGPA__c,
                   Minimum_Attendance__c,
                   Application_Deadline__c
            FROM Career_Opportunity__c
            WHERE Is_Active__c = true
            ORDER BY CreatedDate DESC
            LIMIT 200
        ];
    }

    // Calculate and return the matching result.
    @AuraEnabled
    public static Matching_Result__c calculateMatch(
        Id studentId,
        Id opportunityId
    ) {

        if (studentId == null || opportunityId == null) {
            throw new AuraHandledException(
                'Please select both a student and an opportunity.'
            );
        }

        try {

            InternshipMatchingService.calculateMatches(
                new Set<Id>{ studentId },
                opportunityId
            );

            List<Matching_Result__c> results = [
                SELECT Id, Student__c, Career_Opportunity__c,
                       Skill_Match__c, Academic_Match__c,
                       Interest_Match__c, Overall_Match__c,
                       Is_Eligible__c, Match_Reason__c,
                       Calculated_At__c
                FROM Matching_Result__c
                WHERE Student__c = :studentId
                AND Career_Opportunity__c = :opportunityId
                ORDER BY Calculated_At__c DESC
                LIMIT 1
            ];

            if (results.isEmpty()) {
                throw new AuraHandledException(
                    'No matching result was generated.'
                );
            }

            return results[0];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
