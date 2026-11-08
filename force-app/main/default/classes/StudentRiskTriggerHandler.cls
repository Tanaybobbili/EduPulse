public with sharing class StudentRiskTriggerHandler {

    public static void recalculateRisk(Set<Id> studentIds) {

        if (studentIds == null || studentIds.isEmpty()) {
            return;
        }

        System.enqueueJob(
            new StudentRiskQueueable(studentIds)
        );
    }
}