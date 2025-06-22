trigger AccountTrigger on Account (before insert, after insert) {

    // BEFORE INSERT
    if (Trigger.isBefore) {
        for (Account acc : Trigger.new) {
            // Q1 Set Type to 'Prospect' if blank.
            if (String.isBlank(acc.Type)) {
                acc.Type = 'Prospect';
            }

            // Q2 Copy Shipping Address to Billing Address if Shipping Address has values.
            Boolean hasShipping = 
                !String.isBlank(acc.ShippingStreet) ||
                !String.isBlank(acc.ShippingCity) ||
                !String.isBlank(acc.ShippingState) ||
                !String.isBlank(acc.ShippingPostalCode) ||
                !String.isBlank(acc.ShippingCountry);

            if (hasShipping) {
                acc.BillingStreet = acc.ShippingStreet;
                acc.BillingCity = acc.ShippingCity;
                acc.BillingState = acc.ShippingState;
                acc.BillingPostalCode = acc.ShippingPostalCode;
                acc.BillingCountry = acc.ShippingCountry;
            }

            // Q3 Set Rating to 'Hot' if Phone, Website, and Fax all have values.
            Boolean hasFields =
                !String.isBlank(acc.Phone) &&
                !String.isBlank(acc.Website) &&
                !String.isBlank(acc.Fax);

            if (hasFields) {
                acc.Rating = 'Hot';
            }
        }
    }

    // AFTER INSERT
    if (Trigger.isAfter && Trigger.isInsert) {
        // Q4 Create a Contact related to the inserted Account.
        List<Contact> contactsToInsert = new List<Contact>();
        for (Account insertedAcc : Trigger.new) {
            contactsToInsert.add(new Contact(
                LastName = 'DefaultContact',
                Email = 'default@email.com',
                AccountId = insertedAcc.Id
                ));
        }
        insert contactsToInsert;
    }
}
