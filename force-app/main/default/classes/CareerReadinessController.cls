public with sharing class CareerReadinessController {

    // Data returned to the LWC.
    public class StudentSnapshot {

        @AuraEnabled public Id studentId { get; set; }
        @AuraEnabled public String studentName { get; set; }
        @AuraEnabled public Decimal cgpa { get; set; }
        @AuraEnabled public Decimal attendance { get; set; }
        @AuraEnabled public Decimal assessmentScore { get; set; }
        @AuraEnabled public Decimal skillProficiency { get; set; }
        @AuraEnabled public Decimal currentRisk { get; set; }
        @AuraEnabled public String riskCategory { get; set; }
    }

    // Return active students for the dropdown.
    @AuraEnabled(cacheable=true)
    public static List<Student__c> getStudents() {

        return [
            SELECT Id, Name, First_Name__c, Last_Name__c
            FROM Student__c
            WHERE Is_Active__c = true
            ORDER BY First_Name__c, Last_Name__c
            LIMIT 200
        ];
    }

    // Fetch the student's current performance metrics.
    @AuraEnabled(cacheable=true)
    public static StudentSnapshot getStudentSnapshot(Id studentId) {

        if (studentId == null) {
            throw new AuraHandledException(
                'Please select a student.'
            );
        }

        Student__c student = [
            SELECT Id, Name, First_Name__c, Last_Name__c,
                   CGPA__c, Attendance_Percentage__c,
                   Risk_Score__c, Risk_Category__c,
                   Total_Assessment_Marks__c,
                   Total_Maximum_Marks__c
            FROM Student__c
            WHERE Id = :studentId
            LIMIT 1
        ];

        StudentSnapshot data = new StudentSnapshot();

        data.studentId = student.Id;
        data.studentName =
            student.First_Name__c + ' ' + student.Last_Name__c;

        data.cgpa = student.CGPA__c;
        data.attendance = student.Attendance_Percentage__c;
        data.currentRisk = student.Risk_Score__c;
        data.riskCategory = student.Risk_Category__c;

        // Calculate assessment percentage.
        if (student.Total_Maximum_Marks__c != null &&
            student.Total_Maximum_Marks__c > 0) {

            data.assessmentScore =
                (student.Total_Assessment_Marks__c /
                student.Total_Maximum_Marks__c) * 100;

        } else {
            data.assessmentScore = 0;
        }

        // Calculate average skill proficiency.
        List<Student_Skill__c> skills = [
            SELECT Proficiency_Level__c
            FROM Student_Skill__c
            WHERE Student__c = :studentId
        ];

        Decimal totalSkillScore = 0;
        Integer skillCount = 0;

        for (Student_Skill__c skill : skills) {

            if (skill.Proficiency_Level__c == 'Beginner') {
                totalSkillScore += 25;
            } else if (skill.Proficiency_Level__c == 'Intermediate') {
                totalSkillScore += 50;
            } else if (skill.Proficiency_Level__c == 'Advanced') {
                totalSkillScore += 75;
            } else if (skill.Proficiency_Level__c == 'Expert') {
                totalSkillScore += 100;
            } else {
                continue;
            }

            skillCount++;
        }

        data.skillProficiency = skillCount > 0
            ? totalSkillScore / skillCount
            : 0;

        return data;
    }

    // Calculate hypothetical risk without updating Salesforce records.
    @AuraEnabled
    public static Decimal calculateProjectedRisk(
        Decimal attendance,
        Decimal cgpa,
        Decimal assessmentScore,
        Decimal skillProficiency
    ) {

        if (attendance == null || attendance < 0 || attendance > 100 ||
            cgpa == null || cgpa < 0 || cgpa > 10 ||
            assessmentScore == null ||
            assessmentScore < 0 || assessmentScore > 100 ||
            skillProficiency == null ||
            skillProficiency < 0 || skillProficiency > 100) {

            throw new AuraHandledException(
                'Enter valid values within the permitted ranges.'
            );
        }

        Decimal attendanceRisk = 100 - attendance;
        Decimal academicRisk = 100 - (cgpa * 10);
        Decimal assessmentRisk = 100 - assessmentScore;
        Decimal learningRisk = 100 - skillProficiency;

        Decimal projectedRisk =
            (attendanceRisk * 0.30) +
            (academicRisk * 0.30) +
            (assessmentRisk * 0.25) +
            (learningRisk * 0.15);

        return projectedRisk.setScale(2, RoundingMode.HALF_UP);
    }
}