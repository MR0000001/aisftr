/**
* @File Name          : XC_IN090_CheckDuplicateBillingAccount.cls
* @Description        :
* @Author             : Gaurav Tejpal - gaurav.tejpal@accenture.com
* @Group              :
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 17-06-2022
* @Modification Log   :
* Ver       Date            Author           Modification
* 1.0    03/05/2021   Gaurav Tejpal - gaurav.tejpal@accenture.com     Initial Version
**/

public without sharing class XC_IN090_CheckDuplicateBillingAccount{

    public class InputWrapper {
        @InvocableVariable
        public String stepId;
        @InvocableVariable
        public String orderId;
        @InvocableVariable
        public String bplId;
    }
    //@InvocableMethod
    // public static void executeCheckDuplicateRequest(List<InputWrapper> inputs){
    //     System.enqueueJob(new executeCheckDuplicateRequest(inputs));
    // }
    // public class executeCheckDuplicateRequest implements Queueable, Database.AllowsCallouts{

    //     private List<InputWrapper> inputs;

    //     public executeCheckDuplicateRequest(List<InputWrapper> inputs){
    //         this.inputs = inputs;
    //     }

    //     public void execute(QueueableContext qc) {
    //         manageCheckDuplicateRequest(inputs);
    //     }
    // }
    
    /**
     * @author Gaurav Tejpal - gaurav.tejpal@accenture.com
     * @description Method to prepare Account For Zuora
     * @param accountId
     * @return Account
     */
    private static Account prepareAccountForZuora(String accountId){
        Id accId = Id.valueOf(accountId);
        String sObjName = accId.getSObjectType().getDescribe().getName();
        If(sObjName == 'NE__Billing_Profile__c'){
            NE__Billing_Profile__c billingProf = [SELECT Id, NE__Account__c FROM NE__Billing_Profile__c WHERE Id =: accountId LIMIT 1];
            accountId = billingProf.NE__Account__c;
        }
        String fields = ZuoraWebserviceUtil.generateFieldsToQueryFromFieldSet('zqu__CustomAccountFields','Account');
        return (Account)Database.query('SELECT id,PrimaryEmail__c,XC_FirstName__c,XC_LastName__c, Name, XC_Segment__c, XC_SectorOfTheCompany__c, XC_Giro__c, XC_EnelXSupply__c , XC_TipoDeRegimen__c, XC_ObligacionesDelContribuyente__c, IdentityNumber__c, CurrencyIsoCode, XC_Country__c, XC_SohoType__c, XC_TradingPartner__c, XC_VatGroupType__c, XC_CompanyFiscalCode__c, XC_IdentityNumber2__c, XC_DocumentType2__c, XC_BillingAgency__c, XC_BillingAgency__r.Name '+fields+' FROM Account where Id=:accountId')[0];
        
        //return [SELECT id, Name, CurrencyIsoCode, Country__c FROM Account where Id=:accountId][0];
    }

    /**
     * @author Gaurav Tejpal - gaurav.tejpal@accenture.com
     * @date 20/06/2022 
     * @description Method to rollback if Zuora fails
     * @param billingProfLineItemId - String
     * @param message - String
     * @param doRollback - Boolean
     **/
    @TestVisible
    private static void rollbackForError(String billingProfLineItemId, String message, Boolean doRollback) {
        rollbackForError(billingProfLineItemId, message, doRollback, false);
    }

    /**
     * @author Gaurav Tejpal - gaurav.tejpal@accenture.com
     * @date 20/06/2022 
     * @description Method to rollback if Zuora fails
     * @param billingProfLineItemId - String
     * @param message - String
     * @param doRollback - Boolean
    **/
    @TestVisible
    private static void rollbackForError(String billingProfLineItemId, String message, Boolean doRollback, Boolean fromBillingProfile) {
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Rollback for Zuora error');
        XC_UTIL_DependentPicklist.PicklistWrapper pw = XC_UTIL_DependentPicklist.getDependentPicklist('NE__Billing_Profile__c', 'NE__Payment__c', 'XC_PaymentMethodCategory__c');
        List<String> listPaymentExternal = new List<String>();
        for(String key : pw.pickListMap.keySet()) {
            List<String> listPaymentMethod = pw.pickListMap.get(key);
            for(String mp : listPaymentMethod) {
                if(mp == Label.XC_CL_PaymentType_External) {
                    listPaymentExternal.add(key);
                }
            }
        }
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPaymentExternal: ' + listPaymentExternal);
        if(listPaymentExternal.isEmpty()) {
            return;
        }
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPaymentExternal -> ' + listPaymentExternal);

        List<XC_BillingProfileLineItem__c> listBillingProfile = new List<XC_BillingProfileLineItem__c>([
            SELECT Id, XC_BillingProfile__c, XC_PaymentMethod__c 
            FROM XC_BillingProfileLineItem__c 
            WHERE Id = :billingProfLineItemId
        ]);
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listBillingProfile  -> ' + listBillingProfile );
        if(listBillingProfile.isEmpty()) {
            return;
        }
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listBillingProfile -> ' + listBillingProfile);

        List<XC_BillingProfileLineItem__c> listBplToUpdate = new List<XC_BillingProfileLineItem__c>();
        List<XC_BillingProfileLineItem__c> listBplToDelete = new List<XC_BillingProfileLineItem__c>();
        List<NE__Billing_Profile__c> listBillingProfileToDelete = new List<NE__Billing_Profile__c>();
        for(XC_BillingProfileLineItem__c bp : listBillingProfile) {
            // For external method:
            if(listPaymentExternal.contains(bp.XC_PaymentMethod__c) && doRollback && !fromBillingProfile) {
                listBplToDelete.add(new XC_BillingProfileLineItem__c(Id = bp.Id));
                listBillingProfileToDelete.add(new NE__Billing_Profile__c(Id = bp.XC_BillingProfile__c));
            } else if(listPaymentExternal.contains(bp.XC_PaymentMethod__c) && doRollback && fromBillingProfile) {
                listBplToDelete.add(new XC_BillingProfileLineItem__c(Id = bp.Id));
            }
            // For other method:
            else {
                listBplToUpdate.add(new XC_BillingProfileLineItem__c(
                    Id = bp.Id,
                    XC_Status__c = Label.XC_CL_ZuoraInvoiceDraft,
                    XC_ErrorLastCallout__c = message
                ));
            }
        }
        XC_UTIL_Sobject.updateListRecords(listBplToUpdate);
        XC_UTIL_Sobject.deleteListRecords(listBplToDelete);
        XC_UTIL_Sobject.deleteListRecords(listBillingProfileToDelete);
       
    }
    @InvocableMethod
    public static void manageCheckDuplicateRequest(List<InputWrapper> inputs){
        if(inputs!=null && inputs.size()>0)
        {
                string orderItemId=inputs[0].orderId;
                List<XC_BillingProfileLineItem__c> billingProfieLineItemC=[select id,XC_BillingProfile__c, XC_SoldToAddress__c, XC_BillToAddress__c, XC_BillToContactId__c, XC_Account__c,XC_LegalEntity__c, XC_PaymentMethod__c,XC_InvoiceDeliveryPreference__c,XC_PaymentTerm__c,XC_DocumentType__c, XC_DocumentNumber__c , XC_CommodityContract__c, XC_Segment__c from XC_BillingProfileLineItem__c where id=:inputs[0].bplId];
                List<XC_BillingProfileLineItem__c> billingProfieLineItemExists=[select id from XC_BillingProfileLineItem__c where XC_Account__c=:billingProfieLineItemC[0].XC_Account__c and XC_LegalEntity__c='EXBRA_SA_Goncalo_RJ' and XC_PaymentMethod__c=:billingProfieLineItemC[0].XC_PaymentMethod__c];
                List<Asset> asset=[Select id,XC_BillingProfileLineItem__c from Asset where XC_Configuration_Item__c=:orderItemId];
                NE__OrderItem__c orderItem=new NE__OrderItem__c();
                orderItem.Id=orderItemId;

                if(billingProfieLineItemExists!=null && billingProfieLineItemExists.size()>0)
                {
                    orderItem.XC_BillingProfileLineItem__c=billingProfieLineItemExists[0].id;
                    update orderItem;
                    if(asset.isEmpty()){
                        asset[0].XC_BillingProfileLineItem__c= orderItem.XC_BillingProfileLineItem__c;
                        update asset;
                    }
                    XC_Provisioning_Step__c provStep = new XC_Provisioning_Step__c(Id = inputs[0].stepId);
                    provStep.XC_Status__c = Label.XC_CL_Completed_Ok;
                    XC_UTIL_Sobject.updateRecord(provStep);
                }
                else {
                    string accountId=(billingProfieLineItemC!=null && billingProfieLineItemC.size()>0)?billingProfieLineItemC[0].XC_Account__c:null;
                    XC_BillingProfileLineItem__c billingProfieLineItemClone=billingProfieLineItemC[0].clone(false,true,false);
                    billingProfieLineItemClone.XC_LegalEntity__c='EXBRA_SA_Goncalo_RJ'; 
                    billingProfieLineItemClone.XC_Status__c='Sent To Zuora';
                   // billingProfieLineItemClone.XC_BillingProfile__c=billingProfieLineItemC.XC_BillingProfile__c;
                    insert billingProfieLineItemClone;
                    
                    if(billingProfieLineItemClone!=null)
                    {
                        orderItem.XC_BillingProfileLineItem__c=billingProfieLineItemClone.id;
                        update orderItem;
                    }
                    
                    if(asset!=null && asset.size()>0)
                    {
                        asset[0].XC_BillingProfileLineItem__c= orderItem.XC_BillingProfileLineItem__c;
                        update asset;

                    }

                    string zuoraSequenceSetId;
                    List<XC_CM_LegalEntity_Configuration__mdt> legalInfoList=XC_CM_LegalEntity_Configuration__mdt.getall().values();
                    if(legalInfoList!=null && legalInfoList.size()>0)
                    {
                        for(XC_CM_LegalEntity_Configuration__mdt legalConfiguration:legalInfoList )
                        {
                        if(legalConfiguration.XC_Stream__c==billingProfieLineItemClone.XC_Segment__c && legalConfiguration.XC_LegalEntity__c==billingProfieLineItemClone.XC_LegalEntity__c)
                            {
                                zuoraSequenceSetId=legalConfiguration.XC_ZuoraSequenceSetId__c;
                                break;
                            }

                        }
                    }
                    List<Account> account=[Select id ,XC_SplitPayment__c,RecordType.Name from Account where Id=: accountId];
                    ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper billTo=new ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper();
                    ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper soldTo=new ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper();
                    Account salesforceAccount=new Account();
                    if(string.isNotBlank(accountId))
                    {
                         salesforceAccount=prepareAccountForZuora(accountId);
                    }
                    if(!Test.isRunningTest())
                    {
                        if(billingProfieLineItemClone.XC_BillToAddress__c == billingProfieLineItemClone.XC_SoldToAddress__c){
                            billTo=ZuoraBillingProfileCreationController.prepareContactForZuora(billingProfieLineItemClone.XC_BillToContactId__c ,billingProfieLineItemClone.XC_BillToAddress__c,billingProfieLineItemClone.XC_LegalEntity__c);
                            soldTo=billTo;
                        }
                        else {
                            billTo=ZuoraBillingProfileCreationController.prepareContactForZuora(billingProfieLineItemClone.XC_BillToContactId__c ,billingProfieLineItemClone.XC_BillToAddress__c,billingProfieLineItemClone.XC_LegalEntity__c);
                            soldTo=ZuoraBillingProfileCreationController.prepareContactForZuora(billingProfieLineItemClone.XC_BillToContactId__c ,billingProfieLineItemClone.XC_SoldToAddress__c,billingProfieLineItemClone.XC_LegalEntity__c);
                        }
                    }
                    Map<String,Object> options =new Map<String,Object>{ 'invoiceDeliveryPrefsEmail' =>(String.isBlank(billingProfieLineItemClone.XC_InvoiceDeliveryPreference__c) && billingProfieLineItemClone.XC_InvoiceDeliveryPreference__c=='Email' ) ? true: false,
                                                                        'invoiceDeliveryPrefsPrint'=> (String.isBlank(billingProfieLineItemClone.XC_InvoiceDeliveryPreference__c) && billingProfieLineItemClone.XC_InvoiceDeliveryPreference__c=='Print' ) ? true: false,
                                                                        'paymentTerm' => (String.isBlank(billingProfieLineItemClone.XC_PaymentTerm__c)) ? '': billingProfieLineItemClone.XC_PaymentTerm__c,
                                                                        //'paymentGateway' => (String.isBlank(billingProfieLineItemClone.XC_PaymentMethod__c)) ?  '': billingProfieLineItemClone.XC_PaymentMethod__c,
                                                                        'XC_SplitPayment__c' => (account!=null && account.size()>0 && account[0].XC_SplitPayment__c==null) ? 'No' : 'Yes'
                    };
                    Map<String,Object>  zuoraPayment = new Map<String,Object>{  'bpId' =>billingProfieLineItemC[0].XC_Account__c,
                                                                                'language'=> 'PT-BR',
                                                                                'docNif' => (String.isBlank(billingProfieLineItemClone.XC_DocumentType__c)) ? '': billingProfieLineItemClone.XC_DocumentType__c,
                                                                                'docNumber' => (String.isBlank(billingProfieLineItemClone.XC_DocumentNumber__c)) ? '': billingProfieLineItemClone.XC_DocumentNumber__c,
                                                                                'personTypeCode' => (account!=null && account.size()>0 && account[0].RecordType.Name == 'XC_GLO_Account_Residential') ? 'F' : 'J',
                                                                                'docCountry' => 'BR',
                                                                                'legalE'=>billingProfieLineItemClone.XC_LegalEntity__c,
                                                                                'contractId'=>billingProfieLineItemClone.XC_CommodityContract__c,
                                                                                'zuoraSequenceSetId' => (String.isNotBlank(zuoraSequenceSetId)) ? zuoraSequenceSetId : null
                    };  
                   
                    String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(billingProfieLineItemClone.XC_LegalEntity__c,billingProfieLineItemClone.XC_Segment__c);
                    if(!string.isBlank(entityName))
                    {
                        zuoraBillingAccountCreation(entityName,JSON.serialize(salesforceAccount),JSON.serialize(billTo),JSON.serialize(soldTo),JSON.serialize(options),billingProfieLineItemClone.id,JSON.serialize(zuoraPayment),inputs[0].stepId);
                    }
                }
            }
    }

    /**
     * @author Gaurav Tejpal - gaurav.tejpal@accenture.com
     * @description Method to create Billing account 
     * @param  entityName, account, billTo, soldTo, options, billingProfileLineItemId, zuoraPayment,stepId
     * @return void
    **/
    @Future(callout=true)
    public static void zuoraBillingAccountCreation(string entityName,string account,string billTo,string soldTo,string options,string billingProfileLineItemId,string zuoraPayment ,string stepId)
    {
    try 
    {         
        Account salesforceAccount=(Account)JSON.deserialize(account,Account.class);
        ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper billToContact=(ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper)JSON.deserialize(billTo,ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper.class);
        ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper soldToContact=(ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper)JSON.deserialize(soldTo,ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper.class);   
        ZuoraWebservice zws=new ZuoraWebservice(entityName);
        ZuoraWebservice.CreateZuoraAccountResponse resp=zws.createUnlinkedZuoraAccount(salesforceAccount,(billToContact!=null?billToContact.c:null),(soldToContact!=null?soldToContact.c:null),options,billingProfileLineItemId,zuoraPayment);
        List<XC_Integration_Log__c> intLogGetContract= new List<XC_Integration_Log__c>();
        intLogGetContract.add(resp.integrationLog);
        if(intLogGetContract != null && !intLogGetContract.isEmpty()){
            insert intLogGetContract; 
        }
        if(resp.success.toLowerCase() != 'true') {
            rollbackForError(billingProfileLineItemId, resp.reasons[0].code + ' - ' + resp.reasons[0].message, false,false);
            XC_Provisioning_Step__c provStep = new XC_Provisioning_Step__c(Id = stepId);
            provStep.XC_ErrorMessage__c= 'Error while creating billing account';
            provStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            XC_UTIL_Sobject.updateRecord(provStep);
        }
        else {
            XC_Provisioning_Step__c provStep = new XC_Provisioning_Step__c(Id = stepId);
            provStep.XC_Status__c = Label.XC_CL_Completed_Ok;
            XC_UTIL_Sobject.updateRecord(provStep);
        }
    } 
    catch (Exception ex) {
        rollbackForError(billingProfileLineItemId, null, false,false);
        XC_Provisioning_Step__c provStep = new XC_Provisioning_Step__c(Id = stepId);
        provStep.XC_ErrorMessage__c= ex.getMessage();
        provStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
        XC_UTIL_Sobject.updateRecord(provStep);  
    }
    }

}