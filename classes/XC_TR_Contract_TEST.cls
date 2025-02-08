@isTest
private class XC_TR_Contract_TEST {

@isTest
    static void onInsertDeleteUpdateContract() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Contract> listOfContract = XC_DF_Contract.createContracts(1);
        for(Contract c: listOfContract) {
            c.XC_LegalEntity__c='EndesaX';
        }
        insert listOfContract;
        System.assertNotEquals(listOfContract, null);
        listOfContract[0].Status='Cancelled';
        update listOfContract;
        delete listOfContract;
        Test.stopTest();
    }

}