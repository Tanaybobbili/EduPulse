public with sharing class StudentRiskService {

    public static void calculateRiskScores(Set<Id> studentIds) {

        if (studentIds == null || studentIds.isEmpty()) {
            return;
        }

        // Fetch student performance summaries.
        List<Student__c> students = [
            SELECT Id,
                   Total_Classes_Attended__c,
                   Total_Classes__c,
                   Academic_Record_Count__c,
                   Total_SGPA__c,
                   Assessment_Record_Count__c,
                   Total_Assessment_Marks__c,
                   Total_Maximum_Marks__c,
                   Risk_Score__c
            FROM Student__c
            WHERE Id IN :studentIds
        ];

        // Store skill proficiency totals for each student.
        Map<Id, Decimal> skillTotals = new Map<Id, Decimal>();
        Map<Id, Integer> skillCounts = new Map<Id, Integer>();

        List<Student_Skill__c> skills = [
            SELECT Student__c, Proficiency_Level__c
            FROM Student_Skill__c
            WHERE Student__c IN :studentIds
        ];

        for (Student_Skill__c skill : skills) {

            Decimal proficiencyScore;

            if (skill.Proficiency_Level__c == 'Beginner') {
                proficiencyScore = 25;
            } else if (skill.Proficiency_Level__c == 'Intermediate') {
                proficiencyScore = 50;
            } else if (skill.Proficiency_Level__c == 'Advanced') {
                proficiencyScore = 75;
            } else if (skill.Proficiency_Level__c == 'Expert') {
                proficiencyScore = 100;
            } else {
                continue;
            }

            Id studentId = skill.Student__c;

            Decimal currentTotal = skillTotals.containsKey(studentId)
                ? skillTotals.get(studentId) : 0;

            Integer currentCount = skillCounts.containsKey(studentId)
                ? skillCounts.get(studentId) : 0;

            skillTotals.put(studentId, currentTotal + proficiencyScore);
            skillCounts.put(studentId, currentCount + 1);
        }

        List<Student__c> studentsToUpdate = new List<Student__c>();

        for (Student__c student : students) {

            Decimal totalWeightedRisk = 0;
            Decimal availableWeight = 0;

            // 1. Attendance risk - 30%
            if (student.Total_Classes__c != null &&
                student.Total_Classes__c > 0) {

                Decimal attendancePercentage =
                    (student.Total_Classes_Attended__c /
                    student.Total_Classes__c) * 100;

                Decimal attendanceRisk = 100 - attendancePercentage;

                totalWeightedRisk += attendanceRisk * 0.30;
                availableWeight += 0.30;
            }

            // 2. Academic risk - 30%
            if (student.Academic_Record_Count__c != null &&
                student.Academic_Record_Count__c > 0) {

                Decimal academicPercentage =
                    (student.Total_SGPA__c /
                    student.Academic_Record_Count__c) * 10;

                Decimal academicRisk = 100 - academicPercentage;

                totalWeightedRisk += academicRisk * 0.30;
                availableWeight += 0.30;
            }

            // 3. Assessment risk - 25%
            if (student.Total_Maximum_Marks__c != null &&
                student.Total_Maximum_Marks__c > 0) {

                Decimal assessmentPercentage =
                    (student.Total_Assessment_Marks__c /
                    student.Total_Maximum_Marks__c) * 100;

                Decimal assessmentRisk = 100 - assessmentPercentage;

                totalWeightedRisk += assessmentRisk * 0.25;
                availableWeight += 0.25;
            }

            // 4. Learning progress risk - 15%
            if (skillCounts.containsKey(student.Id) &&
                skillCounts.get(student.Id) > 0) {

                Decimal averageSkillScore =
                    skillTotals.get(student.Id) /
                    skillCounts.get(student.Id);

                Decimal learningRisk = 100 - averageSkillScore;

                totalWeightedRisk += learningRisk * 0.15;
                availableWeight += 0.15;
            }

            // Skip students who have no usable performance data.
            if (availableWeight == 0) {
                continue;
            }

            // Normalize the score using only available factors.
            Decimal riskScore =
                totalWeightedRisk / availableWeight;

            // Keep the score within the 0-100 range.
            if (riskScore < 0) {
                riskScore = 0;
            } else if (riskScore > 100) {
                riskScore = 100;
            }

            student.Risk_Score__c =
                riskScore.setScale(2, RoundingMode.HALF_UP);

            studentsToUpdate.add(student);
        }

        // Perform one bulk update outside the loop.
        if (!studentsToUpdate.isEmpty()) {
            update studentsToUpdate;
        }
    }
}