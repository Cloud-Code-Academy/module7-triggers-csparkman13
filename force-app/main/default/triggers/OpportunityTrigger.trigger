trigger OpportunityTrigger on Opportunity (before update, before delete) {
    
    // Q5 Validate that the Amount is greater than 5000 when an Opportunity is updated.
    if (Trigger.isBefore && Trigger.isUpdate) {
        for (Opportunity opp : Trigger.new) {
            Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

            if (opp.Amount != null && opp.Amount <= 5000) {
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }

    // Q6 Cannot delete Closed Won Opportunities for Banking Accounts.
    if (Trigger.isBefore && Trigger.isDelete) {
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.old) {
            if (opp.StageName == 'Closed Won' && opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        Map<Id, Account> accountsById = new Map<Id, Account>();
        if (!accountIds.isEmpty()) {
            accountsById = new Map<Id, Account>([
                SELECT Id, Industry
                FROM Account
                WHERE Id IN :accountIds
                ]);
        }

        for (Opportunity opp : Trigger.old) {
            if (opp.StageName == 'Closed Won') {
                Account relatedAccount = accountsById.get(opp.AccountId);
                if (relatedAccount != null && relatedAccount.Industry == 'Banking') {
                    opp.addError('Cannot delete closed opportunity for a banking account that is won');
                }
            }
        }
    }

    // Q7 Set the Primary Contact on the Opportunity to the Contact on the same Account with the Title of 'CEO' when the Opportunity is updated.
    if (Trigger.isBefore && Trigger.isUpdate) {
        Set<Id> accountIds = new Set<Id>();

        // Gather Account Ids from updated Opptys
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        // Look for Contacts with Title = 'CEO' related to the gathered Accounts
        Map<Id, Contact> accountIdToCeoContact = new Map<Id, Contact>();
        if (!accountIds.isEmpty()) {
            for (Contact c : [
                SELECT Id, Title, AccountId
                FROM Contact
                WHERE AccountId IN :accountIds AND Title = 'CEO'
            ]) {

                // Store the first found CEO Contact per Account
                if (!accountIdToCeoContact.containsKey(c.AccountId)) {
                    accountIdToCeoContact.put(c.AccountId, c);
                }
            }
        }

        // Update each Opportunity's Primary Contact
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null && accountIdToCeoContact.containsKey(opp.AccountId)) {
                opp.Primary_Contact__c = accountIdToCeoContact.get(opp.AccountId).Id;
            }
        }
    }
}
