trigger StudentSkillTrigger on Student_Skill__c (
    after insert,
    after update,
    after delete,
    after undelete
) {

    Set<Id> studentIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUndelete) {

        for (Student_Skill__c record : Trigger.new) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }
    }

    if (Trigger.isUpdate) {

        for (Student_Skill__c record : Trigger.new) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }

        for (Student_Skill__c record : Trigger.old) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }
    }

    if (Trigger.isDelete) {

        for (Student_Skill__c record : Trigger.old) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }
    }

    StudentRiskTriggerHandler.recalculateRisk(studentIds);
}