public class XC_TR_Asset_U_CustomerInteraction {

    public static void manageCustomerInteraction(Map<Id, Asset> mapNew, Map<Id, Asset> mapOld){
        List<Id> assetForCustomerInteraction = new List<id>();
        List<Asset> assetInfo = new List<Asset>();
        List<XC_Customer_Interaction__c> listCustomerInteraction = new List<XC_Customer_Interaction__c>();
        for(Asset asset : mapNew.values()){
            Boolean check = (asset.XC_Segment__c == 'B2B' || asset.XC_Segment__c == 'B2G') && asset.XC_Product_Type__c =='Service' && asset.Status != mapOld.get(asset.id).Status && (asset.Status == 'Active' || (asset.Status == 'Inactive' && asset.XC_DeactivationByChangeOrder__c ));
            if(check){
                assetForCustomerInteraction.add(asset.id);
            }
        }
        if(assetForCustomerInteraction.isEmpty()){
            return;
        }
        assetInfo = [SELECT XC_Contract__c, NE__Order_Config__c, NE__Order_Config__r.NE__OptyId__c, id, ContactId, Contact.Name, Contact.Email, Contact.XC_Preferredlanguageofcontact__c, XC_LegalEntity__c, XC_Segment__c, AccountId, Status  from Asset  WHERE ID IN: assetForCustomerInteraction];
        for(Asset a : assetInfo){
            if(a.Status == 'Active'){
                listCustomerInteraction.add(populateCustomerInteraction(a, 'Service_Activation'));
            }else if(a.Status == 'Inactive'){
                listCustomerInteraction.add(populateCustomerInteraction(a, 'Service_Deactivation'));
            }
        }
        XC_UTIL_DML.insertRecords(listCustomerInteraction);
    }
    
    private static XC_Customer_Interaction__c populateCustomerInteraction(Asset asset, String comunicationType){
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.XC_OpportunityId__c = asset.NE__Order_Config__r.NE__OptyId__c;
        ci.XC_OrderId__c = asset.NE__Order_Config__c;
        ci.XC_ContactId__c = asset.ContactId;
        ci.XC_ContractId__c = asset.XC_Contract__c;
        ci.XC_AccountId__c = asset.AccountId  ;
        ci.XC_Recipient__c = asset.Contact.Name;
        ci.XC_Email__c = asset.Contact.Email;
        ci.XC_Preferredlanguageofcontact__c = asset.Contact.XC_Preferredlanguageofcontact__c;
        ci.XC_Channel__c = 'Email';
        ci.XC_Communication_Type__c = comunicationType;
        ci.XC_LegalEntity__c = asset.XC_LegalEntity__c;
        ci.XC_Segment__c = asset.XC_Segment__c;
        return ci;
    }
}