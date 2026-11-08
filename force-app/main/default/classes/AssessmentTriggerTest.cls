@IsTest
private class AssessmentTriggerTest {

    @IsTest
    static void testAssessmentInsert() {

        Student__c student = new Student__c(
            First_Name__c = 'Assessment',
            Last_Name__c = 'Test',
            Email__c = 'assessment.test@example.com'
        );

        insert student;

        Test.startTest();

        Assessment__c assessment = new Assessment__c(
            Student__c = student.Id,
            Assessment_Name__c = 'Java Test',
            Subject__c = 'Java',
            Assessment_Date__c = Date.today(),
            Maximum_Marks__c = 100,
            Marks_Obtained__c = 60
        );

        insert assessment;

        Test.stopTest();

        Student__c result = [
            SELECT Risk_Score__c
            FROM Student__c
            WHERE Id = :student.Id
        ];

        System.assertEquals(
            40.00,
            result.Risk_Score__c,
            '60% assessment performance should produce 40 risk.'
        );
    }


    @IsTest
    static void testAssessmentUpdate() {

        Student__c student = new Student__c(
            First_Name__c = 'AssessmentUpdate',
            Last_Name__c = 'Test',
            Email__c = 'assessment.update@example.com'
        );

        insert student;

        Assessment__c assessment = new Assessment__c(
            Student__c = student.Id,
            Assessment_Name__c = 'Python Test',
            Subject__c = 'Python',
            Assessment_Date__c = Date.today(),
            Maximum_Marks__c = 100,
            Marks_Obtained__c = 60
        );

        insert assessment;

        Test.startTest();

        Assessment__c updatedAssessment =
            new Assessment__c(
                Id = assessment.Id,
                Marks_Obtained__c = 80
            );

        update updatedAssessment;

        Test.stopTest();

        Student__c result = [
            SELECT Risk_Score__c
            FROM Student__c
            WHERE Id = :student.Id
        ];

        System.assertEquals(
            20.00,
            result.Risk_Score__c,
            '80% assessment performance should produce 20 risk.'
        );
    }
}