/*
 * NextStepQueueable Class Description:
 * 
 * Implement the Queueable interface to process records asynchronously.
 * This example processes up to 10 accounts at a time.
 * It removes the Next Step from the accounts and related opportunities.
 *  
 * Benefits of using Queueable methods:
 * 
 * 1. Chaining Jobs: Allows for the chaining of jobs, meaning you can add another job to the queue from a running job.
 * 2. Stateful Execution: Supports stateful execution, which allows member variables to retain their values between job invocations.
 * 3. High Concurrency: Processes large sets of data without hitting governor limits.
 * 4. Flexibility: Useful for operations that need more flexibility in execution, especially when there's a possibility of chaining or performing related async operations.
 * 5. Enhanced Integration Capabilities: Useful for making asynchronous callouts to external systems, allowing for more extended processing times.
 * 
 * For more detailed information, refer to the official Salesforce documentation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_queueing_jobs.htm
 * 
 * Note: The class below contains placeholders for implementing a queueable job to update accounts and opportunities.
 */
public with sharing class NextStepQueueable implements Queueable {

    // Member variable to store the accounts
    private Map<Id,Account> accounts;

    // Constructor to accept the accounts
    public NextStepQueueable(Map<Id,Account> accounts) {
        // Store the accounts in a member variable
        this.accounts = accounts;
    }

    // Method to queue the job
    public static void enqueueJob() {
        // Get 10 accounts with Next Step populated
        // If there are any accounts, queue the job using System.enqueueJob
        // Tried with Sets, but had illegals assignments from List to Set - used Maps as there would be no assignment issue that way
        Map<Id,Account> accMapEnqueue = new Map<Id,Account>([
            SELECT Id, Next_Step__c
            FROM Account
            WHERE Next_Step__c != null
            LIMIT 10
        ]);

        if(!accMapEnqueue.isEmpty()) {
            System.enqueueJob(new NextStepQueueable(accMapEnqueue));
        }

    }

    /*
     * Update/Uncomment the template code to create a method
     * Method to execute the queueable job
     */
    //[public | private ] [static] data_type execute (input parameters) {
        // Get the accounts from the member variable

            // Remove the Next Step using the helper method

        // Update the accounts

        // Get the opportunities related to the accounts

            // Remove the Next Step using the helper method

        // Update the opportunities

        // Call the enqueueJob method to queue another job to process more records.
    //}

    public void execute(QueueableContext context) {
        Map<Id,Account> accountMap = new Map<Id,Account>();
        /* 
        ** using this.accounts as that was instantiated via the constructor and can be used throughout the class 
        ** (only in non-static methods).
        */
        accountMap.putAll(this.accounts); 

        /*
        ** unsure if I need the guard clause below (think it's handled in enqueueJob method), but better safe than sorry
        */
        if(accountMap != null || !accountMap.isEmpty()) {
            for(Account a : accountMap.values()) {
                removeNextStep(a);
            }
        }

        update accountMap.values();

        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([
            SELECT Id, NextStep
            FROM Opportunity
            WHERE AccountId IN :accountMap.keySet()
        ]);

        /*
        ** using guard clause here due to potential of Accounts not having related Opps
        */
        if(oppMap != null || !oppMap.isEmpty()) {
            for(Opportunity o : oppMap.values()) {
                removeNextStep(o);
            }
        }

        update oppMap.values();
    }

    // Helper method to remove the Next Step
    // Overloaded method to accept an opportunity
    private static void removeNextStep(Opportunity opp) {
        opp.NextStep = null;
    }

    // Helper method to remove the Next Step
    // Overloaded method to accept an account
    private static void removeNextStep(Account acc) {
        acc.Next_Step__c = null;
    }
}