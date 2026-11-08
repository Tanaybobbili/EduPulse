@IsTest
private class StudentRiskQueueableTest {

    @IsTest
    static void testQueueableRiskCalculation() {

        Student__c student = new Student__c(
            First_Name__c = 'Queue',
            Last_Name__c = 'Test',
            Email__c = 'queue.test@example.com'
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

        System.enqueueJob(
            new StudentRiskQueueable(new Set<Id>{student.Id})
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
            'Queueable should calculate the attendance risk score.'
        );
    }
}