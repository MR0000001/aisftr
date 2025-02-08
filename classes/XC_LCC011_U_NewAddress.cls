/**
 * The Class XC_LCC011_NewAddress.
 *
 * @author Lorenzo Orlanducci,
 * @date Creation 28/02/2019
 * @date Modification dd/mm/yyyy
 * @description Util for XC_LCP011_NewAddress component
 */
public without sharing class XC_LCC011_U_NewAddress {

    /**
     * @description The Class WrapperInput.
    */
    public class WrapperInput {

        /** The id account. */
        @AuraEnabled
        public string idAccount='';

        /** The input fields. */
        @AuraEnabled
        public string inputFields='';

        /** The pod checkbox. */
        @AuraEnabled
        public List<String> podCheckbox=new List<String>();

        /** The category. */
        @AuraEnabled
        public String category='';
    }

    /**
     * @description WrapperResponseAddress
     *
     */
    public class WrapperResponseAddress {

        /** The Result. */
        @AuraEnabled
        public String address = '';

        /** The Address. */
        @AuraEnabled
        public String addressName ='';
    }

    /**
     * Save address apex.
     *
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @param inputAddress the input address
     * @return the x C UTI L result wrapper
     * @description Method for save address from button on Account detail page.
     */
    public static XC_UTIL_ResultWrapper saveAddressApex(String inputAddress) {
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;

        Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(inputAddress);

        XC_Address__c ad = new XC_Address__c();
        ad = populateAddress(ad, fieldMap);
        ad.RecordTypeId = XC_UTIL_Address.getAddressRecordTypeByCountry(ad.XC_AddressCountry__c, (fieldMap.get('isAccountPartner')==true));

        XC_UTIL_Sobject.WrapperResult wrapper = XC_UTIL_Sobject.insertRecord(ad);
        wr = new XC_UTIL_ResultWrapper(wrapper);

        /*
        system.debug('saveAddressApex');
        if(!String.isBlank(ad.XC_Lead__c)){
            system.debug('saveAddressApex: '+ad.XC_Lead__c);
            Lead l = new Lead();
            l.id = ad.XC_Lead__c;
            l.XC_LeadAddress__c = ad.id;
            XC_UTIL_Sobject.updateRecord(l);
        }
        */

        return wr;
    }

    /**
     * @description update address
     * @param inputFields the address serialized
     * @return a list of results
     * @author Simone Trenta - strenta@deloitte.it
     */
    public static XC_UTIL_Sobject.WrapperResult updateAddressByLead(String inputFields) {
        Map<String,Object> inputMap = (Map<String,Object>) JSON.deserializeUntyped(inputFields);

        String leadId = String.valueOf(inputMap.get('lead'));

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
                        XC_ClarificatorType__c, //new
                        XC_ClarificatorValue__c  //new
                FROM XC_Address__c
                WHERE XC_Lead__r.id =: leadId]);
        XC_Address__C add = mapAdd.values()[0];

        add = populateAddress(add, inputMap);
        List<SObject> upLst = new List<SObject>();
        upLst.add(add);

        //Lead ld = new Lead();
        //ld = populateLeadAddress(inputMap, ld);
        //ld.XC_LeadAddress__c = add.id;
        //upLst.add(ld);

        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.updateListRecords(upLst);
        for (XC_UTIL_Sobject.WrapperResult wr : res){
            if(!wr.success){
                return wr;
            }
        }

        return res[0];
    }

    /**
    * populateAddress
    *
    * @author Simone Trenta - strenta@deloitte.it
    * @param ad the address object
    * @param fieldMap the input fields
    * @return the address
    * @description Method for populate address
    */
    private static XC_Address__c populateAddress(XC_Address__c ad, Map<String,Object> fieldMap){

        if(fieldMap.get('validate')!=null) {
            ad.XC_AddressNotValidated__c = !(Boolean) fieldMap.get('validate');
            ad.XC_AddressValidated__c = (Boolean) fieldMap.get('validate');
        }

        if(fieldMap.get('streetTypeText')!=null) {
            ad.XC_StreetTypeText__c  = (String) fieldMap.get('streetTypeText');
            ad.XC_StreetType__c = null;

        }else{
            if(fieldMap.get('streetType')!=null) {
                ad.XC_StreetType__c  = (String) fieldMap.get('streetType');
            }
        }

        if(fieldMap.get('validatedCups')!=null) {
            ad.XC_AddressValidatedCUPS__c  = (Boolean) fieldMap.get('validatedCups');
        }

        Map<String, Object> fieldInputMap = new Map<String, Object>{
                'XC_AddressCountry__c' => fieldMap.get('country'),
                'XC_Address__c' => fieldMap.get('address'),
                'XC_StreetNumber__c' => fieldMap.get('streetNumber'),
                'XC_Door__c' => fieldMap.get('door'),
                'XC_GasCUPS__c' => fieldMap.get('gas'),
                'XC_ElectricCUPS__c' => fieldMap.get('electric'),
                'XC_PostalCode__c' => fieldMap.get('postalCode'),
                'XC_Stair__c' => fieldMap.get('stair'),
                'XC_Floor__c' => fieldMap.get('floor'),
                'XC_City__c' => fieldMap.get('city'),
                'XC_AddressProvince__c' => fieldMap.get('province'),
                'XC_Category__c' => fieldMap.get('category'),
                'XC_Municipality__c' => fieldMap.get('municipality'),
                'XC_Lead__c' => fieldMap.get('lead'),
                'XC_ClarificatorType__c' => fieldMap.get('clarifType'),
                'XC_ClarificatorValue__c' => fieldMap.get('clarifValue'),
                'XC_Account__c' => fieldMap.get('account')
        };

        for (String field : fieldInputMap.keySet()) {
            if ( fieldInputMap.get(field)!=null && fieldInputMap.get(field)+'' != '') {
                ad.put(field, fieldInputMap.get(field));
            }
        }

        ad.XC_InstallationAddress__c = true;
        ad.XC_DeliveryAddress__c = true;
        ad.XC_BillingAddress__c = true;
        ad.XC_PickUpPoint__c = true;
        ad.XC_WareHouse__c = true;
        ad.XC_PointOfSales__c = true;

        return ad;
    }

    public static Lead populateLeadAddress(Map<String,Object> fieldMap, Lead ld){

        Map<String, Object> fieldInputMap = new Map<String, Object>{
                'Id' => fieldMap.get('lead'),
                'XC_Country__c' => fieldMap.get('country'),
                'XC_StreetNumber__c' => fieldMap.get('streetNumber'),
                'XC_Door__c' => fieldMap.get('door'),
                'XC_GasCUPS__c' => fieldMap.get('gas'),
                'XC_ElectricCUPS__c' => fieldMap.get('electric'),
                'XC_ZipCode__c' => fieldMap.get('postalCode'),
                'XC_Stair__c' => fieldMap.get('stair'),
                'XC_Floor__c' => fieldMap.get('floor'),
                'XC_City__c' => fieldMap.get('city'),
                'XC_Province__c' => fieldMap.get('province'),
                'XC_Category__c' => fieldMap.get('category'),
                'XC_Municipality__c' => fieldMap.get('municipality'),
                'XC_ClarificatorType__c' => fieldMap.get('clarifType'),
                'XC_ClarificatorValue__c' => fieldMap.get('clarifValue')
        };
        for (String field : fieldInputMap.keySet()) {
            if ( fieldInputMap.get(field)!=null && fieldInputMap.get(field)+'' != '') {
                ld.put(field, fieldInputMap.get(field));
            }
        }
        return ld;
    }

}