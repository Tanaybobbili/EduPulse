# EduPulse Data Model

## Core Custom Objects

1. Student__c
2. Academic_Record__c
3. Attendance_Record__c
4. Assessment__c
5. Skill__c
6. Student_Skill__c
7. Mentor__c
8. Mentorship__c
9. Intervention__c
10. Career_Opportunity__c
11. Opportunity_Skill__c
12. Application__c
13. Matching_Result__c
14. Notification_Log__c

## Main Relationships

Student
  -> Academic Records
  -> Attendance Records
  -> Assessments
  -> Student Skills
  -> Mentorships
  -> Interventions
  -> Applications
  -> Matching Results
  -> Notification Logs

Skill
  -> Student Skills
  -> Opportunity Skills

Mentor
  -> Mentorships

Career Opportunity
  -> Opportunity Skills
  -> Applications
  -> Matching Results