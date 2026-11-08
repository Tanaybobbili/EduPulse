trigger AttendanceRecordTrigger on Attendance_Record__c (
    after insert,
    after update,
    after delete,
    after undelete
) {

    Set<Id> studentIds = new Set<Id>();

    // Handle newly inserted or restored records.
    if (Trigger.isInsert || Trigger.isUndelete) {

        for (Attendance_Record__c record : Trigger.new) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }
    }

    // Handle updated records.
    if (Trigger.isUpdate) {

        for (Attendance_Record__c record : Trigger.new) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }

        // Include the previous parent if the relationship changed.
        for (Attendance_Record__c record : Trigger.old) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }
    }

    // Handle deleted records.
    if (Trigger.isDelete) {

        for (Attendance_Record__c record : Trigger.old) {

            if (record.Student__c != null) {
                studentIds.add(record.Student__c);
            }
        }
    }

    StudentRiskTriggerHandler.recalculateRisk(studentIds);
}