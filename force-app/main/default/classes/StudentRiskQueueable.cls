public with sharing class StudentRiskQueueable implements Queueable {

    private Set<Id> studentIds;

    // Constructor receives the affected student IDs.
    public StudentRiskQueueable(Set<Id> studentIds) {
        this.studentIds = studentIds;
    }

    // Executes asynchronously.
    public void execute(QueueableContext context) {

        if (studentIds == null || studentIds.isEmpty()) {
            return;
        }

        StudentRiskService.calculateRiskScores(studentIds);
    }
}