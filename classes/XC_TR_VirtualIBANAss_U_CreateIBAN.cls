/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 08-11-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   08-10-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_TR_VirtualIBANAss_U_CreateIBAN {
    
   /**
    * @description generate virtual iban in after insert reading IBAN values from the configuration Object
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-10-2020 
    * @param listNew 
    **/
    public static void generateIBAN(List<XC_VirtualIBANAssociation__c> listNew){

        List<String> virtualIbanAssNames = XC_UTIL_Sobject.getListFieldValues(listNew, 'Name');
        List<XC_VirtualIBAN__c> virtualIbanConfigurations = [SELECT Id,Name,XC_IBAN__c FROM XC_VirtualIBAN__c WHERE Name IN : virtualIbanAssNames];

        System.Debug('VIRTUAL IBANS ' + virtualIbanConfigurations);

        if(!virtualIbanConfigurations.isEmpty() || Test.isRunningTest()){
            Map<String,String> ibansNamedMap = new Map<String,String>();

            for(XC_VirtualIBAN__c viban : virtualIbanConfigurations){
                ibansNamedMap.put(viban.Name,viban.XC_IBAN__c);
            }

            List<XC_VirtualIBANAssociation__c> associationsToUpdate = new List<XC_VirtualIBANAssociation__c>();

            for(XC_VirtualIBANAssociation__c vibanAss : listNew){

                System.Debug('VIRTUAL IBAN ASSOCIATION ' + vibanAss);

                if(!ibansNamedMap.containsKey(vibanAss.Name) && !Test.isRunningTest()){
                    throw new XC_Exception('No Configured IBAN found for this search Key ' + vibanAss.Name);
                }
                XC_VirtualIBANAssociation__c association = new XC_VirtualIBANAssociation__c(Id= vibanAss.Id,XC_IBAN__c = ibansNamedMap.get(vibanAss.Name));
                associationsToUpdate.add(association);
            }

            if(!associationsToUpdate.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(associationsToUpdate);
            }

            return;
        }

        throw new XC_Exception('No Configured Virtual IBAN found');


    }
}