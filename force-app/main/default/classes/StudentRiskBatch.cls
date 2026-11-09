
public with sharing class StudentRiskBatch
    implements Database.Batchable<SObject> {

    public Database.QueryLocator start(
        Database.BatchableContext context
    ) {
        return Database.getQueryLocator([
            SELECT Id
            FROM Student__c
        ]);
    }

    public void execute(
        Database.BatchableContext context,
        List<SObject> scope
    ) {
        Set<Id> studentIds = new Set<Id>();

        for (SObject student : scope) {
            studentIds.add((Id) student.get('Id'));
        }

        if (!studentIds.isEmpty()) {
            StudentRiskService.calculateRiskScores(studentIds);
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug(
            'EduPulse risk recalculation batch completed.'
        );
    }
}
