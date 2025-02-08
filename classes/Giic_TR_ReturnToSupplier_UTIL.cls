public class Giic_TR_ReturnToSupplier_UTIL {
    
    
    public static void setAddressOnRTS(List<gii__ReturntoSupplier__c > listNew){
        List<String> accountId = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__Supplier__c');
        map<Id,XC_Address__c> addressMap = new  map<Id,XC_Address__c>([SELECT Id,XC_Account__c,XC_City__c,XC_AddressCountry__c,
                                                                       XC_AddressProvince__c, XC_Floor__c, XC_Door__c, XC_Stair__c,XC_Address__c,XC_StreetNumber__c,XC_PostalCode__c
                                                                       FROM XC_Address__c WHERE  XC_Account__c IN: accountId]);
        
        for(gii__ReturntoSupplier__c rts : listNew){
            for(XC_Address__c ad : addressMap.values()){
                if(rts.gii__Supplier__c!=null && rts.gii__Supplier__c == ad.XC_Account__c){
                    rts.gii__SupplierCity__c = ad.XC_City__c ; 
                    rts.gii__SupplierCountry__c = ad.XC_AddressCountry__c ; 
                    rts.gii__SupplierStateProvince__c = ad.XC_AddressProvince__c ;
                    String floor =  ad.XC_Floor__c != null ? ', Floor ' + ad.XC_Floor__c : '';
                    String door =  ad.XC_Door__c != null ? ', Door ' + ad.XC_Door__c : '';
                    String stair =  ad.XC_Stair__c != null ? ', Stair ' + ad.XC_Stair__c : '';
                    rts.gii__SupplierStreet__c = ad.XC_Address__c +', '+ad.XC_StreetNumber__c + floor + door + stair ; 
                    rts.gii__SupplierZipPostalCode__c = ad.XC_PostalCode__c ; 
                }
                
            }
        }
        
    }
    
     /**  
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 26/11/2019
* @description To set legalEntity
* @param listNew -  List of RTS
*/
     public static void setLEOnRTS(List<gii__ReturntoSupplier__c> listNew){
        List<String> whIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__ShipFrom__c');
        map<Id,gii__Warehouse__c> p2Maps = new  map<Id,gii__Warehouse__c> ([SELECT Id, giic_LegalEntity__c FROM gii__Warehouse__c WHERE Id IN: whIds ]);
        System.debug('p2Maps = '+p2Maps.values());
        for(gii__ReturntoSupplier__c r : listNew){   
             for(gii__Warehouse__c w : p2Maps.values()){
                 if(r.gii__ShipFrom__c	== w.Id && w.giic_LegalEntity__c != null){
                    	r.giic_LegalEntity__c = w.giic_LegalEntity__c;
                 }
             }
            
        }
        
    }
    
    
    
}