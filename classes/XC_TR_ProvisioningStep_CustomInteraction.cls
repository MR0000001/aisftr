public class XC_TR_ProvisioningStep_CustomInteraction {
    
    public static void customerInteractionEndOfProv(Map<Id, XC_Provisioning_Step__c> mapNew, Map<Id, XC_Provisioning_Step__c> mapOld){
        List<Id> confItemToCheck = new List<Id>();
        List<XC_Customer_Interaction__c> listCustomerInteraction = new List<XC_Customer_Interaction__c>();
        for(XC_Provisioning_Step__c step : mapNew.values()){
            if((step.XC_Segment__c == 'B2B' || step.XC_Segment__c == 'B2G') && (step.XC_Status__c == 'Completed OK' || step.XC_Status__c == 'Skipped' ) && (mapOld.get(step.id).XC_Status__c != 'Completed OK' && mapOld.get(step.id).XC_Status__c != 'Skipped')){
                confItemToCheck.add(step.XC_Configuration_Item__c);
            }
        }
        if(confItemToCheck.isEmpty()){
            return;
        }
        Map<Id, NE__OrderItem__c> confItemMap = new Map<id, NE__OrderItem__c>([Select id, NE__Contract__c, NE__OrderId__r.NE__OptyId__c, NE__OrderId__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessLine__c, NE__Account__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__r.Name, NE__OrderId__r.NE__OptyId__r.XC_Contact__r.Email, NE__OrderId__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c, XC_LegalEntity__c, XC_Segment__c, NE__CatalogItem__c, NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name, NE__ProdId__c,NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name, (SELECT id, XC_Status__c from Provisioning_Steps__r ) from NE__OrderItem__c where id IN: confItemToCheck]);

        for(NE__OrderItem__c oi : confItemMap.values()){
            Boolean createCustomerInteraction = true;
            for(XC_Provisioning_Step__c step : oi.Provisioning_Steps__r){
                if(step.XC_Status__c != 'Completed OK' && step.XC_Status__c != 'Skipped'){
                    createCustomerInteraction = false;
                }
            }
            if(createCustomerInteraction){
                //listCustomerInteraction.add(populateCustomerInteraction(oi));
                if(oi.NE__CatalogItem__c != null && oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__c != null && oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name =='Customer Insights'){
                    XC_Customer_Interaction__c survey = populateCustomerInteraction(oi);
                    survey.XC_Communication_Type__c = 'Survey_Onboarding';
                    survey.XC_SurveyId__c = 'Survey_Onboarding';
                    listCustomerInteraction.add(survey);
                }
            }
            
        }
        XC_UTIL_DML.insertRecords(listCustomerInteraction);
    }
	
    @TestVisible
    private static XC_Customer_Interaction__c populateCustomerInteraction(NE__OrderItem__c oi){
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.XC_OpportunityId__c = oi.NE__OrderId__r.NE__OptyId__c;
        ci.XC_OrderId__c = oi.NE__OrderId__c;
        ci.XC_ContactId__c = oi.NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
        ci.XC_AccountId__c = oi.NE__Account__c;
        ci.XC_ContractId__c = oi.NE__Contract__c;
        ci.XC_Recipient__c = oi.NE__OrderId__r.NE__OptyId__r.XC_Contact__r.Name;
        ci.XC_Email__c = oi.NE__OrderId__r.NE__OptyId__r.XC_Contact__r.email;
        ci.XC_Preferredlanguageofcontact__c = oi.NE__OrderId__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c;
        ci.XC_Channel__c = 'Email';
        ci.XC_Communication_Type__c = 'End_Provisioning';
        ci.XC_LegalEntity__c = oi.XC_LegalEntity__c;
        ci.XC_Segment__c = oi.XC_Segment__c;
        ci.XC_BusinessLine__c=oi.NE__OrderId__r.NE__OptyId__r.XC_BusinessLine__c;
        ci.XC_ProductId__c = oi.NE__ProdId__c;
        return ci;
    }
}