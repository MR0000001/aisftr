/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com && Domenico Del prete - domenico.delprete@nttdata.com
* @date Creation 20/11/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ComplianceMaster_U_ExtraCost ---- Util class for XC_UTIL_ComplianceMaster for obtain the extra cost value
*/
public without sharing class XC_UTIL_ComplianceMaster_U_ExtraCost {


    /**
    * @description 
    * @author Del Prete Domenico - domenico.delprete@nttdata.com | 20/11/2019 
    * @param orderItemList 
    * @return Map<Id, Decimal> 
    **/ 
    public static Map<Id,Decimal> getExtraCost(List<NE__OrderItem__c> orderItemList){
        if(orderItemList.isEmpty()){
            return new Map<Id,Decimal>();
        }
        Decimal extracost = 0;
        Map<Id,Decimal> mapIdOicExtraCost = new Map<Id,Decimal>();
        if(!orderItemList.isEmpty() && String.isBlank(orderItemList[0].NE__Bundle_Configuration__c)){
            mapIdOicExtraCost.put(orderItemList[0].Id, extracost);
            return mapIdOicExtraCost;
        }
        List<String> billingModelAcceptedList = new List<String>{Label.XC_CL_BillingModel_Recurring, Label.XC_CL_BillingModel_OneShot};
        List<NE__OrderItem__c> listOfOIC = new List <NE__OrderItem__c> ([SELECT Id, NE__BaseOneTimeFee__c, NE__OneTimeFeeOv__c, NE__BaseRecurringCharge__c, NE__RecurringChargeOv__c, XC_BillingModel__c
                                                                        FROM NE__OrderItem__c 
                                                                        WHERE NE__Bundle_Configuration__c =: orderItemList[0].NE__Bundle_Configuration__c AND 
                                                                            XC_Product_Type__c =: Label.XC_CL_Technical AND XC_Product_Subtype__c =: Label.XC_CL_ProductSubtype_ExtraInstallation AND 
                                                                            XC_BillingModel__c IN: billingModelAcceptedList]);
        for(NE__OrderItem__c oi :listOfOIC){
            if(oi.XC_BillingModel__c.equals(Label.XC_CL_BillingModel_Recurring)){
                extracost = manageRecurringBillingModel(oi, extracost);
            }else if(oi.XC_BillingModel__c.equals(Label.XC_CL_BillingModel_OneShot)){
                extracost = manageOneShotBillingModel(oi, extracost);
            }
        }
        mapIdOicExtraCost.put(orderItemList[0].Id, extracost);
        return mapIdOicExtraCost;
    }

    private static Decimal manageRecurringBillingModel(NE__OrderItem__c oi, Decimal extracost){
        if(oi.NE__RecurringChargeOv__c > 0 ){
            extracost += oi.NE__RecurringChargeOv__c;
        }else{
            extracost += oi.NE__BaseRecurringCharge__c;
        }
        return extracost;
    }

    private static Decimal manageOneShotBillingModel(NE__OrderItem__c oi, Decimal extracost){
        if(oi.NE__OneTimeFeeOv__c  > 0 ){
            extracost += oi.NE__OneTimeFeeOv__c;
        }else{
            extracost += oi.NE__BaseOneTimeFee__c;
        }
        return extracost;
    }

}