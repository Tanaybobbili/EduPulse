@IsTest
private class MentorAllocationControllerTest {

    @TestSetup
    static void setupData() {
        List<Student__c> students = new List<Student__c>();

        students.add(new Student__c(
            First_Name__c = 'Arun',
            Last_Name__c = 'Kumar',
            Email__c = 'arun@test.com'
        ));

        students.add(new Student__c(
            First_Name__c = 'Rahul',
            Last_Name__c = 'Sharma',
            Email__c = 'rahul@test.com'
        ));

        insert students;

        List<Mentor__c> mentors = new List<Mentor__c>();

        mentors.add(new Mentor__c(
            Mentor_Name__c = 'Ravi Kumar',
            Email__c = 'ravi@test.com',
            Department__c = 'Computer Science',
            Availability__c = 'Available',
            Maximum_Capacity__c = 5,
            Current_Mentees__c = 0,
            Is_Active__c = true
        ));

        mentors.add(new Mentor__c(
            Mentor_Name__c = 'Priya Sharma',
            Email__c = 'priya@test.com',
            Department__c = 'Information Technology',
            Availability__c = 'Available',
            Maximum_Capacity__c = 1,
            Current_Mentees__c = 0,
            Is_Active__c = true
        ));

        insert mentors;
    }

    @IsTest
    static void testGetStudentsAndMentors() {
        Test.startTest();

        List<Student__c> students =
            MentorAllocationController.getStudents();

        List<Mentor__c> mentors =
            MentorAllocationController.getAvailableMentors();

        Test.stopTest();

        System.assertEquals(2, students.size());
        System.assertEquals(2, mentors.size());
    }

    @IsTest
    static void testSuccessfulAssignment() {
        Student__c student = [
            SELECT Id FROM Student__c
            WHERE First_Name__c = 'Arun'
            LIMIT 1
        ];

        Mentor__c mentor = [
            SELECT Id FROM Mentor__c
            WHERE Mentor_Name__c = 'Ravi Kumar'
            LIMIT 1
        ];

        Test.startTest();

        Mentorship__c result =
            MentorAllocationController.assignMentor(
                student.Id,
                mentor.Id
            );

        Test.stopTest();

        System.assertNotEquals(null, result.Id);
        System.assertEquals('Active', result.Status__c);

        Mentor__c updatedMentor = [
            SELECT Current_Mentees__c
            FROM Mentor__c
            WHERE Id = :mentor.Id
        ];

        System.assertEquals(1, updatedMentor.Current_Mentees__c);
    }

    @IsTest
    static void testDuplicateAssignmentPrevented() {
        Student__c student = [
            SELECT Id FROM Student__c
            WHERE First_Name__c = 'Arun'
            LIMIT 1
        ];

        List<Mentor__c> mentors = [
            SELECT Id FROM Mentor__c
            ORDER BY Mentor_Name__c
        ];

        MentorAllocationController.assignMentor(
            student.Id,
            mentors[0].Id
        );

        Boolean exceptionThrown = false;

        Test.startTest();

        try {
            MentorAllocationController.assignMentor(
                student.Id,
                mentors[1].Id
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        System.assert(
            exceptionThrown,
            'Duplicate mentorship should be prevented.'
        );
    }

    @IsTest
    static void testMentorCapacityEnforced() {
        Student__c student = [
            SELECT Id FROM Student__c
            WHERE First_Name__c = 'Arun'
            LIMIT 1
        ];

        Student__c otherStudent = [
            SELECT Id FROM Student__c
            WHERE First_Name__c = 'Rahul'
            LIMIT 1
        ];

        Mentor__c mentor = [
            SELECT Id FROM Mentor__c
            WHERE Mentor_Name__c = 'Priya Sharma'
            LIMIT 1
        ];

        insert new Mentorship__c(
            Student__c = otherStudent.Id,
            Mentor__c = mentor.Id,
            Start_Date__c = Date.today(),
            Status__c = 'Active'
        );

        Boolean exceptionThrown = false;

        Test.startTest();

        try {
            MentorAllocationController.assignMentor(
                student.Id,
                mentor.Id
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        System.assert(
            exceptionThrown,
            'Assignment should fail when mentor capacity is full.'
        );
    }

    @IsTest
    static void testNullInputsRejected() {
        Boolean exceptionThrown = false;

        Test.startTest();

        try {
            MentorAllocationController.assignMentor(null, null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        Test.stopTest();

        System.assert(exceptionThrown);
    }
}