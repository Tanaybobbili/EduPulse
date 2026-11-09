public with sharing class InternshipMatchingService {

    public static void calculateMatches(
        Set<Id> studentIds,
        Id opportunityId
    ) {

        if (studentIds == null ||
            studentIds.isEmpty() ||
            opportunityId == null) {
            return;
        }

        // Fetch the career opportunity.
        Career_Opportunity__c opportunity = [
            SELECT Id,
                   Opportunity_Title__c,
                   Is_Active__c,
                   Application_Deadline__c,
                   Minimum_CGPA__c,
                   Minimum_Attendance__c,
                   Career_Interest__c
            FROM Career_Opportunity__c
            WHERE Id = :opportunityId
            LIMIT 1
        ];

        // Fetch students.
        List<Student__c> students = [
            SELECT Id,
                   CGPA__c,
                   Attendance_Percentage__c,
                   Career_Interest__c
            FROM Student__c
            WHERE Id IN :studentIds
        ];

        // Fetch skills required by the opportunity.
        List<Opportunity_Skill__c> requiredSkills = [
            SELECT Id,
                Skill__c,
                Required_Proficiency__c,
                Is_Mandatory__c
            FROM Opportunity_Skill__c
            WHERE Career_Opportunity__c = :opportunityId
        ];

        // Fetch skills possessed by the students.
        List<Student_Skill__c> studentSkills = [
            SELECT Id,
                Student__c,
                Skill__c,
                Proficiency_Level__c
            FROM Student_Skill__c
            WHERE Student__c IN :studentIds
        ];

        // Organize student skills for faster comparison.
        Map<Id, Map<Id, String>> studentSkillMap =
            new Map<Id, Map<Id, String>>();

        for (Student_Skill__c skill : studentSkills) {

            if (!studentSkillMap.containsKey(skill.Student__c)) {
                studentSkillMap.put(
                    skill.Student__c,
                    new Map<Id, String>()
                );
            }

            studentSkillMap.get(skill.Student__c).put(
                skill.Skill__c,
                skill.Proficiency_Level__c
            );
        }

        // Convert proficiency levels into numerical scores.
        Map<String, Integer> proficiencyScores =
            new Map<String, Integer>{
                'Beginner' => 25,
                'Intermediate' => 50,
                'Advanced' => 75,
                'Expert' => 100
            };

        // Store matching results.
        List<Matching_Result__c> results =
            new List<Matching_Result__c>();

        // Fetch existing matching results for this opportunity.
        Map<Id, Matching_Result__c> existingResults =
            new Map<Id, Matching_Result__c>();

        for (Matching_Result__c oldResult : [
            SELECT Id, Student__c
            FROM Matching_Result__c
            WHERE Career_Opportunity__c = :opportunityId
            AND Student__c IN :studentIds
        ]) {
            existingResults.put(oldResult.Student__c, oldResult);
        }

        for (Student__c student : students) {

            Decimal totalSkillScore = 0;
            Integer matchedSkills = 0;
            Boolean mandatorySkillsMet = true;

            Map<Id, String> studentMap =
                studentSkillMap.containsKey(student.Id)
                ? studentSkillMap.get(student.Id)
                : new Map<Id, String>();

            for (Opportunity_Skill__c requiredSkill : requiredSkills) {

                String studentLevel = studentMap.get(requiredSkill.Skill__c);

                Integer studentScore = proficiencyScores.get(studentLevel);
                Integer requiredScore =
                    proficiencyScores.get(requiredSkill.Required_Proficiency__c);

                if (studentScore != null && requiredScore != null) {

                    if (studentScore >= requiredScore) {
                        matchedSkills++;
                        totalSkillScore += 100;
                    } else {
                        totalSkillScore +=
                            (Decimal.valueOf(studentScore) /
                            requiredScore) * 100;

                        if (requiredSkill.Is_Mandatory__c) {
                            mandatorySkillsMet = false;
                        }
                    }

                } else if (requiredSkill.Is_Mandatory__c) {
                    mandatorySkillsMet = false;
                }
            }

            Decimal skillMatch = 0;

            if (!requiredSkills.isEmpty()) {
                skillMatch = totalSkillScore / requiredSkills.size();
            }

            // Calculate academic match.
            Decimal academicMatch = 0;

            if (student.CGPA__c != null) {
                academicMatch = (student.CGPA__c / 10) * 100;
            }

            // Calculate interest match.
            Decimal interestMatch = 0;

            if (student.Career_Interest__c != null &&
                student.Career_Interest__c == opportunity.Career_Interest__c) {
                interestMatch = 100;
            }

            // Check eligibility requirements.
            Boolean eligible = true;
            List<String> reasons = new List<String>();

            if (!opportunity.Is_Active__c) {
                eligible = false;
                reasons.add('Opportunity is inactive.');
            }

            if (opportunity.Application_Deadline__c == null ||
                opportunity.Application_Deadline__c < Date.today()) {
                eligible = false;
                reasons.add('Application deadline has passed or is missing.');
            }

            if (opportunity.Minimum_CGPA__c != null &&
                (student.CGPA__c == null ||
                student.CGPA__c < opportunity.Minimum_CGPA__c)) {
                eligible = false;
                reasons.add('Student does not meet minimum CGPA.');
            }

            if (opportunity.Minimum_Attendance__c != null &&
                (student.Attendance_Percentage__c == null ||
                student.Attendance_Percentage__c <
                    opportunity.Minimum_Attendance__c)) {
                eligible = false;
                reasons.add('Student does not meet minimum attendance.');
            }

            if (!mandatorySkillsMet) {
                eligible = false;
                reasons.add('One or more mandatory skills are missing or below the required proficiency.');
            }

            // Add eligibility result to matching reasons.
            if (eligible) {
                reasons.add('Student meets all eligibility requirements.');
            }

            // Create matching result.
            Matching_Result__c result;

            if (existingResults.containsKey(student.Id)) {
                result = existingResults.get(student.Id);
            } else {
                result = new Matching_Result__c(
                    Student__c = student.Id,
                    Career_Opportunity__c = opportunity.Id
                );
            }

            result.Skill_Match__c =
                skillMatch.setScale(2, RoundingMode.HALF_UP);

            result.Academic_Match__c =
                academicMatch.setScale(2, RoundingMode.HALF_UP);

            result.Interest_Match__c =
                interestMatch.setScale(2, RoundingMode.HALF_UP);

            result.Is_Eligible__c = eligible;
            result.Match_Reason__c = String.join(reasons, ' ');
            result.Calculated_At__c = System.now();

            results.add(result);

        }
        // Save all matching results in one DML operation.
        if (!results.isEmpty()) {
            upsert results;
        }
    }
}