
public with sharing class StudentRiskScheduler
    implements Schedulable {

    // Executes automatically at the scheduled time.
    public void execute(SchedulableContext context) {

        // Launch the batch to recalculate student risk scores.
        Database.executeBatch(
            new StudentRiskBatch(),
            200
        );
    }
}
