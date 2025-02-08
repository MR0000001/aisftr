/**
 * The Class XC_TR_Address_U_PopulateFields.
 *
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 28/03/2019
 * @description XC_TR_Address_U_PopulateFields – Populate Fields of XC_Address__c
 */ 

public class XC_TR_Address_U_PopulateFields {
    
    /**
     * @description Populate name address.
     *
     * @param listNew the list new
     */
    public static void populateNameAddress(List<XC_Address__c> listNew) {
        for(XC_Address__c address : listNew) {
            String fullAddress = /*address.XC_StreetType__c + ' ' +*/ address.XC_Address__c + ' ' + address.XC_StreetNumber__c + ', ' + address.XC_City__c + ', ' + address.XC_PostalCode__c;  // Modified by NM - LR 28/05/2019
            if(!String.isBlank(address.XC_Stair__c)) { 
                fullAddress = fullAddress + ', ' + Label.XC_CL_Stair + ' ' + address.XC_Stair__c;
            } 
            if(!String.isBlank(address.XC_Floor__c)) {
                fullAddress = fullAddress + ', ' + Label.XC_CL_Floor + ' ' + address.XC_Floor__c;
            }
            system.debug('fullAddress -->'+ fullAddress);

            if(!String.isBlank(address.XC_StreetTypeText__c)){
                if(!fullAddress.containsIgnoreCase(address.XC_StreetTypeText__c)){
                    fullAddress = address.XC_StreetTypeText__c + ' ' + fullAddress;
                }
            }

            if(!String.isBlank(address.XC_Door__c)){
                fullAddress = fullAddress + ', ' + Label.XC_CL_Door + ' ' + address.XC_Door__c;
            }

            if(fullAddress.length()>80) {
                 fullAddress = fullAddress.subString(0,79);            
            }
            address.Name = fullAddress;
        }
    }

    /**
     * @description Populate name address on update.
     *
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void populateNameAddressOnUpdate(List<XC_Address__c> listNew, Map<Id,XC_Address__c> mapOld, Map<Id,XC_Address__c> mapNew) {
        List<String> fieldList = new List<String>{'XC_StreetType__c', 'XC_StreetNumber__c', 'XC_Address__c', 'XC_City__c', 'XC_Stair__c', 'XC_Floor__c'};
        List<XC_Address__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            populateNameAddress(listChanged);
        } 
    }

    /**
     * @description Populate StreetTypeText address (street type label translated by user language).
     * @param listNew the list new
     */
    public static void populateStreetTypeText(List<XC_Address__c> listNew) {
        if(!listNew.isEmpty()){
            for(XC_Address__c address : listNew) {
                if(String.isNotBlank(address.XC_StreetType__c)){
                    address.XC_StreetTypeText__c = XC_UTIL_Sobject_U_Retrieve.retrieveLabelPicklistValue('XC_Address__c', 'XC_StreetType__c', address.XC_StreetType__c);
                }
                if(String.isNotBlank(address.XC_Category__c)){
                    address.XC_CategoryText__c = XC_UTIL_Sobject_U_Retrieve.retrieveLabelPicklistValue('XC_Address__c', 'XC_Category__c', address.XC_Category__c);
                }
            }
        }
    }
    
    /**
     * @description Populate StreetTypeText address (street type label translated by user language).
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void populateStreetTypeText(List<XC_Address__c> listNew, Map<Id,XC_Address__c> mapOld, Map<Id,XC_Address__c> mapNew) {
        List<String> fieldList = new List<String>{'XC_StreetType__c'};
        List<XC_Address__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        populateStreetTypeText(listChanged);
    }

    /**
     * @description Populate MatchKey field (concatenate mandatory fields for duplication criteria).
     * @param listNew the list new
     * @author Simone Trenta - strenta@deloitte.it
     */
    public static void populateMacthKeyField(List<XC_Address__c> listNew){
        if(!listNew.isEmpty()){
            for(XC_Address__c address : listNew) {

                address.XC_KeyForDuplication__c = 
                    address.XC_Account__c + ' ' +
                    address.XC_AddressCountry__c + ' ' + 
                    address.XC_City__c + ' ' +
                    address.XC_AddressProvince__c + ' ' +
                    address.XC_StreetNumber__c;               

                address.XC_KeyForDuplicationOne__c =
                    address.XC_Address__c + ' ' + 
                    address.XC_StreetTypeText__c + ' ' +  
                    address.XC_Municipality__c + ' ' +
                    address.XC_PostalCode__c;

            }
        }
    }

    /**
     * @description Populate MatchKey field (concatenate mandatory fields for duplication criteria).
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     * @author Simone Trenta - strenta@deloitte.it
     */
    public static void populateMacthKeyField(List<XC_Address__c> listNew, Map<Id,XC_Address__c> mapOld, Map<Id,XC_Address__c> mapNew){
        List<String> fieldList = new List<String>{'XC_Account__c', 'XC_AddressCountry__c', 'XC_StreetTypeText__c', 'XC_Address__c', 'XC_StreetNumber__c', 'XC_City__c', 'XC_Municipality__c', 'XC_AddressProvince__c', 'XC_PostalCode__c'};
        List<XC_Address__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        populateMacthKeyField(listChanged);
    }

    /**
    * @description populate Account And Lead Fields
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 24/7/2019
    * @param listNew
    */
    public static void populateAccountAndLeadFields(List<XC_Address__c> listNew){
        List<String> listOfAccId = new List<String>();
        for(XC_Address__c address : listNew){
            if(!String.isBlank(address.XC_Lead__c) || !String.isBlank(address.XC_IdLead__c) ){
                address.XC_IdLead__c  = address.XC_Lead__c;
            }
            if(!String.isBlank(address.XC_Account__c) || !String.isBlank(address.XC_IdAccount__c)){
                if(!String.isBlank(address.XC_Account__c)){
                    listOfAccId.add(address.XC_Account__c);
                }
                address.XC_IdAccount__c  = address.XC_Account__c;
            }
        }
        List<Account> listOfAcc = new List<Account>([SELECT Id, XC_isGuestUser__c FROM Account WHERE Id =:listOfAccId]);
        for(XC_Address__c address : listNew){
            for(Account acc : listOfAcc){
                if(address.XC_Account__c.equals(acc.Id) && String.isBlank(address.XC_IsGuest__c)){
                    address.XC_IsGuest__c = String.valueOf(acc.XC_isGuestUser__c);
                }
            }
        }
    }

    /**
    * @description populate Account And Lead Fields On Update
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 24/7/2019
    * @param listNew - List<XC_Address__c> 
    * @param mapOld - Map<Id, XC_Address__c> 
    * @param mapNew - Map<Id, XC_Address__c> 
    */
    public static void populateAccountAndLeadFieldsOnUpdate(List<XC_Address__c> listNew, Map<Id,XC_Address__c> mapOld, Map<Id,XC_Address__c> mapNew){
        List<String> fieldList = new List<String>{'XC_Lead__c', 'XC_Account__c'};
        List<XC_Address__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        populateAccountAndLeadFields(listChanged);
    }
    
        /**
     * @description update address id on lead
     * @param listNew the list new
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     */
    public static void updateAddressOnLead(List<XC_Address__c> listNew){
        List<Lead> leads = new List<Lead>();
        System.debug('*Address listNew: *' + listNew);
        for(XC_Address__c address : listNew){
            System.debug('*Address for* '+address.id);
            if(!String.isBlank(address.XC_Lead__c)){
                Lead l = new Lead();
                l.id = address.XC_Lead__c;
                l.XC_LeadAddress__c = address.id;
                System.debug('*Address l.id*' + l.id);
                System.debug('*Address l.XC_LeadAddress__c*' + l.XC_LeadAddress__c);
           		leads.add(l);
            }
        }
        System.debug('*Address leads: *' + leads);
        
        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.updateListRecords(leads);
        for(XC_UTIL_Sobject.WrapperResult w : res){
            system.debug(w.success);
            if(!w.success){
                system.debug(w.errorMessage);
            } 
        }
    }
}