
@IsTest
private class StudentRiskBatchTest {

    @IsTest
    static void testBatchProcessesMultipleStudents() {

        List<Student__c> students = new List<Student__c>{
            new Student__c(
                First_Name__c = 'Arun',
                Last_Name__c = 'Kumar',
                Email__c = 'arun.batch@test.com'
            ),
            new Student__c(
                First_Name__c = 'Ravi',
                Last_Name__c = 'Sharma',
                Email__c = 'ravi.batch@test.com'
            )
        };

        insert students;

        List<Attendance_Record__c> attendanceRecords =
            new List<Attendance_Record__c>{
                new Attendance_Record__c(
                    Student__c = students[0].Id,
                    Month__c = Date.today(),
                    Total_Classes__c = 20,
                    Classes_Attended__c = 10
                ),
                new Attendance_Record__c(
                    Student__c = students[1].Id,
                    Month__c = Date.today(),
                    Total_Classes__c = 20,
                    Classes_Attended__c = 15
                )
            };

        insert attendanceRecords;

        Test.startTest();

        Database.executeBatch(new StudentRiskBatch(), 200);

        Test.stopTest();

        Map<Id, Student__c> updatedStudents =
            new Map<Id, Student__c>([
                SELECT Id, Risk_Score__c
                FROM Student__c
                WHERE Id IN :students
            ]);

        System.assertEquals(
            50.00,
            updatedStudents.get(students[0].Id).Risk_Score__c
        );

        System.assertEquals(
            25.00,
            updatedStudents.get(students[1].Id).Risk_Score__c
        );
    }
}
