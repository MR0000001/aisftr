/**
 * The Class XC_TR_FormCase_U_PopulateFields.
 *
 * @author            : Dimitris Karnavas - dkarnavas@deloitte.gr & Eleni Tsiolaki - etsiolaki@deloitte.gr
 * @date Creation     : 24/02/2022
 * @date Modification : dd/mm/yyyy
 * @description       : Class to populate Form Case fields
 **/ 

public without sharing class XC_TR_FormCase_U_PopulateFields {

    /**
    * populateFields.
    * @param listNew the list new
    * @description populate form case fields
    */
    public static void populateFields(List<XC_FormCase__c> listNew, Boolean bypassBeforeInsert) {
        Set<Id> productsConsumedSet = new Set<Id>();
        Set<String> formCountry = new Set<String>();
        Set<Id> formRecordType = new Set<Id>();

        //map to categorize each form by a 'country_recordTypeId' key
        Map<String,List<XC_FormCase__c>> mapCounter = new Map<String,List<XC_FormCase__c>>();

        Map<String,Decimal> orderByCounterType = new Map<String,Decimal>();

        for(XC_FormCase__c form : listNew){
            productsConsumedSet.add(form.XC_Product_Consumed__c);
            formCountry.add(form.XC_Country__c);
            formRecordType.add(form.RecordTypeId);

            String counterType = form.XC_Country__c + '_' + form.RecordTypeId;
            System.debug(form.RecordTypeId);
            if(!mapCounter.containsKey(counterType)){
                List<XC_FormCase__c> listFormCase = new List<XC_FormCase__c>();
                listFormCase.add(form);
                mapCounter.put(counterType,listFormCase);
                orderByCounterType.put(counterType,1);
                form.XC_OrderNumber__c = 1;
            }
            else{
                mapCounter.get(counterType).add(form);
                form.XC_OrderNumber__c = orderByCounterType.get(counterType) + 1;
                orderByCounterType.put(counterType, form.XC_OrderNumber__c);
            }

            //for each form, initialize the Identification code
            //later, this value will change to its latest correct value according to the sequence followed for each 'country_recordTypeId' key
            String recordTypeName = Schema.getGlobalDescribe().get('XC_FormCase__c').getDescribe().getRecordTypeInfosById().get(form.RecordTypeId).getName();
            form.XC_Identification_Code__c = recordTypeName + '_' + System.Today().year() + '_' + form.XC_OrderNumber__c +'_' + form.XC_Country__c;
            form.XC_Year__c = String.valueOf(System.Today().year());
            
        } 
        
        Map<Id,XC_ProductConsumed__c> productsConsumedMap = new Map<Id,XC_ProductConsumed__c>([
            SELECT Id,
             XC_UnitPrice__c,
             XC_ProductCode__c,
             XC_Product2Id__c,
            XC_WorkOrderLineItem__r.XC_ShipToCity__c,
            XC_WorkOrderLineItem__r.XC_ShipToCountry__c,
            XC_WorkOrderLineItem__r.XC_ShipToStateProvince__c,
            XC_WorkOrderLineItem__r.XC_ShipToStreet__c,
            XC_WorkOrderLineItem__r.XC_ShipToZipPostalCode__c,
            XC_WorkOrderLineItem__r.WorkOrderId,
            XC_WorkOrderLineItem__r.WorkOrder.City,
            XC_WorkOrderLineItem__r.WorkOrder.Country,
            XC_WorkOrderLineItem__r.WorkOrder.PostalCode,
            XC_WorkOrderLineItem__r.WorkOrder.Street,
            XC_WorkOrderLineItem__r.WorkOrder.State,
            XC_WorkOrderLineItem__r.WorkOrder.AssetId,
            XC_WorkOrderLineItem__r.WorkOrder.Asset.SerialNumber,
            XC_WorkOrderLineItem__r.WorkOrder.Asset.InstallDate,
            XC_WorkOrderLineItem__r.WorkOrder.XC_PreferredPartner__c,
            XC_WorkOrderLineItem__r.WorkOrder.XC_LegalEntity__c,
            XC_WorkOrderLineItem__r.WorkOrder.XC_AssignedResource__r.XC_Contact__c
            FROM XC_ProductConsumed__c
            WHERE Id IN:productsConsumedSet
        ]);

        for(XC_FormCase__c form : listNew){
            if(!String.isBlank(form.XC_Product_Consumed__c) && !bypassBeforeInsert){ 
                form.XC_EVSE_Serial_Number__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.WorkOrder?.Asset?.SerialNumber;
                form.XC_Asset__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.WorkOrder?.AssetId;
                form.XC_Spare_Part_Code__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_ProductCode__c;
                form.XC_WorkOrder__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r.WorkOrderId;
                form.XC_Installer__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.WorkOrder?.XC_PreferredPartner__c;
                form.XC_Pick_Up_City__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.WorkOrder?.City;
                form.XC_Pick_Up_Country__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.WorkOrder?.Country;
                form.XC_Pick_Up_State_Province__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.WorkOrder?.State;
                form.XC_Pick_Up_Street__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.WorkOrder?.Street;
                form.XC_Pick_Up_Zip_Code__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.WorkOrder?.PostalCode;
                form.XC_Return_to_City__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.XC_ShipToCity__c;
                form.XC_Return_to_Country__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.XC_ShipToCountry__c;
                form.XC_Return_to_State_Province__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.XC_ShipToStateProvince__c;
                form.XC_Return_to_Street__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.XC_ShipToStreet__c;
                form.XC_Return_to_Zip_Code__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.XC_ShipToZipPostalCode__c;
                form.XC_Contact__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.WorkOrder?.XC_AssignedResource__r?.XC_Contact__c;
                form.XC_Spare_Part_Installation_Date__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.WorkOrder?.Asset?.InstallDate;
                form.XC_CostOfTheSparePartUsed__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_UnitPrice__c;
                form.XC_Product2__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_Product2Id__c;
                form.XC_Legal_Entity__c = productsConsumedMap.get(form.XC_Product_Consumed__c)?.XC_WorkOrderLineItem__r?.WorkOrder?.XC_LegalEntity__c;
            }
        }

        //retrieve the latest value in the sequence for each group of country and record type
        AggregateResult[] maxIdentificationCodes = [SELECT MAX(XC_OrderNumber__c),RecordTypeId,XC_Country__c, XC_Year__c  FROM XC_FormCase__c WHERE XC_Country__c IN:formCountry AND RecordTypeId IN:formRecordType AND XC_Year__c =: String.valueOf(System.Today().year())  GROUP BY RecordTypeId,XC_Country__c, XC_Year__c];

        for (AggregateResult ar : maxIdentificationCodes) {
            Integer counter = 0;
            //take the year part of the Identification code :: RECTYPE_YEAR_SEQUENCE_COUNTRY
            Integer lastIdentCodeYear = Integer.valueOf(String.valueOf(ar.get('XC_Year__c')));
            //if the current year is greater than the year in the latest identification code, start the sequence from start
            Integer lastIdentCode = System.Today().year() > lastIdentCodeYear ?  0 : Integer.valueOf(String.valueOf(ar.get('expr0')));
            String counterType = ar.get('XC_Country__c') + '_' + ar.get('RecordTypeId');
            for(XC_FormCase__c form : mapCounter.get(counterType)){
                lastIdentCode += 1;
                String newCode = String.valueOf(lastIdentCode);
                String recTypeId = String.valueOf(ar.get('RecordTypeId'));
                String recordTypeName = Schema.getGlobalDescribe().get('XC_FormCase__c').getDescribe().getRecordTypeInfosById().get(recTypeId).getName();
                form.XC_Identification_Code__c = recordTypeName + '_' + form.XC_Year__c + '_' + newCode + '_' + ar.get('XC_Country__c');
                form.XC_OrderNumber__c = lastIdentCode;
               
            }
        }
    }
}