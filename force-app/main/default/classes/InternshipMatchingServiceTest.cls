@IsTest
private class InternshipMatchingServiceTest {

    @TestSetup
    static void setupData() {

        // Create students.
        Student__c student1 = new Student__c(
            First_Name__c = 'Arun',
            Last_Name__c = 'Kumar',
            Email__c = 'arun@test.com',
            CGPA__c = 9,
            Career_Interest__c = 'Software Development'
        );

        Student__c student2 = new Student__c(
            First_Name__c = 'Ravi',
            Last_Name__c = 'Sharma',
            Email__c = 'ravi@test.com',
            CGPA__c = 8,
            Career_Interest__c = 'Software Development'
        );

        insert new List<Student__c>{student1, student2};

        // Create a career opportunity.
        Career_Opportunity__c opportunity =
            new Career_Opportunity__c(
                Opportunity_Title__c = 'Java Developer Intern',
                Company__c = 'EduTech',
                Opportunity_Type__c = 'Internship',
                Career_Interest__c = 'Software Development',
                Minimum_CGPA__c = 7,
                Minimum_Attendance__c = 75,
                Application_Deadline__c = Date.today().addDays(30),
                Is_Active__c = true
            );

        insert opportunity;

        // Create a skill.
        Skill__c skill = new Skill__c(
            Name = 'Java',
            Skill_Code__c = 'JAVA',
            Skill_Category__c = 'Programming',
            Is_Active__c = true
        );

        insert skill;

        // Require Advanced Java proficiency.
        Opportunity_Skill__c requiredSkill =
            new Opportunity_Skill__c(
                Career_Opportunity__c = opportunity.Id,
                Skill__c = skill.Id,
                Required_Proficiency__c = 'Advanced',
                Is_Mandatory__c = true
            );

        insert requiredSkill;

        // Arun has Advanced Java.
        // Ravi does not have Java.
        Student_Skill__c studentSkill =
            new Student_Skill__c(
                Student__c = student1.Id,
                Skill__c = skill.Id,
                Proficiency_Level__c = 'Advanced',
                Experience_Years__c = 2
            );

        insert studentSkill;

        // Create attendance records.
        Attendance_Record__c attendance1 =
            new Attendance_Record__c(
                Student__c = student1.Id,
                Month__c = Date.today().toStartOfMonth(),
                Total_Classes__c = 100,
                Classes_Attended__c = 90
            );

        Attendance_Record__c attendance2 =
            new Attendance_Record__c(
                Student__c = student2.Id,
                Month__c = Date.today().toStartOfMonth(),
                Total_Classes__c = 100,
                Classes_Attended__c = 80
            );

        insert new List<Attendance_Record__c>{
            attendance1, attendance2
        };
    }

    @IsTest
    static void testEligibleAndIneligibleStudents() {

        Map<String, Student__c> students =
            new Map<String, Student__c>();

        for (Student__c student : [
            SELECT Id, First_Name__c
            FROM Student__c
        ]) {
            students.put(student.First_Name__c, student);
        }

        Career_Opportunity__c opportunity = [
            SELECT Id
            FROM Career_Opportunity__c
            LIMIT 1
        ];

        Set<Id> studentIds = new Set<Id>{
            students.get('Arun').Id,
            students.get('Ravi').Id
        };

        Test.startTest();

        InternshipMatchingService.calculateMatches(
            studentIds,
            opportunity.Id
        );

        Test.stopTest();

        Map<Id, Matching_Result__c> results =
            new Map<Id, Matching_Result__c>();

        for (Matching_Result__c result : [
            SELECT Student__c,
                   Skill_Match__c,
                   Academic_Match__c,
                   Interest_Match__c,
                   Overall_Match__c,
                   Is_Eligible__c
            FROM Matching_Result__c
            WHERE Career_Opportunity__c = :opportunity.Id
        ]) {
            results.put(result.Student__c, result);
        }

        Matching_Result__c arunResult =
            results.get(students.get('Arun').Id);

        Matching_Result__c raviResult =
            results.get(students.get('Ravi').Id);

        System.assertNotEquals(
            null,
            arunResult,
            'Arun matching result should be created.'
        );

        System.assertEquals(
            true,
            arunResult.Is_Eligible__c,
            'Arun should be eligible.'
        );

        System.assertEquals(
            100,
            arunResult.Skill_Match__c,
            'Arun should have a 100% skill match.'
        );

        System.assertEquals(
            100,
            arunResult.Interest_Match__c,
            'Arun should have a 100% interest match.'
        );

        System.assertEquals(
            97,
            arunResult.Overall_Match__c,
            'Arun overall match should be 90%.'
        );

        System.assertNotEquals(
            null,
            raviResult,
            'Ravi matching result should be created.'
        );

        System.assertEquals(
            false,
            raviResult.Is_Eligible__c,
            'Ravi should be ineligible because he lacks mandatory Java.'
        );

        System.assertEquals(
            0,
            raviResult.Skill_Match__c,
            'Ravi should have a 0% skill match.'
        );
    }

    @IsTest
    static void testExistingResultUpdatedWithoutDuplicates() {

        Student__c student = [
            SELECT Id
            FROM Student__c
            WHERE First_Name__c = 'Arun'
            LIMIT 1
        ];

        Career_Opportunity__c opportunity = [
            SELECT Id
            FROM Career_Opportunity__c
            LIMIT 1
        ];

        Matching_Result__c existingResult =
            new Matching_Result__c(
                Student__c = student.Id,
                Career_Opportunity__c = opportunity.Id,
                Skill_Match__c = 20,
                Academic_Match__c = 20,
                Interest_Match__c = 20,
                Is_Eligible__c = false
            );

        insert existingResult;

        Test.startTest();

        InternshipMatchingService.calculateMatches(
            new Set<Id>{student.Id},
            opportunity.Id
        );

        Test.stopTest();

        List<Matching_Result__c> results = [
            SELECT Id, Skill_Match__c, Is_Eligible__c
            FROM Matching_Result__c
            WHERE Student__c = :student.Id
            AND Career_Opportunity__c = :opportunity.Id
        ];

        System.assertEquals(
            1,
            results.size(),
            'Existing result should be updated, not duplicated.'
        );

        System.assertEquals(
            100,
            results[0].Skill_Match__c,
            'Existing skill match should be recalculated.'
        );

        System.assertEquals(
            true,
            results[0].Is_Eligible__c,
            'Existing eligibility should be updated.'
        );
    }

    @IsTest
    static void testInvalidInputs() {

        Test.startTest();

        InternshipMatchingService.calculateMatches(
            null,
            null
        );

        InternshipMatchingService.calculateMatches(
            new Set<Id>(),
            null
        );

        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Matching_Result__c],
            'Invalid inputs should not create matching results.'
        );
    }
}