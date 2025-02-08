/**
 * @author Nicola Arrigo - narrigo@deloitte.it  
 * @date Creation  06/04/2020 
 * @description XC_IN049_ManageMixedVATBillingBatch_Test – Test class for XC_IN049_ManageMixedVATBillingBatch
 */
@IsTest
public class XC_IN049_ManageMixedVATBillingBatch_Test {
    public static testMethod void manageMixedVATZuoraBatch() {

        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        NE__Order__c order = XC_DF_Order.createOrder('Order');
        System.debug(order.NE__Order_Items__r);
        List < NE__OrderItem__c > ListOrderItem = [select id, NE__BaseOneTimeFee__c, XC_PaymentMethod__c, XC_BillingProfileLineItem__c from NE__OrderItem__c
            where NE__OrderId__c =: order.id
        ];


        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        cat.XC_Mixed_VAT__c = true;
        insert cat;

        List < NE__Product__c > productList = XC_DF_Product.createProducts(1);
        ListOrderItem[0].NE__ProdId__c = productList[0].Id;
        ListOrderItem[0].NE__CatalogItem__c = cat.Id;

        List < Account > accList = [SELECT Id FROM Account WHERE Id =: order.NE__AccountID__c];
        List < XC_Address__c > createAddress = XC_DF_Address.createAddress(accList);
        insert createAddress;

        Zuora__CustomerAccount__c zCA = new Zuora__CustomerAccount__c();
        zCA.Zuora__Account__c = accList[0].id;
        zCa.Zuora__External_Id__c = '123456';
        zCa.Zuora__Zuora_Id__c = '123456';
        insert zCA;

        List < Contact > contactIdList = [select id from contact where AccountId =: order.NE__AccountID__c];
        List < NE__Billing_Profile__c > ListBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        ListBillingProfiles[0].NE__Payment__c = 'Cash';
        update ListBillingProfiles;

        ListOrderItem[0].NE__BaseOneTimeFee__c = 89;
        ListOrderItem[0].XC_PaymentMethod__c = ListBillingProfiles[0].NE__Payment__c;
        List < XC_BillingProfileLineItem__c > ListBPLI = [SELECT Id
            FROM XC_BillingProfileLineItem__c
            WHERE XC_BillingProfile__c =: ListBillingProfiles[0].Id
        ];
        
        ListBPLI[0].XC_LegalEntity__c = 'EndesaX';
        ListBPLI[0].XC_CustomerAccount__c = zCA.ID;
        // system.debug('zuora id'+' '+ListBPLI[0].XC_ZuoraId__c);
        ListBPLI[0].XC_BillToContactId__c = contactIdList[0].id;
        ListBPLI[0].XC_SoldToContactId__c = contactIdList[0].id;
        ListBPLI[0].XC_BillToAddress__c = createAddress[0].id;
        update ListBPLI;
        ListOrderItem[0].XC_BillingProfileLineItem__c = ListBPLI[0].ID;
        update ListOrderItem;


        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ListOrderItem[0].id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;


        List < XC_IN049_ManageMixedVATBillingBatch.InputWrapper > inputWrappList = new List < XC_IN049_ManageMixedVATBillingBatch.InputWrapper > ();
        XC_IN049_ManageMixedVATBillingBatch.InputWrapper inputWrapper = new XC_IN049_ManageMixedVATBillingBatch.InputWrapper();
        inputWrapper.stepId = provisioningStep.id;
        inputWrappList.add(inputWrapper);


        Test.startTest();
        ZuoraWebservice_Mock_TEST mock = new ZuoraWebservice_Mock_TEST();
        Test.setMock(HttpCalloutMock.class, mock);
        XC_IN049_ManageMixedVATBillingBatch.manageMixedVATZuoraBatch(inputWrappList);
        Test.stopTest();
    }

}