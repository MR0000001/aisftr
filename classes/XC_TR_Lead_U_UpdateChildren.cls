/**
* @author Simone Trenta - stenta@deloitte.it
* @date Creation 15/04/2019
* @date Modification 
* @description Class with methods to update children of Lead
*/

public with sharing class XC_TR_Lead_U_UpdateChildren { 

    /**
     * @author Simone Trenta - stenta@deloitte.it
     * @description Update or create addresses record when editing Lead object 
     * @param mapOld 
     * @param mapNew
    */ 
    public static void updateOrCreateAddress(Map<Id, Lead> mapOld, Map<Id, Lead> mapNew) {

        List<String> listFieldToCheck = new List<String> {  'XC_Country__c',
                                                            'XC_Category__c',
                                                            'XC_StreetType__c', 
                                                            'XC_Address__c', 
                                                            'XC_StreetNumber__c',
                                                            'XC_Floor__c',
                                                            'XC_Door__c',
                                                            'XC_Stair__c',
                                                            'XC_City__c',
                                                            'XC_Municipality__c',
                                                            'XC_Province__c',
                                                            'XC_ZipCode__c',
                                                            'XC_InstallationAddress__c',
                                                            'XC_BillingAddress__c',
                                                            'XC_DeliveryAddress__c',
                                                            'XC_Region__c' };

        List<Lead> listLeadChanged = XC_UTIL_Sobject.getListChanged(listFieldToCheck, mapOld, mapNew); 

        List<String> listLeadIds =  new List<String>();

        for (Lead l : listLeadChanged) {
            listLeadIds.add(l.id);
        }

        if(listLeadChanged.isEmpty()){
            return;
        } 

        Map<id,Lead> withAddress = new Map<id,Lead>();
        Map<id,Lead> withoutAddress = new Map<id,Lead>();

        for (Lead l : listLeadChanged) {
            if(String.isBlank(l.XC_Address__c)){
                continue;
            }
            if(String.isBlank(l.XC_LeadAddress__c)) {
                withoutAddress.put(l.id, l);
            } else {
                withAddress.put(l.id, l);
            }
        }

        updateAddress(withAddress);
        createAddress(withoutAddress);
    } 

    /**
     * @author Simone Trenta - stenta@deloitte.it
     * @description Update addresses record when editing Lead object 
     * @param mapNew - map Id -> new value of record
    */
    private static void updateAddress(Map<id,Lead> mapNew){

        if(!Schema.sObjectType.XC_Address__c.isAccessible()){
            return;
        }

        List<XC_Address__c> addresses = [ 	SELECT id,
                                         	XC_AddressCountry__c,
                                         	XC_Category__c,
                                            XC_StreetType__c,
                                            XC_Address__c,
                                            XC_StreetNumber__c,
                                            XC_Floor__c,
                                            XC_Door__c,
                                            XC_Stair__c,
                                            XC_City__c,
                                            XC_Municipality__c,
                                            XC_AddressProvince__c,
                                            XC_PostalCode__c,
                                            XC_InstallationAddress__c,
                                            XC_BillingAddress__c,
                                            XC_DeliveryAddress__c,
                                            XC_Lead__c,
                                            XC_Region__c
                                            FROM XC_Address__c
                                            where XC_Lead__c in: mapNew.keySet() ];
 
        for (XC_Address__c add : addresses) {
            if (mapNew.keySet().contains(add.XC_Lead__c)) {
                Lead l = mapNew.get(add.XC_Lead__c);
                add.XC_AddressCountry__c = l.XC_Country__c;
                add.XC_Category__c = l.XC_Category__c;
                add.XC_StreetType__c = l.XC_StreetType__c;
                add.XC_Address__c = l.XC_Address__c;
                add.XC_StreetNumber__c = l.XC_StreetNumber__c;
                add.XC_Floor__c = l.XC_Floor__c;
                add.XC_Door__c = l.XC_Door__c;
                add.XC_Stair__c = l.XC_Stair__c;
                add.XC_City__c = l.XC_City__c;
                add.XC_Municipality__c = l.XC_Municipality__c;
                if(l.XC_Country__c == 'Spain') {
                    add.XC_AddressProvince__c = l.XC_Province__c;
                } else if(l.XC_Country__c == 'Italy') {
                    add.XC_Region__c = l.XC_Region__c;
                }else {
                    add.XC_Region__c = l.XC_Province__c;
                }
                add.XC_PostalCode__c = l.XC_ZipCode__c;
                add.XC_InstallationAddress__c = l.XC_InstallationAddress__c;
                add.XC_BillingAddress__c = l.XC_BillingAddress__c;
                add.XC_DeliveryAddress__c = l.XC_DeliveryAddress__c;         
            }
        }

        XC_UTIL_SObject.updateListRecords(addresses);
    }

    
    /**
     * @author Simone Trenta - stenta@deloitte.it
     * @description Update addresses record when editing Lead object 
     * @param mapNew - map Id -> new value of record
    */
    @testVisible
    private static void createAddress(Map<id,Lead> mapNew){

        List<XC_Address__c> addresses = new List<XC_Address__c>();

        for (Lead l : mapNew.values()) {
            XC_Address__c add = new XC_Address__c();              
            add.XC_AddressCountry__c = l.XC_Country__c;
            add.XC_Category__c = l.XC_Category__c;
            add.XC_StreetType__c = l.XC_StreetType__c;
            add.XC_Address__c = l.XC_Address__c;
            add.XC_StreetNumber__c = l.XC_StreetNumber__c;
            add.XC_Floor__c = l.XC_Floor__c;
            add.XC_Door__c = l.XC_Door__c;
            add.XC_Stair__c = l.XC_Stair__c;
            add.XC_City__c = l.XC_City__c;
            add.XC_Municipality__c = l.XC_Municipality__c;
            if(l.XC_Country__c == 'Spain') {
                add.XC_AddressProvince__c = l.XC_Province__c;
            } else if(l.XC_Country__c == 'Italy') {
                add.XC_Region__c = l.XC_Region__c;
            }else {
                add.XC_Region__c = l.XC_Province__c;
            }
            add.XC_PostalCode__c = l.XC_ZipCode__c;
            add.XC_InstallationAddress__c = l.XC_InstallationAddress__c;
            add.XC_BillingAddress__c = l.XC_BillingAddress__c;
            add.XC_DeliveryAddress__c = l.XC_DeliveryAddress__c;
            add.XC_Lead__c = l.id;
            addresses.add(add);
        }

        XC_UTIL_SObject.insertListRecords(addresses);

        for (Lead l : mapNew.values()) {
            for (XC_Address__c add : addresses) {
                if ( add.XC_Lead__c == l.id ) {
                    l.XC_LeadAddress__c = add.id;
                }
            }
        }
        
    }
    /**
     * @author Andrea Di Cicco
     * @description Method use to create address from lead by dataloader 
     * @param listNew - map Id -> new value of record
    */
    public static void createAddressForDataImport(List<Lead> listNew){
        List<Lead> leadWithNewAddress = new List<Lead>();
        for(Lead l : listNew){
            if(l.XC_Segment__c != 'B2C' && l.XC_Segment__c != null && l.XC_Country__c != null && l.XC_City__c != null && l.XC_Address__c!= null && l.XC_MassivelyCreated__c){
                leadWithNewAddress.add( l);
            }
        }
        if(!leadWithNewAddress.isEmpty()){
            List<XC_Address__c> addresses = new List<XC_Address__c>();

            for (Lead l : leadWithNewAddress) {
                XC_Address__c add = new XC_Address__c();              
                add.XC_AddressCountry__c = l.XC_Country__c;
                add.XC_Category__c = l.XC_Category__c;
                add.XC_StreetType__c = l.XC_StreetType__c;
                add.XC_Address__c = l.XC_Address__c;
                add.XC_StreetNumber__c = l.XC_StreetNumber__c;
                add.XC_Floor__c = l.XC_Floor__c;
                add.XC_Door__c = l.XC_Door__c;
                add.XC_Stair__c = l.XC_Stair__c;
                add.XC_City__c = l.XC_City__c;
                add.XC_Municipality__c = l.XC_Municipality__c;
                if(l.XC_Country__c == 'Spain') {
                    add.XC_AddressProvince__c = l.XC_Province__c;
                } else if(l.XC_Country__c == 'Italy') {
                    add.XC_Region__c = l.XC_Region__c;
                }else {
                    add.XC_Region__c = l.XC_Province__c;
                }
                add.XC_PostalCode__c = l.XC_ZipCode__c;
                add.XC_InstallationAddress__c = l.XC_InstallationAddress__c;
                add.XC_BillingAddress__c = l.XC_BillingAddress__c;
                add.XC_DeliveryAddress__c = l.XC_DeliveryAddress__c;
                add.XC_Lead__c = l.id;
                addresses.add(add);
            }
    
            XC_UTIL_SObject.insertListRecords(addresses);
            for (Lead l : leadWithNewAddress) {
                for (XC_Address__c add : addresses) {
                    if ( add.XC_Lead__c == l.id ) {
                        l.XC_LeadAddress__c = add.id;
                    }
                }
            }
        }
    }

      public static void createAddressForDataImportAfterInsert(List<Lead> listNew) {
        System.debug('createAddressForDataImport '+ listNew);
        List<Lead> leadWithNewAddress = new List<Lead>();
        List<Lead> leadToUpdate = new List<Lead>();
        for(Lead l : listNew){
            if(l.XC_Segment__c != 'B2C' && l.XC_Segment__c != null && l.XC_Country__c != null && l.XC_City__c != null && l.XC_Address__c!= null && l.XC_MassivelyCreated__c){
                leadWithNewAddress.add( l);
            }
        }
        System.debug('leadWithNewAddress.isEmpty() '+ leadWithNewAddress.isEmpty());
        if(!leadWithNewAddress.isEmpty()){
            List<XC_Address__c> addresses = new List<XC_Address__c>();
            String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'XC_Address_Global'].Id;            
            for (Lead l : leadWithNewAddress) {
                XC_Address__c add = new XC_Address__c();              
                add.XC_AddressCountry__c = l.XC_Country__c;
                add.XC_Category__c = l.XC_Category__c;
                add.XC_StreetType__c = l.XC_StreetType__c;
                add.XC_Address__c = l.XC_Address__c;
                add.XC_StreetNumber__c = l.XC_StreetNumber__c;
                add.XC_Floor__c = l.XC_Floor__c;
                add.XC_Door__c = l.XC_Door__c;
                add.XC_Stair__c = l.XC_Stair__c;
                add.XC_City__c = l.XC_City__c;
                add.XC_Municipality__c = l.XC_Municipality__c;
                if(l.XC_Country__c == 'Spain') {
                    add.XC_AddressProvince__c = l.XC_Province__c;
                } else if(l.XC_Country__c == 'Italy') {
                    add.XC_Region__c = l.XC_Region__c;
                }else {
                    add.XC_Region__c = l.XC_Province__c;
                }
                add.XC_PostalCode__c = l.XC_ZipCode__c;
                add.XC_InstallationAddress__c = l.XC_InstallationAddress__c;
                add.XC_BillingAddress__c = l.XC_BillingAddress__c;
                add.XC_DeliveryAddress__c = l.XC_DeliveryAddress__c;
                add.XC_Lead__c = l.id;
                add.RecordTypeId = recordTypeId;
                addresses.add(add);
            }
            
            XC_UTIL_SObject.insertListRecords(addresses);
            
            for (Lead l : leadWithNewAddress) {
                for (XC_Address__c add : addresses) {
                    System.debug('add '+ add);
                    System.debug('l '+ l);
                    if ( add.XC_Lead__c == l.id ) {
                        leadToUpdate.add(new Lead(Id = l.id,XC_LeadAddress__c = add.id));                        
                    }
                }
            }            
        }        
        if(leadToUpdate.size()>0) {                
            XC_UTIL_Sobject.updateListRecords(leadToUpdate);
        }
    }
    

}