@IsTest
private class AcademicRecordTriggerTest {

    @IsTest
    static void testAcademicRecordInsert() {

        Student__c student = new Student__c(
            First_Name__c = 'Academic',
            Last_Name__c = 'Test',
            Email__c = 'academic.test@example.com'
        );

        insert student;

        Test.startTest();

        Academic_Record__c academic = new Academic_Record__c(
            Student__c = student.Id,
            Academic_Year__c = '2026-2027',
            Semester__c = 1,
            SGPA__c = 8,
            Credits_Earned__c = 20,
            Result_Status__c = 'Pass'
        );

        insert academic;

        Test.stopTest();

        Student__c result = [
            SELECT Risk_Score__c
            FROM Student__c
            WHERE Id = :student.Id
        ];

        System.assertEquals(
            20.00,
            result.Risk_Score__c,
            'SGPA of 8 should produce 20 academic risk.'
        );
    }


    @IsTest
    static void testAcademicRecordUpdate() {

        Student__c student = new Student__c(
            First_Name__c = 'AcademicUpdate',
            Last_Name__c = 'Test',
            Email__c = 'academic.update@example.com'
        );

        insert student;

        Academic_Record__c academic = new Academic_Record__c(
            Student__c = student.Id,
            Academic_Year__c = '2026-2027',
            Semester__c = 1,
            SGPA__c = 8,
            Credits_Earned__c = 20,
            Result_Status__c = 'Pass'
        );

        insert academic;

        Test.startTest();

        Academic_Record__c updatedAcademic =
            new Academic_Record__c(
                Id = academic.Id,
                SGPA__c = 6
            );

        update updatedAcademic;

        Test.stopTest();

        Student__c result = [
            SELECT Risk_Score__c
            FROM Student__c
            WHERE Id = :student.Id
        ];

        System.assertEquals(
            40.00,
            result.Risk_Score__c,
            'SGPA of 6 should produce 40 academic risk.'
        );
    }
}