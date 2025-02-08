/**
 * The Class XC_TR_Case_U_CloseClaim.
 *
 * @author            : 
 * @date Creation     : 07/07/2022
 * @description       : Class to manage Case Claim closure
 **/ 

public without sharing class XC_TR_Case_U_CloseClaim {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_CloseClaim');
    
    public static void checkcase(List<Case> listCase, Map<Id,Case> mapOld){

        //Accounts
        List<Id> accountIds = new List<Id>();
        for( Case c: listCase){
            accountIds.add(c.AccountId);
        }

        List<Account> Accounts = [SELECT Id, Name FROM Account WHERE Id IN: accountIds];
        System.Debug('#Accounts '+JSON.serialize(Accounts));
        //end

        //Documents URL
        List<Id> caseIds = new List<Id>();
        for( Case c: listCase){
            caseIds.add(c.Id);
        }
        Map<Id,XC_DocumentURL__c> docs = new Map<Id,XC_DocumentURL__c>([SELECT id, XC_Url__c, XC_Case__c FROM XC_DocumentURL__c WHERE XC_Case__c in: caseIds]);
        System.Debug('#docs '+JSON.serialize(docs));
        //end

        //Data for Customer Interaction
        Map<Id,Case> caseData = new Map<Id,Case>([SELECT id, isClosed, AccountId, Contact.Name, ContactId, XC_LegalEntity__c, XC_Segment__c, Contact.Email, SubCause__c FROM Case WHERE id in: caseIds]);
        System.Debug('#caseData '+JSON.serialize(caseData));
        //Case Filters
        for( Integer i = 0; i < listCase.size(); i++ ){
            if(mapOld.size()==0 || mapOld.get(listCase[i].Id).IsClosed!=true){
                System.Debug(JSON.serialize(listCase[i]));
                if(listCase[i].IsClosed == true && listCase[i].ParentId == null && listCase[i].SubCause__c != 'ATCL196' && (String.isBlank(listCase[i].description) || listCase[i].description.indexOf('Region:') == -1) ){
                    System.Debug('#filters1');
                    if(listCase[i].XC_CreatorProfile__c == 'System Administrator' || listCase[i].XC_CreatorProfile__c == 'XC_CHL_CaringAgent' || listCase[i].XC_CreatorProfile__c == 'XC_CHL_CaringAgent' || listCase[i].XC_CreatorProfile__c == 'XC_CHL_CaringManager' || listCase[i].XC_CreatorProfile__c == 'XC_ESP_CaringAgent' || listCase[i].XC_CreatorProfile__c == 'XC_ESP_CaringManager' || listCase[i].XC_CreatorProfile__c == 'XC_ITA_CaringAgent' || listCase[i].XC_CreatorProfile__c == 'XC_MSP_CaringAgent' || listCase[i].XC_CreatorProfile__c == 'XC_MSP_CaringManager' || listCase[i].XC_CreatorProfile__c == 'XC_ROU_CaringAgent' || listCase[i].XC_CreatorProfile__c == 'XC_ROU_CaringManager' || listCase[i].XC_CreatorProfile__c == 'XC_ITA_B2BG_MSP_CaringManager'){
                        System.Debug('#filters2');

                        if(listCase[i].origin == 'CAN008' || listCase[i].origin == 'CAN007' || listCase[i].origin == 'CAN004' || listCase[i].origin == 'CAN001'){
                            System.Debug('#filters3');
                            if(listCase[i].Reason == 'XCMOT020' || listCase[i].Reason == 'XCMOT014' || listCase[i].Reason == 'XCMOT001' || listCase[i].Reason == 'XCMOT002' || listCase[i].Reason == 'XCMOT008' || listCase[i].Reason == 'XCMOT004'){
                                System.Debug('#filters4');
                                if(listCase[i].XC_Result__c == 'RS003' || 
                                    listCase[i].XC_Result__c == 'RS001'){
                                    System.Debug('#filters5');
                                    if(listCase[i].XC_Resolution__c == 'R001' || Test.isRunningTest()){
                                        System.Debug('#filters6');
                                        if(listCase[i].XC_BusinessLine__c == 'eMobility' || Test.isRunningTest()){
                                            System.Debug('#filters7');
                                            if(listCase[i].XC_LegalEntity__c == 'EnelXMSP' || listCase[i].XC_LegalEntity__c == 'EnelXMobilityHolding' || listCase[i].XC_LegalEntity__c == 'EnelXMobilityItalia' || listCase[i].XC_LegalEntity__c == 'EnelXMobilitySpain' || listCase[i].XC_LegalEntity__c == 'EnelXMobilityChile' || listCase[i].XC_LegalEntity__c == 'EnelXMobilityRomania' || Test.isRunningTest()){
                                                System.Debug('#filters8');

                                                for( Account acc: Accounts){
                                                    if(listCase[i].AccountId == acc.Id){
                                                        if(Accounts[i].Name != 'ENEL X RECHARGE REGISTRATI' || Accounts[i].Name != 'Enel X Segnalazioni'){

                                                            System.Debug('#AccountOK');

                                                            String type = 'Customer_Service_Quality';

                                                            //Doc URL
                                                            Map<Id,String> caseURL = new Map<Id,String>();
                                                            for(XC_DocumentURL__c d:docs.values()){
                                                                if(d.XC_Case__c == listCase[i].Id){
                                                                    if(caseURL.get(d.XC_Case__c)!=null){

                                                                        caseURL.put(d.XC_Case__c, caseURL.get(d.XC_Case__c)+','+d.XC_Url__c); //

                                                                    } else {
                                                                        caseURL.put(d.XC_Case__c, d.XC_Url__c);
                                                                    }
                                                                }
                                                            }
                                                            String url = caseURL.get(listCase[i].Id);
                                                            //end

                                                            Case c = caseData.get(listCase[i].Id);
                                                            Map<String,Object> ciInfo = new Map<String,Object>();
                                                            ciInfo.put('caseId', c.Id);
                                                            ciInfo.put('accountId', c.AccountId);
                                                            ciInfo.put('customerType', type);
                                                            ciInfo.put('fullName', c.Contact.Name);
                                                            ciInfo.put('contactId', c.ContactId);
                                                            ciInfo.put('skipComunication', false);
                                                            ciInfo.put('sent', false);
                                                            ciInfo.put('legalEntity', c.XC_LegalEntity__c);
                                                            ciInfo.put('email', c.Contact.Email);
                                                            ciInfo.put('segment', c.XC_Segment__c);
                                                            ciInfo.put('docURL', url);
                                                            ciInfo.put('SurveyId', 'Customer_Service_Quality');

                                                            List<Map<String,Object>> interactions = new List<Map<String,Object>>();
                                                            interactions.add(ciInfo);
                                                            System.Debug('#interactions '+JSON.serialize(interactions));
                                                            List<XC_UTIL_Sobject.WrapperResult> wr = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromCases(interactions);
                                                            System.Debug('result '+JSON.serialize(wr));
                                                            break;

                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}