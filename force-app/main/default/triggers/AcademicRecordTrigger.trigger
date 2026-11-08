trigger AcademicRecordTrigger on Academic_Record__c (
    after insert,
    after update,
    after delete,
    after undelete
) {

    Set<Id> studentIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUndelete) {

        for (Academic_Record__c record : Trigger.new) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }
    }

    if (Trigger.isUpdate) {

        for (Academic_Record__c record : Trigger.new) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }

        for (Academic_Record__c record : Trigger.old) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }
    }

    if (Trigger.isDelete) {

        for (Academic_Record__c record : Trigger.old) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }
    }

    StudentRiskTriggerHandler.recalculateRisk(studentIds);
}