/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest
private class StudentRiskServiceTest {

    // Test 1: Calculate risk using attendance data.
    @IsTest
    static void testAttendanceRiskCalculation() {

        Student__c student = new Student__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Student',
            Email__c = 'teststudent@example.com'
        );

        insert student;

        Attendance_Record__c attendance = new Attendance_Record__c(
            Student__c = student.Id,
            Month__c = Date.today(),
            Total_Classes__c = 20,
            Classes_Attended__c = 10
        );

        insert attendance;

        Test.startTest();

        StudentRiskService.calculateRiskScores(
            new Set<Id>{student.Id}
        );

        Test.stopTest();

        Student__c result = [
            SELECT Risk_Score__c
            FROM Student__c
            WHERE Id = :student.Id
        ];

        System.assertEquals(
            50.00,
            result.Risk_Score__c,
            'A student with 50% attendance should have 50 risk.'
        );
    }


    // Test 2: Do not calculate risk when no data exists.
    @IsTest
    static void testNoPerformanceData() {

        Student__c student = new Student__c(
            First_Name__c = 'NoData',
            Last_Name__c = 'Student',
            Email__c = 'nodata@example.com'
        );

        insert student;

        Test.startTest();

        StudentRiskService.calculateRiskScores(
            new Set<Id>{student.Id}
        );

        Test.stopTest();

        Student__c result = [
            SELECT Risk_Score__c
            FROM Student__c
            WHERE Id = :student.Id
        ];

        System.assertEquals(
            null,
            result.Risk_Score__c,
            'Risk score should remain blank when no performance data exists.'
        );
    }


    // Test 3: Handle empty and null student ID sets.
    @IsTest
    static void testEmptyStudentIds() {

        Test.startTest();

        StudentRiskService.calculateRiskScores(new Set<Id>());
        StudentRiskService.calculateRiskScores(null);

        Test.stopTest();

        System.assert(true, 'Empty inputs should be handled safely.');
    }
}