trigger AssessmentTrigger on Assessment__c (
    after insert,
    after update,
    after delete,
    after undelete
) {

    Set<Id> studentIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUndelete) {

        for (Assessment__c record : Trigger.new) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }
    }

    if (Trigger.isUpdate) {

        for (Assessment__c record : Trigger.new) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }

        for (Assessment__c record : Trigger.old) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }
    }

    if (Trigger.isDelete) {

        for (Assessment__c record : Trigger.old) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }
    }

    StudentRiskTriggerHandler.recalculateRisk(studentIds);
}