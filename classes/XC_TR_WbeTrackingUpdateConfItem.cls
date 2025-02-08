/**
 * @author Donato Lombardi - dolombardi@deloitte.it
 * @description Method to retrieve a Map of Work Order -> List skills requested
 * @param listNew - List WorkOrder
 * @return void
 **/


public without sharing class XC_TR_WbeTrackingUpdateConfItem {


    public static void updateConfigurationItem(List<XC_WbeTracking__c> listNew, List<XC_WbeTracking__c> listOld){
        Map<String,XC_WbeTracking__c> mapWbeChange = new Map<String,XC_WbeTracking__c>();
        mapWbeChange = checkStatusIsChanged(listNew,listOld);
        System.debug('DL--> mapWbeChange' + mapWbeChange);
        if(mapWbeChange.isEmpty()){
            return;
        }
        List<NE__OrderItem__c> queryOnConfItemList = new List<NE__OrderItem__c>();
        queryOnConfItemList = queryOnConfItem(mapWbeChange);
        System.debug('DL--> queryOnConfItemList' + queryOnConfItemList);
        if(!queryOnConfItemList.isEmpty()){
            updateConfItem(mapWbeChange,queryOnConfItemList);
        }
    }


    private static Map<String,XC_WbeTracking__c> checkStatusIsChanged(List<XC_WbeTracking__c> listNew, List<XC_WbeTracking__c> listOld){
        Map<String,XC_WbeTracking__c> mapWbeChange = new Map<String,XC_WbeTracking__c>();
        for(XC_WbeTracking__c newVal : listNew){
            for(XC_WbeTracking__c oldVal : listOld){
                if(oldVal.XC_Status__c!=newVal.XC_Status__c && newVal.XC_ConfigurationItemId__c!=Null){
                    mapWbeChange.put(newVal.XC_ConfigurationItemId__c, newVal);
                }
            }
        }
        return mapWbeChange;
    }


    private static List<NE__OrderItem__c> queryOnConfItem(Map<String,XC_WbeTracking__c> mapWbeChange){
        List<NE__OrderItem__c> listConfItems = new List<NE__OrderItem__c>();
        if(Schema.SObjectType.NE__OrderItem__c.isAccessible()){
            List<String> wbeList = (List<String>) XC_UTIL_Sobject.getListFieldValues(mapWbeChange.values(),'XC_Wbe__c');
            List<String> ordList = (List<String>) XC_UTIL_Sobject.getListFieldValues(mapWbeChange.values(),'XC_ConfigurationId__c');
            listConfItems = [SELECT ID, XC_Wbe__c, XC_WBE_Status__c, XC_ProjectDimension__c,
                                (SELECT Id, XC_Flow_API_Name__c, XC_Status__c, XC_ErrorMessage__c FROM Provisioning_Steps__r WHERE XC_Flow_API_Name__c = :Label.XC_CL_ProvisioningFlow_CheckWBEStatus AND XC_Status__c = :Label.XC_CL_InProgress)
                            FROM NE__OrderItem__c
                            WHERE XC_Wbe__c IN :wbeList and NE__OrderId__c IN :ordList];
        }
        return listConfItems;
    }


    private static void updateConfItem(Map<String,XC_WbeTracking__c> mapWbeChange,List<NE__OrderItem__c> listConfItems){
        List<NE__OrderItem__c> listItemsToUpdate = new List<NE__OrderItem__c>();
        List<XC_Provisioning_Step__c > listStepsToUpdate = new List<XC_Provisioning_Step__c >();
        for(XC_WbeTracking__c wb : mapWbeChange.values()){
            for(NE__OrderItem__c ne : listConfItems){
                System.debug('DL--> wb.XC_ConfigurationItemId__c' + wb.XC_ConfigurationItemId__c);
                System.debug('DL--> ne.id' + ne.id);
                if(wb.XC_ConfigurationItemId__c == ne.id){
                    ne.XC_WBE_Status__c = wb.XC_Status__c;
                    ne.XC_ProjectDimension__c = wb.XC_ProjectDimension__c;
                    ne.XC_BlockWBE_User__c= true;
                    listItemsToUpdate.add(ne);
                    if(!ne.Provisioning_Steps__r.isEmpty()) {
                        XC_Provisioning_Step__c  stepToUpdate = ne.Provisioning_Steps__r[0];
                        stepToUpdate.XC_Status__c = (ne.XC_WBE_Status__c == 'Approved') ? Label.XC_CL_Completed_Ok : ((ne.XC_WBE_Status__c == 'Rejected') ? Label.XC_CL_Step_CompletedKO : stepToUpdate.XC_Status__c);
                        stepToUpdate.XC_ErrorMessage__c = (ne.XC_WBE_Status__c == 'Rejected') ? Label.XC_CL_ProvisioningStep_WBERejected : stepToUpdate.XC_ErrorMessage__c;
                        listStepsToUpdate.add(stepToUpdate);
                    }
                }
            }
        }
        checkAccesibleAndUpdate(listItemsToUpdate);
        checkAccesibleAndUpdateSteps(listStepsToUpdate);
    }


    private static void checkAccesibleAndUpdate(List<NE__OrderItem__c> listItemsToUpdate){
        if(Schema.SObjectType.NE__OrderItem__c.isUpdateable() && !listItemsToUpdate.isEmpty()){
            System.debug('DL--> listItemsToUpdate' + listItemsToUpdate);
            Database.update(listItemsToUpdate);
            for(NE__OrderItem__c ne :listItemsToUpdate){
                ne.XC_BlockWBE_User__c = false;
            }
            update listItemsToUpdate;
        }
    }


    private static void checkAccesibleAndUpdateSteps(List<XC_Provisioning_Step__c> listStepsToUpdate){
        if(Schema.SObjectType.XC_Provisioning_Step__c.isUpdateable() && !listStepsToUpdate.isEmpty()){
            System.debug('--> listStepsToUpdate' + listStepsToUpdate);
            XC_UTIL_SObject.updateListRecords(listStepsToUpdate);
        }
    }

}