@IsTest
private class AttendanceRecordTriggerTest {

    @IsTest
    static void testAttendanceInsertRecalculatesRisk() {

        Student__c student = new Student__c(
            First_Name__c = 'Trigger',
            Last_Name__c = 'Test',
            Email__c = 'trigger.test@example.com'
        );

        insert student;

        Test.startTest();

        Attendance_Record__c attendance =
            new Attendance_Record__c(
                Student__c = student.Id,
                Month__c = Date.today(),
                Total_Classes__c = 20,
                Classes_Attended__c = 10
            );

        insert attendance;

        Test.stopTest();

        Student__c result = [
            SELECT Risk_Score__c
            FROM Student__c
            WHERE Id = :student.Id
        ];

        System.assertEquals(
            50.00,
            result.Risk_Score__c,
            'Attendance trigger should automatically recalculate risk.'
        );
    }


    @IsTest
    static void testAttendanceUpdateRecalculatesRisk() {

        Student__c student = new Student__c(
            First_Name__c = 'Update',
            Last_Name__c = 'Test',
            Email__c = 'update.test@example.com'
        );

        insert student;

        Attendance_Record__c attendance =
            new Attendance_Record__c(
                Student__c = student.Id,
                Month__c = Date.today(),
                Total_Classes__c = 20,
                Classes_Attended__c = 10
            );

        insert attendance;

        // Test.startTest();

        // attendance.Classes_Attended__c = 15;
        // update attendance;

        // Test.stopTest();

        Test.startTest();

Attendance_Record__c updatedAttendance =
    new Attendance_Record__c(
        Id = attendance.Id,
        Classes_Attended__c = 15
    );

update updatedAttendance;

Test.stopTest();

        Student__c result = [
            SELECT Risk_Score__c
            FROM Student__c
            WHERE Id = :student.Id
        ];

        System.assertEquals(
            25.00,
            result.Risk_Score__c,
            'Updated attendance of 75% should produce 25 risk.'
        );
    }
}