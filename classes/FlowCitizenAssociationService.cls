/**
 * Created by FMARCHEGIA00 on 02/04/2021.
 */

global class FlowCitizenAssociationService {

    @InvocableMethod
    public static void futureUpdateObjectCitizenAssociation(List<Case> cases) {
        system.debug('cases -> '+ cases);
        for ( Case singleCase: cases)
            updateMe(singleCase.Id, singleCase.AccountId, singleCase.ContactId, singleCase.Anonymous_Contact__c);
    }

    @future
    private static void updateMe(Id caseId, String valAccountId, String valContactId, Boolean valAnonymousContact) {

        Case caseToUpdate = [SELECT Id, AccountId, ContactId, Anonymous_Contact__c FROM Case WHERE Id =: caseId];

        caseToUpdate.AccountId = valAccountId;
        caseToUpdate.ContactId = valContactId;
        caseToUpdate.Anonymous_Contact__c = valAnonymousContact;

        Database.SaveResult result =  Database.update(caseToUpdate, false);
        system.debug('result update-> '+ result);

    }
}