@isTest
private class StudentSkillTriggerTest {

    @isTest
    static void testSkillInsertCalculatesAverageProficiency() {

        Student__c student = new Student__c(
            First_Name__c = 'Skill',
            Last_Name__c = 'Test',
            Email__c = 'skilltest@example.com'
        );
        insert student;

        List<Skill__c> skills = new List<Skill__c>{
            new Skill__c(
                Name = 'Java',
                Skill_Code__c = 'JAVA-TST',
                Skill_Category__c = 'Programming'
            ),
            new Skill__c(
                Name = 'Python',
                Skill_Code__c = 'PYTHON-TST',
                Skill_Category__c = 'Programming'
            ),
            new Skill__c(
                Name = 'SQL',
                Skill_Code__c = 'SQL-TST',
                Skill_Category__c = 'Programming'
            ),
            new Skill__c(
                Name = 'React',
                Skill_Code__c = 'REACT-TST',
                Skill_Category__c = 'Programming'
            )
        };
        insert skills;

        List<Student_Skill__c> studentSkills =
            new List<Student_Skill__c>{
                new Student_Skill__c(
                    Student__c = student.Id,
                    Skill__c = skills[0].Id,
                    Proficiency_Level__c = 'Beginner'
                ),
                new Student_Skill__c(
                    Student__c = student.Id,
                    Skill__c = skills[1].Id,
                    Proficiency_Level__c = 'Intermediate'
                ),
                new Student_Skill__c(
                    Student__c = student.Id,
                    Skill__c = skills[2].Id,
                    Proficiency_Level__c = 'Advanced'
                ),
                new Student_Skill__c(
                    Student__c = student.Id,
                    Skill__c = skills[3].Id,
                    Proficiency_Level__c = 'Expert'
                )
            };

        Test.startTest();
        insert studentSkills;
        Test.stopTest();

        Student__c result = [
            SELECT Risk_Score__c
            FROM Student__c
            WHERE Id = :student.Id
        ];

        // Average proficiency = (25 + 50 + 75 + 100) / 4 = 62.5
        // Learning risk = 100 - 62.5 = 37.5
        System.assertEquals(
            37.50,
            result.Risk_Score__c,
            'Risk score should reflect the average of all four proficiency levels.'
        );
    }


    @isTest
    static void testSkillUpdateRecalculatesRisk() {

        Student__c student = new Student__c(
            First_Name__c = 'Update',
            Last_Name__c = 'Test',
            Email__c = 'skillupdate@example.com'
        );
        insert student;

        Skill__c skill = new Skill__c(
            Name = 'Java',
            Skill_Code__c = 'JAVA-UPD',
            Skill_Category__c = 'Programming'
        );
        insert skill;

        Student_Skill__c studentSkill = new Student_Skill__c(
            Student__c = student.Id,
            Skill__c = skill.Id,
            Proficiency_Level__c = 'Beginner'
        );
        insert studentSkill;

        Test.startTest();

        // Use a sparse update to change only the proficiency field.
        Student_Skill__c updatedSkill = new Student_Skill__c(
            Id = studentSkill.Id,
            Proficiency_Level__c = 'Expert'
        );
        update updatedSkill;

        Test.stopTest();

        Student__c result = [
            SELECT Risk_Score__c
            FROM Student__c
            WHERE Id = :student.Id
        ];

        // Expert proficiency = 100, so learning risk = 0.
        System.assertEquals(
            0,
            result.Risk_Score__c,
            'Risk score should become zero when the only skill is Expert.'
        );
    }
}