/**
* @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 22/03/2019
* @description XC_UTIL_Address – Util class for Address
*/
public class XC_UTIL_Address {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Address');

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 22/03/2019
    * @description AddressWrapper
    */
    public class AddressWrapper {
        @AuraEnabled
        public Id LeadId;
        @AuraEnabled
        public Id AccountID;
        @AuraEnabled
        public String AddressID;
        @AuraEnabled
        public String Category;
        @AuraEnabled
        public String StreetType;
        @AuraEnabled
        public String StreetTypeText;
        @AuraEnabled
        public String Address;
        @AuraEnabled
        public String ZipCode;
        @AuraEnabled
        public String Province;
        @AuraEnabled
        public String Municipality;
        @AuraEnabled
        public String City;
        @AuraEnabled
        public String StreetNumber;
        @AuraEnabled
        public String Door;
        @AuraEnabled
        public String Floor;
        @AuraEnabled
        public String Stair;
        @AuraEnabled
        public String Country;
        @AuraEnabled
        public Boolean InstallationAddress;
        @AuraEnabled
        public Boolean DeliveryAddress;
        @AuraEnabled
        public Boolean BillingAddress;
        @AuraEnabled
        public Boolean isPartner;
        @AuraEnabled
        public Boolean addressValid;
        @AuraEnabled
        public String CUPS;
        @AuraEnabled
        public Boolean PickupPoint;
        @AuraEnabled
        public Boolean Warehouse;
        @AuraEnabled
        public Boolean PointOfSales;
        @AuraEnabled
        public String Note;
        @AuraEnabled
        public Integer AddressIndex;
        @AuraEnabled
        public String MunicipalName;
        @AuraEnabled
        public Boolean ShippingAddress;
        @AuraEnabled
        public Boolean SkipDuplication;
        @AuraEnabled
        public List<XC_REST_ReadAccont_U.WrapperAddressPointOfDelivery> PointOfDelivery;

        // Fields for the response of AddressValidation API
        public String CountryCode;
        public String CountryDesc;
        public String ProvinceCode;
        public String ProvinceCodeINE;
        public String ProvinceDesc;
        public String MunicipalityCode;
        public String MunicipalityCodeINE;
        public String MunicipalityDesc;
        public String CityCode;
        public String CityCodeINE;
        public String CityDesc;
        public String StreetCode;
        public String StreetCodeINE;
        public String StreetDesc;
        public String Coordinates;
        public String ConfidenceLevel;
        public String ReferenceYear;
        public String Street;
        public String Latitude;
        public String Longitude;
        public List<PoSWrapper> PointOfService;

        public String electricCUPS;
        public String gasCUPS;
        public Boolean validatedCups;
        public String clarifType;
        public String clarifValue;

        public String ClarifierType;
        public String ClarifierValue;

        // Fields for the Invoice API
        public String RegionCode;
        public String Region;
        public String CodTipAcFin;
        public Boolean MainContactAddress;
        public Boolean AddressStandardization;
        public Boolean SameContactAddress;
        public String AddressType;
        public String Alias;

        //Fields for Xygo
        public String RecordNum;

        public Boolean AddressValidated;

        /** @description Costructor */
        public AddressWrapper(){
            InstallationAddress = true;
            DeliveryAddress = true;
            BillingAddress = true;
            isPartner = true;
            PickupPoint = true;
            Warehouse = true;
            PointOfSales = true;
        }

        /**
        * @description Costructor
        * @param method - String
        */
        public AddressWrapper(String method) {
            if (method=='REST'){
                InstallationAddress = null;
                DeliveryAddress = null;
                BillingAddress = null;
                isPartner = null;
                PickupPoint = null;
                Warehouse = null;
                PointOfSales = null;
            }
        }

        /**
        * @description getFullName
        * @return fullName String
        */
        public String getFullName(){
            return this.StreetType+' '+this.Address+' '+this.StreetNumber+' '+this.City+' '+this.ZipCode+' '+this.Province;
        }
    }

    /**
    * @author Nicola Mariniello - nmariniello@deloitte.it & Luisana Rocco - lrocco@deloitte.it
    * @date Creation 16/04/2019
    * @description PoSWrapper
    */
    public class PoSWrapper{
        public String POSType;
        public String POS;
        public String POSID;
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 22/03/2019
    * @description insertAddress()
    * @param addressWrapper address Wrapper
    * @return XC_UTIL_Sobject.WrapperResult
    */
    public static XC_UTIL_Sobject.WrapperResult insertAddress(AddressWrapper addressWrapper) {
        List<XC_UTIL_Sobject.WrapperResult> result = insertListAddress(new List<AddressWrapper>{addressWrapper});
        return result[0];
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 22/03/2019
    * @description insertListAddress()
    * @param listAddressWrapper list of address wrapper
    * @return List<XC_UTIL_Sobject.WrapperResult>
    */
    public static List<XC_UTIL_Sobject.WrapperResult> insertListAddress(List<AddressWrapper> listAddressWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in XC_UTIL_Address.insertListAddress >'+listAddressWrapper);
        List<XC_Address__c> listAddress = new List<XC_Address__c>();

        for(AddressWrapper addressWrapper : listAddressWrapper) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in XC_UTIL_Address.insertListAddress >'+addressWrapper.electricCUPS);

            /*Id recordTypeId;
            if(addressWrapper.isPartner==true){
             recordTypeId = Schema.SObjectType.XC_Address__c.getRecordTypeInfosByDeveloperName().get('XC_ESP_Address_Partner').getRecordTypeId();

            }else{
             recordTypeId = Schema.SObjectType.XC_Address__c.getRecordTypeInfosByDeveloperName().get('XC_GLO_Address_Partner').getRecordTypeId();
            }*/

            boolean valid = addressWrapper.addressValid == null ? false : addressWrapper.addressValid;

            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@Lollo'+addressWrapper.accountId);
            listAddress.add(new XC_Address__c(
                RecordTypeId = getAddressRecordTypeByCountry(addressWrapper.country.toUpperCase(), addressWrapper.isPartner),
                //RecordTypeId = recordTypeId,
                XC_Lead__c = addressWrapper.leadId,
                XC_Account__c = addressWrapper.accountId,
                XC_Category__c = addressWrapper.category,
                XC_StreetType__c = addressWrapper.streetType,
                XC_StreetTypeText__c = addressWrapper.streetTypeText,
                XC_Address__c = addressWrapper.address,
                XC_PostalCode__c = addressWrapper.zipCode,
                XC_AddressProvince__c = addressWrapper.province,
                XC_Municipality__c = addressWrapper.municipality,
                XC_City__c = addressWrapper.city,
                XC_StreetNumber__c = addressWrapper.streetNumber,
                XC_Door__c = addressWrapper.door,
                XC_Floor__c = addressWrapper.floor,
                XC_Stair__c = addressWrapper.stair,
                XC_AddressCountry__c = addressWrapper.country,
                XC_InstallationAddress__c = addressWrapper.installationAddress,
                XC_DeliveryAddress__c = addressWrapper.deliveryAddress,
                XC_BillingAddress__c = addressWrapper.billingAddress,
                XC_PickUpPoint__c =  addressWrapper.pickupPoint,
                XC_Warehouse__c =  addressWrapper.warehouse,
                XC_PointOfSales__c =  addressWrapper.pointOfSales,
                XC_AddressNotValidated__c = !valid,
                XC_AddressValidated__c = valid,
                XC_ElectricCUPS__c = addressWrapper.electricCUPS,
                XC_GasCUPS__c = addressWrapper.gasCUPS,
                XC_AddressValidatedCUPS__c = (addressWrapper.validatedCups != null) ? addressWrapper.validatedCups : false,
                XC_ClarificatorType__c = addressWrapper.clarifType,
                XC_ClarificatorValue__c = addressWrapper.clarifValue,
                XC_Region__c = addressWrapper.Region
            ));
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Inserisco = '+listAddress[0].XC_ElectricCUPS__c);
        system.debug('test: '+listAddress[0].XC_ClarificatorType__c);
        return XC_UTIL_Sobject.insertListRecords(listAddress);
    }


    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description getAddressRecordTypeByCountry() - Method to get Address RecordTypeId By Country
     * @param country Country
     * @param isPartner isPartner
     * @return String
    **/
    public static String getAddressRecordTypeByCountry(String country, Boolean isPartner) {
        Id recordTypeId;

        if(country.equalsIgnoreCase('SPAIN') && isPartner){
            recordTypeId = Schema.SObjectType.XC_Address__c.getRecordTypeInfosByDeveloperName().get('XC_ESP_Address_Partner').getRecordTypeId();

        } else if(!country.equalsIgnoreCase('SPAIN') && isPartner){
            recordTypeId = Schema.SObjectType.XC_Address__c.getRecordTypeInfosByDeveloperName().get('XC_GLO_Address_Partner').getRecordTypeId();

        } else if(country.equalsIgnoreCase('SPAIN') && !isPartner){
            recordTypeId = Schema.SObjectType.XC_Address__c.getRecordTypeInfosByDeveloperName().get('XC_Address_Spain').getRecordTypeId();

        } else if(!country.equalsIgnoreCase('SPAIN') && !isPartner){
            recordTypeId = Schema.SObjectType.XC_Address__c.getRecordTypeInfosByDeveloperName().get('XC_Address_Global').getRecordTypeId();
        }

        return recordTypeId;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to populate a Work order record with data incoming from an address.
     * @param wo WorkOrder
     * @param address Address
    **/
    public static void populateAddressFieldsFromAddress(WorkOrder wo, XC_Address__c address){
        wo.City = address.XC_City__c;
        wo.Country = address.XC_AddressCountry__c;
        wo.PostalCode = address.XC_PostalCode__c;
        wo.Street = address.XC_Address__c;
        if(String.isNotBlank(address.XC_StreetTypeText__c) && String.isNotBlank(address.XC_StreetNumber__c)){
            wo.Street = address.XC_StreetTypeText__c + ' ' + address.XC_Address__c.toLowerCase().capitalize() + ' ' + address.XC_StreetNumber__c;
        }
        wo.State = address.XC_PricinRegion__c; 
        wo.XC_Address__c = address.Id;
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to populate an address Wrapper from a Lead.
     * @param ld Lead to create wrapper
     * @return AddressWrapper
    **/
    public static AddressWrapper createWrapperFromLead(Lead ld){
        AddressWrapper wr = new AddressWrapper();
        wr.category = ld.XC_Category__c;
        wr.streetType = ld.XC_StreetType__c;
        wr.StreetTypeText = ld.XC_StreetTypeText__c;
        wr.address = ld.XC_Address__c;
        wr.zipCode = ld.XC_ZipCode__c;
        wr.province = ld.XC_Province__c;
        wr.municipality = ld.XC_Municipality__c;
        wr.city = ld.XC_City__c;
        wr.streetNumber = ld.XC_StreetNumber__c;
        wr.door = ld.XC_Door__c;
        wr.floor = ld.XC_Floor__c;
        wr.stair = ld.XC_Stair__c;
        wr.country = ld.XC_Country__c;
        wr.installationAddress = ld.XC_InstallationAddress__c;
        wr.deliveryAddress = ld.XC_DeliveryAddress__c;
        wr.billingAddress = ld.XC_BillingAddress__c;
        wr.accountId = ld.ConvertedAccountId;
        wr.leadId = ld.Id;
        wr.addressValid = !ld.XC_AddressLeadNotValidated__c;
        wr.isPartner = false;

        wr.electricCUPS = ld.XC_ElectricCUPS__c;
        wr.gasCUPS = ld.XC_GasCUPS__c;
        wr.validatedCups = ld.XC_AddressValidatedCUPS__c;
        wr.clarifType = ld.XC_ClarificatorType__c;
        wr.clarifValue = ld.XC_ClarificatorValue__c;
        
        wr.Region = ld.XC_Region__c;

        return wr;
    }
}