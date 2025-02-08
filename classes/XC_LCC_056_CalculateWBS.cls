/**
* @author: Donato Lombardi 
* @date Creation Date: 09/09/2019
* @description calculate WBS
*/
public with sharing class XC_LCC_056_CalculateWBS {
    public static Map<Id,XC_WbeTracking__c> confIdWbe = new Map<Id,XC_WbeTracking__c>();

    @AuraEnabled
    /**
   * @author: Donato Lombardi
   * @date Creation Date 09/09/2019
   * @description method calculate WBE   
   * @param recordId Id
   * @return errorMsg String 
   */
    public static String submit(Id recordId){
        String wbeOldD = 'wbe';
        String wbeOldA = 'wbe';
        String wbeNewA = 'wbe';
        String wbeNewD = 'wbe';
        List<NE__OrderItem__c> listItems = XC_LCC_056_CalculateWBS_U.retriveConfItem(recordId);
        if(listItems.isEmpty()){
            return Label.XC_WBEexisisting;
        }

        //DTT ALC 26-01-2022 Cogenio WBE - START
        if(checkFakeWBE(recordId)){
            //We skipped all WBE logic, assign a fake WBE and update the WBE Status
            XC_LCC_056_CalculateWBS_New.calculateFakeWBE(listItems);
            return 'OK';
        }else{
        List<NE__OrderItem__c> listItems2 = XC_LCC_056_CalculateWBS_U.retriveConfItemforPenlty(recordId);
        List<NE__OrderItem__c> listItemsToPenaltiy = new List<NE__OrderItem__c>();
        listItemsToPenaltiy = XC_LCC_056_CalculateWBS_U.wbsToPenalty(listItems2);
        if(!listItemsToPenaltiy.isEmpty()){
            return 'OK';
        }

        if(XC_LCC_056_CalculateWBS_UU.checkSalesChannel(listItems)){
            return Label.XC_CL_WBE_InsertSalesChannel;

        }
        if(checkInvoiceContractType(listItems)){
            return Label.XC_CL_WBE_MissingContractType;
        }
        if(checkgGeographicalDataIsFilled(listItems)){
            return Label.XC_CL_CheckGeographicalData;
        }
        if(checkBillingModelIsFilled(listItems)){
            return Label.XC_CL_CheckBillingModelWBE;
        }
        if(checkProprietaImpianti(listItems)){
            return Label.XC_CL_WBE_MissingOwnerShip;
        }
        if(checkRecurringDuration(listItems)){
            return Label.XC_CL_DurationField_Is_Filled; 
        }
        if(checkContractEndDate(listItems)){
            return Label.XC_CL_WBE_MissingContarctEndDate;
        }


        XC_LCC_056_CalculateWBS_New.generateAutoNumber(listItems);

        return XC_LCC_056_CalculateWBS_New.calculateWBE(listItems);
        }
        //DTT ALC 26-01-2022 Cogenio WBE - END
     }

    private static Boolean checkInvoiceContractType(List<NE__OrderItem__c> liItems){
        Set<Id> setIdOpportuinty = new Set<Id>();
        Boolean missingField = False;
        for(NE__OrderItem__c ne :liItems){
            setIdOpportuinty.add(ne.NE__OrderId__r.NE__OptyId__c);
        }
        List<Contract> listContract = new List<Contract>();
        listContract = [SELECT id, XC_Configurations__c, XC_InvoiceType__c, Opportunity__c,XC_ContractType__c,Contract_Type__c from Contract where Opportunity__c = :setIdOpportuinty];

        for(Contract c :listContract){
            if(liItems[0].XC_Segment__c == 'B2G' && (c.XC_InvoiceType__c == null || c.Contract_Type__c == null)){
                missingField = True;
                break;
            }
        }
        return missingField;


    }

    private static Boolean checkgGeographicalDataIsFilled(List<NE__OrderItem__c> listItems){
        Boolean fieldIsBlank = False;
        Map<Id,String> mapIdCompanyCode = new Map<Id,String>();
        for(NE__OrderItem__c ne : listItems){
            mapIdCompanyCode.put(ne.id,ne.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c);
        }
        String segment = listItems[0].NE__OrderId__r.XC_Segment__c;
        Map<Id,String> getGeographicalDataOrderItem = XC_LCC_056_CalculateWBS_New.getGeographicalDataOrderItem(mapIdCompanyCode.values()[0], segment, listItems);
        List<XC_CM_LegalEntity_Configuration__mdt> listCMCompanyCode = [SELECT ID, XC_LegalEntity__c,XC_Stream__c, XC_CompanyCode__c,XC_digFree__c, XC_digitFree2__c, XC_Type_of_WBE__c, XC_WBEDigit18__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c IN:mapIdCompanyCode.values() AND XC_Stream__c =: segment AND XC_OrgId__c = :UserInfo.getOrganizationId() LIMIT 1];
        for(NE__OrderItem__c ne: listItems){
            if( !listCMCompanyCode.isEmpty() && listCMCompanyCode[0].XC_Type_of_WBE__c == 'Complex' && String.isBlank(listCMCompanyCode[0].XC_digFree__c)){
                if(getGeographicalDataOrderItem.get(ne.Id) == null){
                    fieldIsBlank = True;
                    return fieldIsBlank;
                }

            }

        }


        return fieldIsBlank;
    }

    private static Boolean checkBillingModelIsFilled(List<NE__OrderItem__c> listItems){
        Boolean check = false;
        for(NE__OrderItem__c ne: listItems){
           if(String.isBlank(ne.XC_BillingModel__c)){
               return true;
           }

        }
    return check;
    }

    private static Boolean checkProprietaImpianti(List<NE__OrderItem__c> listItems){
        Boolean check = false;
        if(String.isBlank(listItems[0].NE__OrderId__r.XC_PlantOwnership__c)){
            check = true;
        }
        return check;
    }

    private static Boolean checkRecurringDuration(List<NE__OrderItem__c> listItems){
        Boolean check = false;
        for(NE__OrderItem__c orderItem : listItems){
            if(orderItem.XC_BillingModel__c=='Recurring' && orderItem.XC_RecurringDuration__c == Null) {
                return true;
            }
        }
        return false;
    }
    
        private static Boolean checkContractEndDate(List<NE__OrderItem__c> liItems){
 		Set<Id> setIdOpportuinty = new Set<Id>();
        Boolean missingDate = False;
        for(NE__OrderItem__c ne :liItems){
            setIdOpportuinty.add(ne.NE__OrderId__r.NE__OptyId__c);
        }
        List<Contract> listContract = new List<Contract>();
        listContract = [SELECT id, XC_Configurations__c, EndDate, Opportunity__c from Contract where Opportunity__c = :setIdOpportuinty];

        for(Contract c :listContract){
            if(c.EndDate == null ){
                missingDate = True;
                break;
            }
        }
        return missingDate;
    }

    private static Boolean checkFakeWBE(Id recordId){
        Boolean needsFakeWBE = false;
        NE__Order__c order = [SELECT Id, XC_Calculate_Fake_WBE__c FROM NE__Order__c WHERE Id=:recordId];

        if(order.XC_Calculate_Fake_WBE__c){
            needsFakeWBE = true;
        }

        return needsFakeWBE;
    }

}