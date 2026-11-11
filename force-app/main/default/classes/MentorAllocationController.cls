public with sharing class MentorAllocationController {

    // Fetch active students.
    @AuraEnabled(cacheable=true)
    public static List<Student__c> getStudents() {

        return [
            SELECT Id, Name, First_Name__c, Last_Name__c,
                   Department__c, CGPA__c, Risk_Category__c
            FROM Student__c
            WHERE Is_Active__c = true
            ORDER BY First_Name__c, Last_Name__c
            LIMIT 200
        ];
    }

    // Fetch available mentors with remaining capacity.
    @AuraEnabled(cacheable=true)
    public static List<Mentor__c> getAvailableMentors() {

        List<Mentor__c> mentors = [
            SELECT Id, Mentor_Name__c, Email__c,
                Department__c, Expertise__c,
                Maximum_Capacity__c, Current_Mentees__c,
                Availability__c
            FROM Mentor__c
            WHERE Is_Active__c = true
            AND Availability__c = 'Available'
            ORDER BY Current_Mentees__c ASC
            LIMIT 200
        ];

        List<Mentor__c> availableMentors = new List<Mentor__c>();

        for (Mentor__c mentor : mentors) {

            Decimal currentCount = mentor.Current_Mentees__c == null
                ? 0 : mentor.Current_Mentees__c;

            Decimal maxCapacity = mentor.Maximum_Capacity__c == null
                ? 0 : mentor.Maximum_Capacity__c;

            if (currentCount < maxCapacity) {
                availableMentors.add(mentor);
            }
        }

        return availableMentors;
    }


    // Assign a mentor to a student.
    @AuraEnabled
    public static Mentorship__c assignMentor(
        Id studentId,
        Id mentorId
    ) {

        if (studentId == null || mentorId == null) {
            throw new AuraHandledException(
                'Please select both a student and a mentor.'
            );
        }

        try {

            // Lock the mentor record to prevent concurrent over-allocation.
            Mentor__c mentor = [
                SELECT Id, Mentor_Name__c, Is_Active__c,
                       Availability__c, Maximum_Capacity__c,
                       Current_Mentees__c
                FROM Mentor__c
                WHERE Id = :mentorId
                LIMIT 1
                FOR UPDATE
            ];

            // Validate student.
            List<Student__c> students = [
                SELECT Id, Is_Active__c
                FROM Student__c
                WHERE Id = :studentId
                LIMIT 1
            ];

            if (students.isEmpty() || !students[0].Is_Active__c) {
                throw new AuraHandledException(
                    'The selected student is unavailable or inactive.'
                );
            }

            // Validate mentor.
            if (!mentor.Is_Active__c ||
                mentor.Availability__c != 'Available') {

                throw new AuraHandledException(
                    'The selected mentor is not available.'
                );
            }

            // Check for an existing pending or active mentorship.
            List<Mentorship__c> existingMentorships = [
                SELECT Id
                FROM Mentorship__c
                WHERE Student__c = :studentId
                AND Status__c IN ('Pending', 'Active')
                LIMIT 1
            ];

            if (!existingMentorships.isEmpty()) {
                throw new AuraHandledException(
                    'This student already has a pending or active mentorship.'
                );
            }

            // Count actual active mentorship assignments.
            Integer activeCount = [
                SELECT COUNT()
                FROM Mentorship__c
                WHERE Mentor__c = :mentorId
                AND Status__c = 'Active'
            ];

            Integer maximumCapacity =
                mentor.Maximum_Capacity__c == null
                ? 0
                : mentor.Maximum_Capacity__c.intValue();

            if (activeCount >= maximumCapacity) {
                throw new AuraHandledException(
                    'The selected mentor has reached maximum capacity.'
                );
            }

            // Create mentorship.
            Mentorship__c mentorship = new Mentorship__c(
                Student__c = studentId,
                Mentor__c = mentorId,
                Start_Date__c = Date.today(),
                Status__c = 'Active',
                Notes__c = 'Assigned through EduPulse Mentor Allocation.'
            );

            insert mentorship;

            // Synchronize the mentor's active mentee count.
            mentor.Current_Mentees__c = activeCount + 1;
            update mentor;

            return [
                SELECT Id, Name, Student__c, Mentor__c,
                       Start_Date__c, Status__c
                FROM Mentorship__c
                WHERE Id = :mentorship.Id
            ];

        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(
                'Mentor assignment failed: ' + e.getMessage()
            );
        }
    }
}