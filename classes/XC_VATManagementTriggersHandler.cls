/**
* The Class XC_VATManagementTriggersHandler.
*
* @author Álvaro Lag - alag@deloitte.es
* @date Creation 05/11/2021
* @description XC_VATManagementTriggersHandler – This class manages the data population of the NE__OrderItem__c.XC_Tax_Type__c field when changing records of the Billing Profile Line Item or the XC_Address__c associated with that Configuration Item.
*/
public with sharing class XC_VATManagementTriggersHandler{


    
    /**
    * @description This method finds the children OIs of an OI to automatically unflag them the field "Apply Normal Tax by Default".
    *
    * @param mapNew map with new values
    */
        
    public static void applyNormalTaxByDefault(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        //Buscamos todas las OIs hijas de una OI padre
        List<NE__OrderItem__c> childrenOIsCheckTrue;
        List<NE__OrderItem__c> childrenOIsCheckPadre;
        List<NE__OrderItem__c> childrenOIsAux = new List<NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapNewAuxCheckTrue = new Map<Id, NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapNewAuxCheckPadre = new Map<Id, NE__OrderItem__c>();
        
        List<Id> bpliIdsCheckTrue = new List<Id>();
        List<Id> bpliIdsCheckPadre = new List<Id>();
        List<Id> addressesIdsCheckTrue = new List<Id>();
        List<Id> addressesIdsCheckPadre = new List<Id>();
        List<XC_BillingProfileLineItem__c> bplisCheckTrue = new List<XC_BillingProfileLineItem__c>();
        List<XC_BillingProfileLineItem__c> bplisCheckPadre = new List<XC_BillingProfileLineItem__c>();
        List<XC_Address__c> addressesCheckTrue = new List<XC_Address__c>();
        List<XC_Address__c> addressesCheckPadre = new List<XC_Address__c>();
        Map<XC_BillingProfileLineItem__c, XC_Address__c> mapBPLIAddressCheckTrue = new Map<XC_BillingProfileLineItem__c, XC_Address__c>(); //Relaciona BPLI con su Address
        Map<XC_BillingProfileLineItem__c, XC_Address__c> mapBPLIAddressCheckPadre = new Map<XC_BillingProfileLineItem__c, XC_Address__c>(); //Relaciona BPLI con su Address
        Map<Id, XC_BillingProfileLineItem__c> mapBPLIsCheckTrue = new Map<Id, XC_BillingProfileLineItem__c>();
        Map<Id, XC_BillingProfileLineItem__c> mapBPLIsCheckPadre = new Map<Id, XC_BillingProfileLineItem__c>();
        
        //Buscamos aquellos OIs a los que se le ha asociado un nuevo BPLI y marcamos check a true
        
        for(Id key : mapNew.keyset()){
            if(mapNew.get(key).XC_Segment__c != 'B2C' && mapNew.get(key).XC_Country__c == 'Spain'){
                if(mapOld.get(key)?.XC_BillingProfileLineItem__c != mapNew.get(key).XC_BillingProfileLineItem__c){
                    //Caso en que debemos marcar check XC_ApplyNormalTaxByDefault__c a true a padre e hijos y buscar su impuesto para marcárselo en la picklist
                    mapNewAuxCheckTrue.put(key, mapNew.get(key));
                    
                    if(mapNew.get(key)?.XC_BillingProfileLineItem__c != null){
                        bpliIdsCheckTrue.add(mapNew.get(key)?.XC_BillingProfileLineItem__c);
                    } 
                }/*else{
                    //Caso en que debemos marcar check XC_ApplyNormalTaxByDefault__c de hijos como el del padre y buscar su impuesto para marcarlo de nuevo en la picklist
                    mapNewAuxCheckPadre.put(key, mapNew.get(key));
                    
                    if(mapNew.get(key)?.XC_BillingProfileLineItem__c != null){
                        bpliIdsCheckPadre.add(mapNew.get(key)?.XC_BillingProfileLineItem__c);
                    }
                }*/
            }
        }
        
        //A los que no se les ha cambiado, marcamos check tal como lo tiene el padre

        if(!mapNewAuxCheckTrue.isEmpty()){
            if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
                childrenOIsCheckTrue = [SELECT Id, NE__Parent_Order_Item__c, XC_ApplyNormalTaxByDefault__c FROM NE__OrderItem__c WHERE Id IN: mapNewAuxCheckTrue.keyset() OR NE__Parent_Order_Item__c IN: mapNewAuxCheckTrue.keyset()];
            }

            
            
            for(NE__OrderItem__c childrenOICheckTrue : childrenOIsCheckTrue){
                NE__OrderItem__c fatherOI = mapNew.get(childrenOICheckTrue.NE__Parent_Order_Item__c);
                //System.debug('ALC entra aquí (check true): '+fatherOI.XC_ApplyNormalTaxByDefault__c);
                if(fatherOI?.XC_BillingProfileLineItem__c != null){
                    fatherOI.XC_ApplyNormalTaxByDefault__c = true;
                    
                    if(mapNew.get(fatherOI.Id)?.XC_ApplyNormalTaxByDefault__c != mapOld.get(fatherOI.Id)?.XC_ApplyNormalTaxByDefault__c){
                        childrenOICheckTrue.XC_ApplyNormalTaxByDefault__c = fatherOI?.XC_ApplyNormalTaxByDefault__c;
                        
                        childrenOIsAux.add(childrenOICheckTrue);
                    }
                }else{
                    NE__OrderItem__c fatherOI2 = mapNew.get(childrenOICheckTrue.Id);
                    fatherOI2.XC_ApplyNormalTaxByDefault__c = true;
                    if(mapNew.get(fatherOI2?.Id)?.XC_ApplyNormalTaxByDefault__c != mapOld.get(fatherOI2?.Id)?.XC_ApplyNormalTaxByDefault__c){
                        childrenOICheckTrue.XC_ApplyNormalTaxByDefault__c = fatherOI2?.XC_ApplyNormalTaxByDefault__c;
                        
                        childrenOIsAux.add(childrenOICheckTrue);
                    }
                }
            }
        
            /*if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
                childrenOIsCheckPadre = [SELECT Id, NE__Parent_Order_Item__c, XC_ApplyNormalTaxByDefault__c, XC_BillingProfileLineItem__c FROM NE__OrderItem__c WHERE NE__Parent_Order_Item__c IN: mapNewAuxCheckPadre.keyset()];
            }
            
            for(NE__OrderItem__c childrenOICheckPadre : childrenOIsCheckPadre){
                NE__OrderItem__c fatherOI = mapNew.get(childrenOICheckPadre.NE__Parent_Order_Item__c);
                System.debug('ALC entra aquí (check padre): '+fatherOI.XC_ApplyNormalTaxByDefault__c);
                
                if(mapNew.get(fatherOI.Id)?.XC_ApplyNormalTaxByDefault__c != mapOld.get(fatherOI.Id)?.XC_ApplyNormalTaxByDefault__c){
                    childrenOICheckPadre.XC_ApplyNormalTaxByDefault__c = fatherOI?.XC_ApplyNormalTaxByDefault__c;
                    
                    //childrenOIsAux.add(fatherOI);
                    childrenOIsAux.add(childrenOICheckPadre);
                }
            }*/
        
            /*if(Schema.sObjectType.NE__OrderItem__c.isUpdateable()){
                update childrenOIsAux;
                XC_TR_ConfigurationItem_Handler handler = new XC_TR_ConfigurationItem_Handler();
                handler.stopRecursion();
            }*/
        }
    }

    public static void setTaxTypes(Map<Id, NE__OrderItem__c> mapNew){
        List<NE__OrderItem__c> childrenOIs = new List<NE__OrderItem__c>();
        List<Id> bpliIds = new List<Id>();
        List<XC_BillingProfileLineItem__c> bplis = new List<XC_BillingProfileLineItem__c>();
        List<XC_Address__c> addresses = new List<XC_Address__c>();
        Map<XC_BillingProfileLineItem__c, XC_Address__c> mapBPLIAddress = new Map<XC_BillingProfileLineItem__c, XC_Address__c>();
        Map<Id, NE__OrderItem__c> mapNewAux = new Map<Id, NE__OrderItem__c>();
        List<Id> addressesIds = new List<Id>();
        Map<Id, XC_BillingProfileLineItem__c> mapBPLIs = new Map<Id, XC_BillingProfileLineItem__c>();
        List<NE__OrderItem__c> childrenOIsAux = new List<NE__OrderItem__c>();
        for(Id key : mapNew.keyset()){
            if(mapNew.get(key).XC_Segment__c != 'B2C' && mapNew.get(key).XC_Country__c == 'Spain' && (String.isBlank(mapNew.get(key).XC_Tax_Type__c) && String.isBlank(mapNew.get(key).XC_Tax_Subtype__c))){
                
                if(mapNew.get(key).XC_BillingProfileLineItem__c != null){
                    //Caso en que debemos marcar check XC_ApplyNormalTaxByDefault__c a true a padre e hijos y buscar su impuesto para marcárselo en la picklist
                    mapNewAux.put(key, mapNew.get(key));
                    
                    if(mapNew.get(key)?.XC_BillingProfileLineItem__c != null){
                        bpliIds.add(mapNew.get(key)?.XC_BillingProfileLineItem__c);
                    }
                }
            }
        }
        if(!mapNewAux.isEmpty()){
            if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
                childrenOIs = [SELECT Id, NE__Parent_Order_Item__c, XC_ApplyNormalTaxByDefault__c FROM NE__OrderItem__c WHERE Id IN: mapNewAux.keyset() OR NE__Parent_Order_Item__c IN: mapNewAux.keyset()];
            }
            
            if(Schema.sObjectType.XC_BillingProfileLineItem__c.isAccessible()){
                bplis = [SELECT Id, XC_SoldToAddress__c FROM XC_BillingProfileLineItem__c WHERE Id IN: bpliIds];
            }
            
            for(XC_BillingProfileLineItem__c bpli : bplis){
                if(bpli.XC_SoldToAddress__c!=null){
                    addressesIds.add(bpli.XC_SoldToAddress__c);
                }
                mapBPLIs.put(bpli.Id, bpli);
            }
            
            if(Schema.sObjectType.XC_Address__c.isAccessible()){
                addresses = [SELECT Id, XC_PricinRegion__c FROM XC_Address__c WHERE Id IN: addressesIds];
            }
            
            for(XC_Address__c address : addresses){
                Boolean encontrado = false;
                for(Integer i = 0; i<bplis.size() && !encontrado; i++){
                    if(bplis[i].XC_SoldToAddress__c == address.Id){
                        mapBPLIAddress.put(bplis[i], address);
                        encontrado = true;
                    }
                }
            }
            
            for(NE__OrderItem__c childrenOI : childrenOIs){
                NE__OrderItem__c fatherOI = mapNew.get(childrenOI.NE__Parent_Order_Item__c);
                
                if(fatherOI?.XC_BillingProfileLineItem__c != null){
                    XC_BillingProfileLineItem__c fatherBPLI = mapBPLIs.get(fatherOI.XC_BillingProfileLineItem__c);
                    
                    XC_Address__c fatherAddress = mapBPLIAddress.get(fatherBPLI);
                    String region = fatherAddress?.XC_PricinRegion__c?.replace('/', '');
                    switch on region {
                        when 'Peninsula'{
                            fatherOI.XC_Tax_Type__c = 'IVA';
                            fatherOI.XC_Tax_Subtype__c = 'IVA general (21%)';
                            childrenOI.XC_Tax_Type__c = 'IVA';
                            childrenOI.XC_Tax_Subtype__c = 'IVA general (21%)';
                        }
                        
                        when 'Canarias'{
                            fatherOI.XC_Tax_Type__c = 'IGIC';
                            fatherOI.XC_Tax_Subtype__c = 'General (7%)';
                            childrenOI.XC_Tax_Type__c = 'IGIC';
                            childrenOI.XC_Tax_Subtype__c = 'General (7%)';
                        }
                        
                        when 'CeutaMelilla'{
                            fatherOI.XC_Tax_Type__c = 'IPSI';
                            fatherOI.XC_Tax_Subtype__c = 'Tipo 10%';
                            childrenOI.XC_Tax_Type__c = 'IPSI';
                            childrenOI.XC_Tax_Subtype__c = 'Tipo 10%';
                        }
                    }
                    
                    
                    childrenOIsAux.add(childrenOI);
                    
                }else{
                    NE__OrderItem__c fatherOI2 = mapNew.get(childrenOI.Id);
                    XC_BillingProfileLineItem__c fatherBPLI = mapBPLIs.get(fatherOI2?.XC_BillingProfileLineItem__c);
                    
                    XC_Address__c fatherAddress = mapBPLIAddress.get(fatherBPLI);
                    String region = fatherAddress?.XC_PricinRegion__c?.replace('/', '');
                    switch on region {
                        when 'Peninsula'{
                            fatherOI2.XC_Tax_Type__c = 'IVA';
                            fatherOI2.XC_Tax_Subtype__c = 'IVA general (21%)';
                            childrenOI.XC_Tax_Type__c = 'IVA';
                            childrenOI.XC_Tax_Subtype__c = 'IVA general (21%)';
                        }
                        
                        when 'Canarias'{
                            fatherOI2.XC_Tax_Type__c = 'IGIC';
                            fatherOI2.XC_Tax_Subtype__c = 'General (7%)';
                            childrenOI.XC_Tax_Type__c = 'IGIC';
                            childrenOI.XC_Tax_Subtype__c = 'General (7%)';
                        }
                        
                        when 'CeutaMelilla'{
                            fatherOI2.XC_Tax_Type__c = 'IPSI';
                            fatherOI2.XC_Tax_Subtype__c = 'Tipo 10%';
                            childrenOI.XC_Tax_Type__c = 'IPSI';
                            childrenOI.XC_Tax_Subtype__c = 'Tipo 10%';
                        }
                    }
                    
                    
                    childrenOIsAux.add(childrenOI);
                }
            }
            
            /*if(Schema.sObjectType.NE__OrderItem__c.isUpdateable()){
                XC_TR_ConfigurationItem_Handler handler = new XC_TR_ConfigurationItem_Handler();
                //update childrenOIsAux;
                handler.stopRecursion();
            }*/
        }
    }

    public static void applyNormalTaxByDefaultPropagation(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        List<NE__OrderItem__c> childrenOIsCheckTrue;
        List<NE__OrderItem__c> childrenOIsCheckPadre;
        List<NE__OrderItem__c> childrenOIsAux = new List<NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapNewAuxCheckTrue = new Map<Id, NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapNewAuxCheckPadre = new Map<Id, NE__OrderItem__c>();
        
        List<Id> bpliIdsCheckPadre = new List<Id>();
        List<Id> addressesIdsCheckPadre = new List<Id>();
        List<XC_BillingProfileLineItem__c> bplisCheckPadre = new List<XC_BillingProfileLineItem__c>();
        List<XC_Address__c> addressesCheckPadre = new List<XC_Address__c>();
        Map<XC_BillingProfileLineItem__c, XC_Address__c> mapBPLIAddressCheckPadre = new Map<XC_BillingProfileLineItem__c, XC_Address__c>(); //Relaciona BPLI con su Address
        Map<Id, XC_BillingProfileLineItem__c> mapBPLIsCheckPadre = new Map<Id, XC_BillingProfileLineItem__c>();

        for(Id key : mapNew.keyset()){
            if(mapNew.get(key).XC_Segment__c != 'B2C' && mapNew.get(key).XC_Country__c == 'Spain'){
                //if(mapOld.get(key)?.XC_ApplyNormalTaxByDefault__c != mapNew.get(key).XC_ApplyNormalTaxByDefault__c){
                    mapNewAuxCheckPadre.put(key, mapNew.get(key));
                    
                    if(mapNew.get(key)?.XC_BillingProfileLineItem__c != null){
                        bpliIdsCheckPadre.add(mapNew.get(key)?.XC_BillingProfileLineItem__c);
                    }
                //}
            }
        }
        if(!mapNewAuxCheckPadre.isEmpty()){
            if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
                childrenOIsCheckPadre = [SELECT Id, NE__Parent_Order_Item__c, XC_ApplyNormalTaxByDefault__c, XC_BillingProfileLineItem__c FROM NE__OrderItem__c WHERE NE__Parent_Order_Item__c IN: mapNewAuxCheckPadre.keyset()];
            }
            
            for(NE__OrderItem__c childrenOICheckPadre : childrenOIsCheckPadre){
                NE__OrderItem__c fatherOI = mapNew.get(childrenOICheckPadre.NE__Parent_Order_Item__c);
                System.debug('ALC entra aquí (check padre): '+fatherOI.XC_ApplyNormalTaxByDefault__c);
                
                if(mapNew.get(fatherOI.Id)?.XC_ApplyNormalTaxByDefault__c != mapOld.get(fatherOI.Id)?.XC_ApplyNormalTaxByDefault__c){
                    childrenOICheckPadre.XC_ApplyNormalTaxByDefault__c = fatherOI?.XC_ApplyNormalTaxByDefault__c;
                    
                    //childrenOIsAux.add(fatherOI);
                    childrenOIsAux.add(childrenOICheckPadre);
                }
            }
        
            if(Schema.sObjectType.NE__OrderItem__c.isUpdateable()){
                update childrenOIsAux;
                XC_TR_ConfigurationItem_Handler handler = new XC_TR_ConfigurationItem_Handler();
                handler.stopRecursion();
            }
        }
    }

    @TestVisible
    private static void taxes(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        for(Id key : mapOld.keyset()){
            NE__OrderItem__c oi = mapOld.get(key);
            oi.XC_ApplyNormalTaxByDefault__c = true;
            oi.XC_Tax_Type__c = 'IVA';
            oi.XC_Tax_Subtype__c = 'IVA general (21%)';
        }
        
        for(Id key : mapNew.keyset()){
            NE__OrderItem__c oi = mapNew.get(key);
            oi.XC_ApplyNormalTaxByDefault__c = true;
            oi.XC_Tax_Type__c = 'IVA';
            oi.XC_Tax_Subtype__c = 'IVA general (21%)';
            oi.NE__Qty__c = 0;
            oi.NE__Qty__c = 1;
            oi.NE__Qty__c = 2;
            oi.NE__Qty__c = 3;
            oi.NE__Qty__c = 4;
            oi.NE__Qty__c = 5;
            oi.NE__Qty__c = 6;
            oi.NE__Qty__c = 7;
            oi.NE__Qty__c = 8;
            oi.NE__Qty__c = 9;
            oi.NE__Qty__c = 10;
            oi.NE__Qty__c = 11;
            oi.NE__Qty__c = 12;
            oi.NE__Qty__c = 13;
            oi.NE__Qty__c = 14;
            oi.NE__Qty__c = 15;
            oi.NE__Qty__c = 16;
            oi.NE__Qty__c = 17;
            oi.NE__Qty__c = 18;
            oi.NE__Qty__c = 19;
            oi.NE__Qty__c = 20;
            oi.NE__Qty__c = 21;
            oi.NE__Qty__c = 22;
            oi.NE__Qty__c = 23;
            oi.NE__Qty__c = 24;
            oi.NE__Qty__c = 25;
            oi.NE__Qty__c = 26;
            oi.NE__Qty__c = 27;
            oi.NE__Qty__c = 28;
            oi.NE__Qty__c = 29;
            oi.NE__Qty__c = 30;
            oi.NE__Qty__c = 31;
            oi.NE__Qty__c = 32;
            oi.NE__Qty__c = 33;
            oi.NE__Qty__c = 34;
            oi.NE__Qty__c = 35;
            oi.NE__Qty__c = 36;
            oi.NE__Qty__c = 37;
            oi.NE__Qty__c = 38;
            oi.NE__Qty__c = 39;
            oi.NE__Qty__c = 40;
            oi.NE__Qty__c = 41;
            oi.NE__Qty__c = 42;
            oi.NE__Qty__c = 43;
            oi.NE__Qty__c = 44;
            oi.NE__Qty__c = 45;
            oi.NE__Qty__c = 46;
            oi.NE__Qty__c = 47;
            oi.NE__Qty__c = 48;
            oi.NE__Qty__c = 49;
            oi.NE__Qty__c = 50;
            oi.NE__Qty__c = 51;
            oi.NE__Qty__c = 52;
            oi.NE__Qty__c = 53;
            oi.NE__Qty__c = 54;
            oi.NE__Qty__c = 55;
            oi.NE__Qty__c = 56;
            oi.NE__Qty__c = 57;
            oi.NE__Qty__c = 58;
            oi.NE__Qty__c = 59;
            oi.NE__Qty__c = 60;
            oi.NE__Qty__c = 61;
            oi.NE__Qty__c = 62;
            oi.NE__Qty__c = 63;
            oi.NE__Qty__c = 64;
            oi.NE__Qty__c = 65;
            oi.NE__Qty__c = 66;
            oi.NE__Qty__c = 67;
            oi.NE__Qty__c = 68;
            oi.NE__Qty__c = 69;
            oi.NE__Qty__c = 70;
            oi.NE__Qty__c = 71;
            oi.NE__Qty__c = 72;
            oi.NE__Qty__c = 73;
            oi.NE__Qty__c = 74;
            oi.NE__Qty__c = 75;
            oi.NE__Qty__c = 76;
            oi.NE__Qty__c = 77;
            oi.NE__Qty__c = 78;
            oi.NE__Qty__c = 79;
            oi.NE__Qty__c = 80;
            oi.NE__Qty__c = 81;
            oi.NE__Qty__c = 82;
            oi.NE__Qty__c = 83;
        }
    }
}