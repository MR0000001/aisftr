public without sharing class XC_TR_Case_MalfunctioningNotification {

    public static void checkCaseAndUpdateCustomerInteraction(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew){

        //set that is used to query related Accounts
        Set<Id> caseAccountSet = new Set<Id>();

        //list that tracks filtered cases
        List<Case> caseList = new List<Case>();

        List<Case> listStatusChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'Status', 'XC_automaticClosure__c'}, mapOld, mapNew);

        for(Case c : listStatusChanged){
            caseAccountSet.add(c.AccountId);
        }

        //account map holding the account names
        Map<Id,Account> caseRelatedAccountMap = new Map<Id,Account>([SELECT id,Name FROM Account WHERE Id IN : caseAccountSet]);

        for(Case c : listStatusChanged){

            String accountName = caseRelatedAccountMap.get(c.AccountId).Name;

            if((c.XC_Segment__c == 'B2B' || c.XC_Segment__c == 'B2G') &&
                c.Reason == 'XCMOT002' &&
                c.SubCause__c == 'ATCL003' &&
                c.XC_Subtype__c == 'XC199' &&
                ((c.Status == 'ESTA007' &&
                c.XC_Resolution__c == 'R001' )|| c.XC_automaticClosure__c)  &&
                c.XC_BusinessLine__c == 'eCity' &&
                //CR 733 22-06-22 VDB ADD origin!=can028
                c.Origin != 'CAN013' && c.Origin != 'CAN028' &&
                c.XC_DefectType__c != 'Incidente Stradale' &&
                c.CreatedDate > Date.Today().addDays(-30) &&
                accountName != 'Enel X S.r.l.' &&
                accountName != 'Enel X segnalazioni' &&
                accountName != 'Comune di Sole 2.0' &&
                accountName != 'Capparex' 
                ){
                    caseList.add(c);
                    System.debug('Malfunction Notification added case: ' + c.Id);
                }
        }

        if(caseList.size()>0){

            List<XC_Customer_Interaction__c> customerInteractionToInsert = new List<XC_Customer_Interaction__c>();

            for(Case c : caseList){

                //populate customer interaction fields from case values
                XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c(XC_Segment__c = c.XC_Segment__c,
                                                                                XC_LegalEntity__c = c.XC_LegalEntity__c,
                                                                                XC_AssetId__c = !String.isBlank(c.XC_TechnicalAsset__c) ? c.XC_TechnicalAsset__c : null,
                                                                                XC_CaseId__c = c.Id,
                                                                                XC_AccountId__c = c.AccountId,
                                                                                XC_Preferredlanguageofcontact__c  = 'Italian',
                                                                                XC_Channel__c = 'Email');

                //email population logic
                if(c.Origin == 'CAN004'){
                    if(String.isBlank(c.XC_SuppliedEmail__c) && String.isBlank(c.ContactEmail)){
                        continue;
                    }
                    else{
                        ci.XC_Email__c = c.XC_SuppliedEmail__c != null? c.XC_SuppliedEmail__c : c.ContactEmail;
                    } 
                }
                else{
                    if(String.isBlank(c.XC_Email__c) && String.isBlank(c.XC_SuppliedEmail__c) && String.isBlank(c.XC_ContactEmail__c)){
                        continue;
                    }
                    else{
                        ci.XC_Email__c = c.XC_SuppliedEmail__c != null? c.XC_SuppliedEmail__c : (c.XC_Email__c != null  ? c.XC_Email__c : (c.XC_ContactEmail__c));
                    }
                }

                //communication type population logic
                if(c.XC_CallerType__c != 'Cittadino' && c.XC_CallerType__c != 'Comune'){
                   continue;
                }
                else{
                    ci.XC_Communication_Type__c = c.XC_CallerType__c == 'Cittadino' ? 'Case_Closed_Citizen' : 'Case_Closed_Municipality';
                }

                customerInteractionToInsert.add(ci);
            }

            System.debug('Malfunction Notification customer interaction size: ' + customerInteractionToInsert.size());
            if(customerInteractionToInsert.size()>0){
                XC_UTIL_DML.insertRecords(customerInteractionToInsert);
            }
        }
    }
}