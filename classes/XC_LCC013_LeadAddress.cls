/**
* The Class XC_LCC013_LeadAddress.
* @author Roberta Cossiga - rcossiga@deloitte.it
* @description XC_LCC013_LeadAddress
*/

public with sharing class XC_LCC013_LeadAddress {

    /**
     * Gets the field set.
     * @description Gets the field set.
     * @return the field set
     */
    @AuraEnabled
    public static String getFieldSet(){
        String fieldSetName = 'XC_ESP_Lead_New_Address';
        return fieldSetName;
    } 

    /**
     * Gets address fields by lead
     * @description Gets the field set.
     * @param leadId the lead id 
     * @author Simone Trenta - strenta@deloitte.it
     * @return the field set
     */
    @AuraEnabled
    public static string getAddressFields(String leadId){
        Map<String,Object> res = new Map<String,Object>();
        Map<id,XC_Address__c> mapAdd = new Map<id,XC_Address__C>([
            SELECT id, 
            XC_AddressCountry__c ,
            XC_StreetTypeText__c,
            XC_Address__c,
            XC_StreetNumber__c,
            XC_Door__c,
            XC_PostalCode__c,
            XC_Stair__c,
            XC_Floor__c,
            XC_City__c,
            XC_AddressProvince__c,
            XC_Category__c,
            XC_Municipality__c,
            XC_GasCUPS__c,
            XC_ElectricCUPS__c,
            XC_InstallationAddress__c,
            XC_DeliveryAddress__c,
            XC_BillingAddress__c,
            XC_PickUpPoint__c,
            XC_WareHouse__c,
            XC_PointOfSales__c,
            XC_AddressValidated__c,
            XC_AddressValidatedCUPS__c,
            XC_ClarificatorType__c,
            XC_ClarificatorValue__c,
            XC_Region__c, 
            XC_Lead__r.RecordType.Name
            FROM XC_Address__c 
            WHERE XC_Lead__r.id =: leadId]);

        if(mapAdd.values().isEmpty()){
            String parentRecordTypeName = [Select RecordType.DeveloperName from Lead where id = : leadId].RecordType.DeveloperName;
            res.put('parentRecordType', parentRecordTypeName);
            res.put('addressToUpdate', false);
            return JSON.serialize(res, true);
        }

        XC_Address__c add = mapAdd.values()[0];
        
        res.put('country',add.XC_AddressCountry__c);
        res.put('streetTypeText',add.XC_StreetTypeText__c); 
        res.put('address',add.XC_Address__c);
        res.put('streetNumber',add.XC_StreetNumber__c);
        res.put('door',add.XC_Door__c);
        res.put('postalCode',add.XC_PostalCode__c);
        res.put('stair',add.XC_Stair__c);
        res.put('floor',add.XC_Floor__c);
        res.put('city',add.XC_City__c);
        res.put('province',add.XC_AddressProvince__c);
        res.put('category',add.XC_Category__c);
        res.put('municipality',add.XC_Municipality__c);
        res.put('gas',add.XC_GasCUPS__c);
        res.put('electric',add.XC_ElectricCUPS__c);
        res.put('installationAddress',add.XC_InstallationAddress__c);
        res.put('deliveryAddress',add.XC_DeliveryAddress__c);
        res.put('billingAddress',add.XC_BillingAddress__c);
        res.put('pickupPoint',add.XC_PickUpPoint__c);
        res.put('warehouse',add.XC_WareHouse__c);
        res.put('pointOfSales',add.XC_PointOfSales__c);
        res.put('validate',add.XC_AddressValidated__c);
        res.put('validatedCups',add.XC_AddressValidatedCUPS__c);
        res.put('clarifType',add.XC_ClarificatorType__c);
        res.put('clarifValue',add.XC_ClarificatorValue__c);
        res.put('lead',leadId); 
        res.put('region',add.XC_Region__c);
        res.put('parentRecordType', add.XC_Lead__r.RecordType.Name);
        res.put('addressToUpdate', 'true');
        return JSON.serialize(res, true);
    }
}