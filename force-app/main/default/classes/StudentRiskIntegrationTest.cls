
@isTest
private class StudentRiskIntegrationTest {

    @isTest
    static void testCompleteFourFactorRiskCalculation() {

        // Create student.
        Student__c student = new Student__c(
            First_Name__c = 'Integration',
            Last_Name__c = 'Test',
            Email__c = 'integration@example.com'
        );
        insert student;

        // Create skill.
        Skill__c skill = new Skill__c(
            Name = 'Java',
            Skill_Code__c = 'JAVA-INT',
            Skill_Category__c = 'Programming'
        );
        insert skill;

        Test.startTest();

        // 1. Attendance: 16 / 20 = 80%.
        Attendance_Record__c attendance =
            new Attendance_Record__c(
                Student__c = student.Id,
                Month__c = Date.today(),
                Total_Classes__c = 20,
                Classes_Attended__c = 16
            );
        insert attendance;

        // 2. Academic performance: SGPA = 8.
        Academic_Record__c academic =
            new Academic_Record__c(
                Student__c = student.Id,
                Academic_Year__c = '2026-2027',
                Semester__c = 1,
                SGPA__c = 8,
                Credits_Earned__c = 20,
                Result_Status__c = 'Pass'
            );
        insert academic;

        // 3. Assessment: 70 / 100 = 70%.
        Assessment__c assessment =
            new Assessment__c(
                Student__c = student.Id,
                Assessment_Name__c = 'Midterm Test',
                Subject__c = 'Mathematics',
                Assessment_Date__c = Date.today(),
                Maximum_Marks__c = 100,
                Marks_Obtained__c = 70
            );
        insert assessment;

        // 4. Learning progress: Advanced = 75.
        Student_Skill__c studentSkill =
            new Student_Skill__c(
                Student__c = student.Id,
                Skill__c = skill.Id,
                Proficiency_Level__c = 'Advanced'
            );
        insert studentSkill;

        // Execute all queued risk calculations.
        Test.stopTest();

        // Retrieve the calculated risk score.
        Student__c result = [
            SELECT Risk_Score__c, Risk_Category__c
            FROM Student__c
            WHERE Id = :student.Id
        ];

        System.assertEquals(
            23.25,
            result.Risk_Score__c,
            'The combined four-factor risk score should be 23.25.'
        );

        System.assertEquals(
            'Low',
            result.Risk_Category__c,
            'A risk score of 23.25 should be classified as Low.'
        );
    }
}
