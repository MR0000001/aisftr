/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation 29/10/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Contract – Util class for Contract methods
*/  

public without sharing class XC_UTIL_Contract { 

    /** @description ContractIFWrapper */
    public class ContractIFWrapper {
        // GET Inbound
        public String AccountID;
        public Date ContractStartDate;
        public Integer ContractTerm;
        public String Currency_x;
        public String Status;
        public String ContractType;
        public String OwnerExpirationNotice;
        public String AssetID;
        public String AddressID;
        
        // GET Outbound
        public String HighDate;
        public String LowDate;
        public String StartDateVersion;
        public String Version;
        public String ContractNumber;
        public String ServiceProductName;
        public String CNAE;
        public String ShippingAddressType;
        public String ContractedPower1;
        public String ContractedPower2;
        public String ContractedPower3;
        public String CIEAuthorizedMaximumPower;
        public Date RegistrationDate;
        public Date StartVersionDate;
        public Date WithdrawalDate;
        public String CUPS;
        public String PODaddress;
        public String Distributor;
        public String Tariff;
        public String BusinessLine;
        public String DeliveryAddress;
        public String Consumption;
        public String MaximumContractedPower;
        public String SelfConsumption;
        public String ProductName;
        public String OwnerCompany;
        public String ContractNotCuttable;
        public String TypeOfSocialBonus;
        public String TypeShippingAddress;
        public String ShippingAddress;
        public String BillingPeriod;
        public String Telemeasure;
        public String BankAccountHolder;
        public String CollectionMode;
        public String Rate;
        public String EnergySupplier;
        public String PaymentMethod;

        public String CommodityBillingCycleFrequency;
        public String AddressData;
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Method to create a List of Contracts related to Orders.
     * @param listOrders
    **/

    public static void createContracts(List<NE__Order__c> listOrders){ 
        List<Contract> contractToInsert = new List<Contract>();
        /*List<String> listCountries = XC_UTIL_Sobject.getListFieldValues(listOrders, 'XC_Country__c'); 
        Map<String, Id> mapCountryRecordTypeId = getRecordTypeByCountry(listCountries); */
        Set<String> legalEntitySet = XC_UTIL_Sobject.getSetIdsStringOnField(listOrders, 'XC_LegalEntity__c');
        Set<String> streamSet = XC_UTIL_Sobject.getSetIdsStringOnField(listOrders, 'XC_Segment__c'); 
        Map<String, XC_SegmentUtilities.RTConfigWrapper> recordTypesMap = XC_SegmentUtilities.getLegEntityConfig(legalEntitySet, streamSet);

        for(NE__Order__c order : listOrders){
            String country = order.XC_Country__c.toUpperCase();  
            Contract newContract = new Contract(); 
            newContract.Opportunity__c = order.NE__OptyId__c;
            newContract.XC_LegalEntity__c = order.XC_LegalEntity__c;
            newContract.XC_Segment__c = order.XC_Segment__c;
			newContract.Status = Label.XC_CL_Contract_Pending;
			newContract.AccountId = order.NE__AccountId__c;
			newContract.XC_Configurations__c = order.Id;
			if(order.XC_Segment__c != 'B2B' && order.XC_Segment__c != 'B2G') {
                newContract.ContractTerm = 12;
            }
            newContract.StartDate = Date.today();

            //CR2249 - Gestione date contrattuali - federico.manni@accenture.com R1 2022
            if(order.XC_Segment__c != 'B2C'){ 
                Map<String, Date> dates = new Map<String, Date>();
                dates = XC_TR_Contract_U_PopulateFromRootOi.populatefields(order.NE__OptyId__c);
                System.debug('@@@@ Date: '+dates);
                if(dates!=null && !dates.keySet().isEmpty()){
                    for(String dateis : dates.keySet()){
                        if('Start'.equalsIgnoreCase(dateis)){
                            if(dates.get(dateis)!=null){
                                newContract.StartDate = dates.get(dateis);
                            }
                        }
                        if('End'.equalsIgnoreCase(dateis)){
                            if(dates.get(dateis)!=null){
                                newContract.EndDate = dates.get(dateis);
                            }
                        }
                    }
                }
            }
            //mridul.b.jain@accenture.com NR2299 4/5/22 start
            else if('B2C'.equalsIgnoreCase(order.XC_Segment__c) && ('EnelXMobilityRomania'.equalsIgnoreCase(order.XC_LegalEntity__c) || 'EnelXRomania'.equalsIgnoreCase(order.XC_LegalEntity__c)) && 'Romania'.equalsIgnoreCase(order.XC_Country__c)){
                newContract.XC_MarketLegalEntity__c = order.XC_MarketLegalEntity__c;
            } 
            //mridul.b.jain@accenture.com NR2299 4/5/22 end

            //newContract.recordTypeId = mapCountryRecordTypeId.get(country);
            if(recordTypesMap.get(order.XC_LegalEntity__c+order.XC_Segment__c) != null && String.isNotBlank(recordTypesMap.get(order.XC_LegalEntity__c+order.XC_Segment__c).contractRT)) {
                newContract.recordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(recordTypesMap.get(order.XC_LegalEntity__c+order.XC_Segment__c).contractRT).getRecordTypeId();
            }

            contractToInsert.add(newContract);
        } 
        XC_UTIL_Sobject.insertListRecords(contractToInsert);
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Method to get Contract RecordTypeId By Country.
     * @return Map<String,Id>
     * @param listCountries
    **/
    /*public static Map<String, Id> getRecordTypeByCountry(List<String> listCountries){

        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalEnConfigMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_Country__c, XC_RecordType_Contract__c 
                                                                                                                            FROM XC_CM_LegalEntity_Configuration__mdt
                                                                                                                            WHERE XC_Country__c IN :listCountries AND XC_OrgId__c =: UserInfo.getOrganizationId()]);

        Map<String, String> mapCountryRecordTypeName = new Map<String, String>();
        for(XC_CM_LegalEntity_Configuration__mdt legalEnConfig : legalEnConfigMap.values()) {
            mapCountryRecordTypeName.put(legalEnConfig.XC_Country__c.toUpperCase(), legalEnConfig.XC_RecordType_Contract__c);
        }

        return XC_UTIL_SObject.getRecordTypeMapByCountry('Contract', listCountries, mapCountryRecordTypeName);
	}*/




}