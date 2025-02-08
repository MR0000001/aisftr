/**
* @author De Blasio Valentina
* @date Creation 20/06/2022
* @date Modification -
* @description XC_TR_ZuoraZInvoice_U_FillConfigItem populate configurationitem lookup of invoice
*/			   

public without sharing class XC_TR_ZuoraZInvoice_U_FillConfigItem {
    
    public static void fillInvoiceConfigItemLookup (Map<Id,Zuora__ZInvoice__c> mapOld, Map<Id,Zuora__ZInvoice__c> mapNew){
        List<Zuora__ZInvoice__c> invoiceToUpdate = new List<Zuora__ZInvoice__c>();
        List<String> legalEntity=new List<String>{'EnelSole','EnelXItalia'};
        Set<Id> conftemid=new Set<Id>();
        List<String> fieldList = new List<String>{'XC_ConfigurationItem__c'};
        List<Zuora__ZInvoice__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
          for(Zuora__ZInvoice__c zinv:listChanged){
              if(zinv.XC_ConfigurationItem__c !=null){
                 conftemid.add(zinv.XC_ConfigurationItem__c);
                 } 
             }
        }
        List<NE__OrderItem__c> listiorderItem=[Select id,NE__OrderId__r.XC_LegalEntity__c from NE__OrderItem__c where id in:conftemid and NE__OrderId__r.XC_LegalEntity__c in:legalEntity];
        for(NE__OrderItem__c orderitemId : listiorderItem){     
       	    for(Zuora__ZInvoice__c z:listChanged){
                if(orderitemId.Id==String.valueof(z.XC_ConfigurationItem__c)){
                   Zuora__ZInvoice__c zinvoice=new Zuora__ZInvoice__c();
                   zinvoice.id=z.id;
                   zinvoice.Configuration_Item__c= orderitemId.id; 
                   invoiceToUpdate.add(zinvoice);                      
            	}
            }
        }   
        XC_TR_ZuoraZInvoice_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_TR_ZuoraZInvoice_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        if(!invoiceToUpdate.isEmpty() && !Test.isRunningTest()){
            update invoiceToUpdate;
        }
        XC_TR_ZuoraZInvoice_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        XC_TR_ZuoraZInvoice_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
	}
    
    
     public static void PopulateInvoiceConfigItemLookup (List<Zuora__ZInvoice__c> listNew){
        List<Zuora__ZInvoice__c> invoiceToUpdate = new List<Zuora__ZInvoice__c>();
        List<String> legalEntity=new List<String>{'EnelSole','EnelXItalia'};
        List<String> idconfitem = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_ConfigurationItem__c');
        if(!idconfitem.isEmpty()) {
       	   List<NE__OrderItem__c> listiorderItem=[Select id,NE__OrderId__r.XC_LegalEntity__c from NE__OrderItem__c where id in:idconfitem and NE__OrderId__r.XC_LegalEntity__c in:legalEntity];         
           for(NE__OrderItem__c orderitemId : listiorderItem){
               for(Zuora__ZInvoice__c zinv:listNew){
                   if(orderitemId.Id==String.valueof(zinv.XC_ConfigurationItem__c)){    
                      Zuora__ZInvoice__c zinvoice=new Zuora__ZInvoice__c();
                      zinvoice.id=zinv.id;
                   	  zinvoice.Configuration_Item__c= orderitemId.id; 
                   	  invoiceToUpdate.add(zinvoice);                  
            	       }
                   } 
                }
        }
      
        if(!invoiceToUpdate.isEmpty()){
            update invoiceToUpdate;
        }
    }
}