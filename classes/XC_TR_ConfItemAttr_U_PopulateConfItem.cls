/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
* @date Creation 08/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ConfItemAttr_U_PopulateConfItem – Class to populate fields on the configuration item father of the configuration item attribute.
*/ 
public without sharing class XC_TR_ConfItemAttr_U_PopulateConfItem {
    /**
	* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com   
	* @description Method starting in after insert 
	* @param listNew the list of inserted Configuration Item Attribute
	*/
    public static void onAfterInsert(List<NE__Order_Item_Attribute__c> listNew){
        populateBillingModelAndSize(listNew);
        fillSubsidySurveyFields(listNew);
        //populateSize(listNew);
    }
    /**
	* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com   
	* @description Method starting in after update
	* @param listNew the list of updated Configuration Item Attribute
	* @param mapOld the map old of updated Configuration Item Attribute
	* @param mapNew the map new of updated Configuration Item Attribute
	*/   
   	public static void onAfterUpdate(List<NE__Order_Item_Attribute__c> listNew, Map<Id,NE__Order_Item_Attribute__c> mapOld, Map<Id,NE__Order_Item_Attribute__c> mapNew){
        List<String> fieldList = new List<String>{'NE__Value__c'};       
        List<NE__Order_Item_Attribute__c> confItemAttributeListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!confItemAttributeListChanged.isEmpty()){
            populateBillingModelAndSize(confItemAttributeListChanged);
        }
        //populateSize(confItemAttributeListChanged);
    }
    
     /**
	* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com   
	* @description Method to populate XC_BIllingModel__c on configurationItem, father of the inserted/updated configuration item attribute.
	* @param confItemAttributeList 
	*/   
    public static void populateBillingModelAndSize(List<NE__Order_Item_Attribute__c> confItemAttributeList){
        Set<Id> itemBundleIds = new Set<Id>();
    	Map<String, String> orderItemAttributeWithFather = getConfigurationItemFather(confItemAttributeList, itemBundleIds);
        Map<Id, NE__OrderItem__c> ordItemBundleMap = new Map<Id, NE__OrderItem__c>();
        if(!itemBundleIds.isEmpty()){
           ordItemBundleMap = new Map<Id, NE__OrderItem__c> ([SELECT Id, NE__Bundle_Configuration__c FROM NE__OrderItem__c  WHERE XC_Product_Type__c =: Label.XC_CL_ProductTypeBundle AND NE__Bundle_Configuration__c != NULL AND Id IN: itemBundleIds]);
        }
        
        Map<Id, NE__OrderItem__c> orderItemMapToUpdate = new Map<Id, NE__OrderItem__c>();
        Set<String> picklistBillingModel = getBillingModelPicklist();
        picklistBillingModel.add('One shot');
        picklistBillingModel.add('By Milestone');
        picklistBillingModel.add('Installment Plan');
        picklistBillingModel.add('Capex');
        picklistBillingModel.add('Billing Plan');
        picklistBillingModel.add('Saving Sharing');
        picklistBillingModel.add('Revenue Sharing');
        // * @ Mod CV CR.NR2044 @date 07/10/2021 @Description Add new Billing model 'Billing Model Conguaglio     Start -->
        picklistBillingModel.add('Billing Model Conguaglio');
        //<--End
        Set<String> billingModelRecurring = new Set<String>{ 'Annual', 'Quarter', 'Biannual', 'Biennial',
                Label.XC_CL_PaymentModel_Quarter,
                Label.XC_CL_PaymentModel_Biannual,
                Label.XC_CL_PaymentModel_Biennial,
                Label.XC_CL_PaymentModel_BiMonthly,
                Label.XC_CL_PaymentModel_FourMonthly};
        for(NE__Order_Item_Attribute__c orItemAttribute : confItemAttributeList ){
            String orderItemFatherId = orderItemAttributeWithFather.get(orItemAttribute.Id);
            if(orItemAttribute.XC_DeveloperName__c == Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel && picklistBillingModel.contains(orItemAttribute.NE__Value__c)){
                if(!orderItemMapToUpdate.containsKey(orderItemFatherId)) {
                    orderItemMapToUpdate.put(orderItemFatherId, new NE__OrderItem__c(Id = orderItemFatherId));
                }
                orderItemMapToUpdate.get(orderItemFatherId).XC_BillingModel__c = orItemAttribute.NE__Value__c;
            } else if(orItemAttribute.XC_DeveloperName__c == Label.XC_CL_ConfigurationItemAttribute_DevFormaDePago 
                || (orItemAttribute.XC_DeveloperName__c == Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel && (orItemAttribute.NE__Value__c == Label.XC_CL_PaymentModel_Monthly || orItemAttribute.NE__Value__c  == Label.XC_CL_PaymentModel_Annual || billingModelRecurring.contains(orItemAttribute.NE__value__c)) ) ){
                if(!orderItemMapToUpdate.containsKey(orderItemFatherId)) {
                    orderItemMapToUpdate.put(orderItemFatherId, new NE__OrderItem__c(Id = orderItemFatherId));
                }
                orderItemMapToUpdate.get(orderItemFatherId).XC_BillingModel__c =  Label.XC_CL_BillingModel_Recurring;
            } else if(orItemAttribute.Name == Label.XC_CL_ConfigurationItemAttribute_Size){
                if(!orderItemMapToUpdate.containsKey(orderItemFatherId)) {
                    orderItemMapToUpdate.put(orderItemFatherId, new NE__OrderItem__c(Id = orderItemFatherId));
                }
                orderItemMapToUpdate.get(orderItemFatherId).XC_Size__c =  orItemAttribute.NE__Value__c;
            }
            if(ordItemBundleMap.containsKey(orderItemFatherId) && orderItemMapToUpdate.get(orderItemFatherId) != null && !String.isBlank(orderItemMapToUpdate.get(orderItemFatherId).XC_BillingModel__c)){
                String bundleId = ordItemBundleMap.get(orderItemFatherId).NE__Bundle_Configuration__c;
                if(!orderItemMapToUpdate.containsKey(bundleId)) {
                    orderItemMapToUpdate.put(bundleId, new NE__OrderItem__c(Id = bundleId));
                }   
                orderItemMapToUpdate.get(bundleId).XC_BillingModel__c =  orderItemMapToUpdate.get(orderItemFatherId).XC_BillingModel__c;
                orderItemMapToUpdate.get(bundleId).XC_Size__c =  orderItemMapToUpdate.get(orderItemFatherId).XC_Size__c;
            }
            //NR0247 - New Billing model - B2B_S-73 [MC 20200608]
            if(orItemAttribute.NE__Value__c == 'By Milestone'){
                if(orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c) != null){
                    orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c).XC_BillingModel__c = 'Milestone';
                }
            }
            if(orItemAttribute.NE__Value__c == 'Installment Plan'){
                if(orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c) != null){
                    orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c).XC_BillingModel__c = 'Installment plan';
                }
            }
            if(orItemAttribute.NE__Value__c == 'Usage'){
                if(orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c) != null){
                    orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c).XC_BillingModel__c = 'Usage';
                }
            }
            if(orItemAttribute.NE__Value__c == 'Capex'){
                if(orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c) != null){
                    orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c).XC_BillingModel__c = 'Capex';
                }
            }
            if(orItemAttribute.NE__Value__c == 'Billing Plan'){
                if(orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c) != null){
                    orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c).XC_BillingModel__c = 'Billing Plan';
                }
            }
            if(orItemAttribute.NE__Value__c == 'Saving Sharing'){
                if(orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c) != null){
                    orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c).XC_BillingModel__c = 'Saving Sharing';
                }
            }
            if(orItemAttribute.NE__Value__c == 'Revenue Sharing'){
                if(orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c) != null){
                    orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c).XC_BillingModel__c = 'Revenue Sharing';
                }
            }
            /*  Mod CV CR.NR2044
            Start -->
            * @date 07/10/2021
            * @Description Add new Billing model 'Billing Model Conguaglio'
            */
            if(orItemAttribute.Name  == Label.XC_CL_AdjustmentBillMod){
                if(orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c) != null){
                    orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c).XC_BillingModel__c = 'Recurring';
                    orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c).XC_RecurringPeriodType__c = orItemAttribute.NE__value__c;
                }
            }
            //<-- End
            if(billingModelRecurring.contains(orItemAttribute.NE__value__c)){
                if(orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c) != null){
                    orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c).XC_BillingModel__c = 'Recurring';
                    orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c).XC_RecurringPeriodType__c = orItemAttribute.NE__value__c;
                }
            }
            
             /*  Mod CV CR.NR1652
            Start -->
            * @date 02/11/2021
            * @author Tsiolaki Eleni - etsiolaki@deloitte.gr
            * @Description Populate the Particle field on the Configuration Item based on the value of the Revaluation Configuration Item Attribute
            */
            if(orItemAttribute.Name  == 'Revaluation'){
                if(!orderItemMapToUpdate.containsKey(orderItemFatherId)) {
                    orderItemMapToUpdate.put(orderItemFatherId, new NE__OrderItem__c(Id = orderItemFatherId));
                }
                if(orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c) != null){
                    System.debug('We found a revaluation attribute ' + orItemAttribute.NE__value__c);
                    if(orItemAttribute.NE__value__c == 'Yes') {
                        orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c).XC_Particle__c = 'FALSE';
                    } else {
                        orderItemMapToUpdate.get(orItemAttribute.NE__Order_Item__c).XC_Particle__c = 'TRUE';
                    }
                }
            }
            //<-- End

        }
      
        if(!orderItemMapToUpdate.isEmpty()){
            List<NE__OrderItem__c> childrenItem =  copyBillingModelFromFatherToChild(orderItemMapToUpdate);
            if(!childrenItem.isEmpty()){
                orderItemMapToUpdate.putAll(childrenItem);
            }
            XC_UTIL_Sobject.updateListRecords(orderItemMapToUpdate.values());
        }
    }

     /**
	* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com   
	* @description Method to retrieve the needeed info in the configuration item.
	* @param confItemAttributeList  
    * @param itemBundleIds  
	* @return orderItemAttributeWithFather  the map where the key is the id of the configuration item attribute and the value the Configuration Item father
	*/       
    public static Map<String, String> getConfigurationItemFather(List<NE__Order_Item_Attribute__c> confItemAttributeList, Set<Id> itemBundleIds){
        Map<String, String> orderItemAttributeWithFather = new Map<String, String>();
        for(NE__Order_Item_Attribute__c orderItemAttribute : confItemAttributeList){
            orderItemAttributeWithFather.put(orderItemAttribute.Id, orderItemAttribute.NE__Order_Item__c);
            itemBundleIds.add(orderItemAttribute.NE__Order_Item__c);
        }
        return orderItemAttributeWithFather;
    }


    /**
     * GetBillingModelPicklist.
     *
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @return the set of string
     * @description Method to get the picklist active values of BillingModel
     */
    public static Set<String> getBillingModelPicklist() {

        Set<String> picklistValues = new Set<String>();
        List<Schema.PicklistEntry> picklist = Schema.NE__OrderItem__c.XC_BillingModel__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pe : picklist) {
            if(pe.isActive()) {
                picklistValues.add(pe.getValue());
            }
        }

        return picklistValues;
    }

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : get Survey information based on configuration item attribute of subsidies - Italy subsidies management
     * @createdDate 2020-02-28
     */
    /*public static void fillSubsidySurveyFields(List<NE__Order_Item_Attribute__c> listNew){

        String currentUserLE = XC_UTIL_User.getLegalEntityFromUser();
        List<XC_CM_CountryLegalEntityAssociation__mdt> legalEntityCategory = [SELECT ID,DeveloperName,XC_LegalEntity__c,XC_Category__c
        FROM XC_CM_CountryLegalEntityAssociation__mdt
        WHERE XC_LegalEntity__c = : currentUserLE];


        if(legalEntityCategory[0].XC_Category__c=='B2C'){

            //check if subsidy configuration is in place
            List<NE__OrderItem__c> oiToUpdate = new List<NE__OrderItem__c>();
            List<XC_CreditAssignmentConfiguration__mdt> creditAssignmentConfs = [SELECT ID,XC_AdmittedMop__c,XC_IncentiveName__c
            ,XC_LegalEntity__c,XC_ProductCategory__c,XC_IncentiveValue__c,XC_Stream__c,XC_SurveyLink__c 
            FROM XC_CreditAssignmentConfiguration__mdt WHERE XC_LegalEntity__c = :currentUserLE AND XC_Stream__c = 'B2C' AND XC_OrganizationId__c = :UserInfo.getOrganizationId()];



            if(!creditAssignmentConfs.isEmpty() || Test.isRunningTest()){

                Map<String,XC_CreditAssignmentConfiguration__mdt> creditAssignmentCategoryMap = new Map<String,XC_CreditAssignmentConfiguration__mdt>();
                for(XC_CreditAssignmentConfiguration__mdt conf : creditAssignmentConfs){
                    String key = conf.XC_ProductCategory__c+'_'+conf.XC_IncentiveName__c+'_'+conf.XC_IncentiveValue__c;
                    creditAssignmentCategoryMap.put(key, conf);
                }

                System.Debug('ENTERED SUBSIDY CREDIT ASSIGNMENT FLOW');
                System.Debug('CREDIT ASSIGNMENTS CONF:: ' + creditAssignmentCategoryMap);


                //get attribute map to filter configurations
                List<String> oiIds = new List<String>();

                for(NE__Order_Item_Attribute__c oia : listNew){
                    oiIds.add(oia.NE__Order_Item__c);
                }

                Map<Id,NE__OrderItem__c> oisMap = new Map<Id,NE__OrderItem__c>([SELECT ID,NE__ProdName__c,
                XC_CreditAssignmentSurvey__c,NE__ProdId__r.XC_LIC_Product_Name__c,NE__OrderId__r.NE__OptyId__r.XC_Contact__c,
                NE__CatalogItem__c,NE__Item_Code__c,XC_Product_Subtype__c,XC_RelatedProduct__c,NE__Bundle_Configuration__c
                ,NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c,NE__Bundle_Configuration__r.XC_Product_Subtype__c,NE__OrderId__r.NE__Type__c, (SELECT Id,XC_DeveloperName__c,NE__Value__c FROM NE__Order_Item_Attributes__r)
                FROM NE__OrderItem__c WHERE ID IN:oiIds AND XC_Product_Subtype__c = :Label.XC_CL_ProductSubtypeIncentive AND NE__Bundle_Configuration__c!=null]);

                //getfeedback survey configuration is based on configurationitemattribute values such as incentive type 
                //and product subtype of the considered item
                if(!oisMap.isEmpty()){

                    for(NE__OrderItem__c incentiveOi : oisMap.values()){

                        if(incentiveOi.NE__OrderId__r.NE__Type__c==Label.XC_CL_Configuration_TypeInOrder || incentiveOi.NE__OrderId__r.NE__Type__c==Label.XC_CL_Configuration_TypeChangeOrder){
                            //building survey key to retrieve the correct URL
                            Map<String,String> attrNameValueMap = new Map<String,String>();
                            String surveyKey = incentiveOi.NE__Bundle_Configuration__r.XC_Product_Subtype__c+'_';
                            String equipmentKey = incentiveOi.NE__Bundle_Configuration__c + '_' + incentiveOi.NE__Bundle_Configuration__r.XC_Product_Subtype__c;
                            for(NE__Order_Item_Attribute__c attr : incentiveOi.NE__Order_Item_Attributes__r){
                                attrNameValueMap.put(attr.XC_DeveloperName__c,attr.NE__Value__c);
                            }
                            surveyKey += attrNameValueMap.get(Label.XC_CL_Incentive_Type)+'_'+attrNameValueMap.get(Label.XC_CL_Incentive_Amount);
                            System.Debug('INCENTIVE SURVEY KEY ::: ' + surveyKey + 'FOUND:: ' + creditAssignmentCategoryMap.containsKey(surveyKey));
                            NE__OrderItem__c bundleItem = new NE__OrderItem__c(Id = incentiveOi.NE__Bundle_Configuration__c);

                                if(creditAssignmentCategoryMap.containsKey(surveyKey)){
                                    incentiveOi.XC_CreditAssignmentSurvey__c = creditAssignmentCategoryMap.get(surveyKey).XC_SurveyLink__c+'?ConfItem='+incentiveOi.Id+'&ContactID='+incentiveOi.NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
                                    /***CREDIT ASSIGNMENT AMOUNT CALCULATION****/
                                    /*Decimal totalBundleAmount =  incentiveOi.NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c;
                                    Integer incentiveAmount = Integer.valueOf(attrNameValueMap.get(Label.XC_CL_Incentive_Amount));
                                    if(totalBundleAmount != null){
                                        Decimal creditAssignmentAmount = ((totalBundleAmount / 100) * incentiveAmount).round();
                                        incentiveOi.XC_CreditAssignmentAmount__c = creditAssignmentAmount;
                                        bundleItem.XC_CreditAssignmentAmount__c = creditAssignmentAmount;
                                    }
                                    oiToUpdate.add(incentiveOi);

                                }

                            //other bundle parent item field updates - 20200408 - FI
                            bundleItem.XC_BundleIncentiveText__c = incentiveOi.NE__Bundle_Configuration__r.XC_Product_Subtype__c + '_' + attrNameValueMap.get(Label.XC_CL_Incentive_Type);
                            bundleItem.XC_IncentiveName__c = incentiveOi.NE__ProdName__c;
                            oiToUpdate.add(bundleItem);
    
                        }
                    }
                    if(!oiToUpdate.isEmpty()){
                        XC_UTIL_Sobject.updateListRecords(oiToUpdate);
                    }    
                }
            }
        }
    }*/



    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description : get Survey information based on configuration item attribute of subsidies - Italy subsidies management
     * @createdDate 2020-02-28
     * @modificatedDate 2020-04-27 by Nicola Mariniello - nmariniello@deloitte.it
     */
    public static void fillSubsidySurveyFields(List<NE__Order_Item_Attribute__c> listNew){

        List<String> oiIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'NE__Order_Item__c');
        Map<Id,NE__OrderItem__c> oisMap = new Map<Id,NE__OrderItem__c>([SELECT ID, NE__OrderId__r.XC_Segment__c, NE__ProdName__c, XC_CreditAssignmentSurvey__c,NE__ProdId__r.XC_LIC_Product_Name__c,NE__OrderId__r.NE__OptyId__r.XC_Contact__c,
                                                                            NE__CatalogItem__c,NE__Item_Code__c,XC_Product_Subtype__c,XC_Product_Type__c,XC_RelatedProduct__c,NE__Bundle_Configuration__c,
                                                                            NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c,NE__Bundle_Configuration__r.XC_Product_Subtype__c,NE__OrderId__r.NE__Type__c, 
                                                                            (SELECT Id,XC_DeveloperName__c,NE__Value__c FROM NE__Order_Item_Attributes__r)
                                                                       	    FROM NE__OrderItem__c
        																    WHERE ID IN:oiIds AND (XC_Product_Subtype__c = :Label.XC_CL_ProductSubtypeIncentive OR XC_Product_Type__c = :Label.XC_CL_ProductTypeEquipment) AND NE__Bundle_Configuration__c!=null AND (NE__OrderId__r.XC_LegalEntity__c =: Label.XC_CL_LegalEntity_Italy OR NE__OrderId__r.XC_LegalEntity__c =: Label.XC_CL_LegalEntity_EnelXMobilityItalia) AND NE__OrderId__r.XC_Segment__c = 'B2C']);


        //getfeedback survey configuration is based on configurationitemattribute values such as incentive type 
        //and product subtype of the considered item
        if(!oisMap.isEmpty()){


            List<NE__OrderItem__c> incentiveOis = new List<NE__OrderItem__c>();
            Map<String,NE__OrderItem__c> incentiveEquipmentMap = new Map<String,NE__OrderItem__c>();

            for(NE__OrderItem__c oi : oisMap.values()){
                if(oi.XC_Product_Subtype__c == Label.XC_CL_ProductSubtypeIncentive){
                    incentiveOis.add(oi);
                }
            }

            for(NE__OrderItem__c incentiveOi : incentiveOis){
                for(NE__OrderItem__c oi : oisMap.values()){
                    if(!incentiveEquipmentMap.containsKey(incentiveOi.Id) 
                    && oi.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment 
                    && oi.NE__Bundle_Configuration__c == incentiveOi.NE__Bundle_Configuration__c){
                        if(oi.NE__Bundle_Configuration__r.XC_Product_Subtype__c == oi.XC_Product_Subtype__c || (oi.XC_Product_Subtype__c == 'Photovoltaic PP')){ //eccezione per fotovoltaico PP
                            incentiveEquipmentMap.put(incentiveOi.Id,oi);
                        }
                    }
                }
            }


            //String currentUserLE = XC_UTIL_User.getLegalEntityFromUser();

            //check if subsidy configuration is in place
            List<NE__OrderItem__c> oiToUpdate = new List<NE__OrderItem__c>();
            List<XC_CreditAssignmentConfiguration__mdt> creditAssignmentConfs = [SELECT ID,XC_AdmittedMop__c,XC_IncentiveName__c ,XC_LegalEntity__c,XC_ProductCategory__c,XC_IncentiveValue__c,XC_Stream__c,XC_SurveyLink__c 
            FROM XC_CreditAssignmentConfiguration__mdt
            WHERE (XC_LegalEntity__c = :Label.XC_CL_LegalEntity_Italy OR XC_LegalEntity__c = :Label.XC_CL_LegalEntity_EnelXMobilityItalia) AND XC_Stream__c = 'B2C' AND XC_OrganizationId__c = :UserInfo.getOrganizationId()];

            if(!creditAssignmentConfs.isEmpty() || Test.isRunningTest()){

                Map<String,XC_CreditAssignmentConfiguration__mdt> creditAssignmentCategoryMap = new Map<String,XC_CreditAssignmentConfiguration__mdt>();
                for(XC_CreditAssignmentConfiguration__mdt conf : creditAssignmentConfs){
                    String key = conf.XC_ProductCategory__c+'_'+conf.XC_IncentiveName__c+'_'+conf.XC_IncentiveValue__c;
                    creditAssignmentCategoryMap.put(key, conf);
                }

                System.Debug('ENTERED SUBSIDY CREDIT ASSIGNMENT FLOW');
                System.Debug('CREDIT ASSIGNMENTS CONF:: ' + creditAssignmentCategoryMap);
                

                for(NE__OrderItem__c incentiveOi : incentiveOis){

                    if(incentiveOi.NE__OrderId__r.NE__Type__c==Label.XC_CL_Configuration_TypeInOrder || incentiveOi.NE__OrderId__r.NE__Type__c==Label.XC_CL_Configuration_TypeChangeOrder){
                        //building survey key to retrieve the correct URL
                        NE__OrderItem__c relatedEquipment = incentiveEquipmentMap.get(incentiveOi.Id);
                        Map<String,String> attrNameValueMap = new Map<String,String>();
                        String surveyKey = relatedEquipment.XC_Product_Subtype__c+'_';
                        for(NE__Order_Item_Attribute__c attr : incentiveOi.NE__Order_Item_Attributes__r){
                            attrNameValueMap.put(attr.XC_DeveloperName__c,attr.NE__Value__c);
                        }

                        surveyKey += attrNameValueMap.get(Label.XC_CL_Incentive_Type)+'_'+attrNameValueMap.get(Label.XC_CL_Incentive_Amount);
                        System.Debug('INCENTIVE SURVEY KEYINCENTIVE SURVEY KEY ::: ' + surveyKey + 'FOUND:: ' + creditAssignmentCategoryMap.containsKey(surveyKey));
                        NE__OrderItem__c bundleItem = new NE__OrderItem__c(Id = incentiveOi.NE__Bundle_Configuration__c);

                            if(creditAssignmentCategoryMap.containsKey(surveyKey)){
                                incentiveOi.XC_CreditAssignmentSurvey__c = creditAssignmentCategoryMap.get(surveyKey).XC_SurveyLink__c+'?ConfItem='+incentiveOi.Id+'&ContactID='+incentiveOi.NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
                                /***CREDIT ASSIGNMENT AMOUNT CALCULATION****/
                                Decimal totalBundleAmount =  incentiveOi.NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c;
                                Integer incentiveAmount = ( Integer.valueOf(attrNameValueMap.get(Label.XC_CL_Incentive_Amount)) >100 ? 100: Integer.valueOf(attrNameValueMap.get(Label.XC_CL_Incentive_Amount))) ;
                                if(totalBundleAmount != null){

                                    Decimal creditAssignmentAmount =  ((totalBundleAmount / 100) * incentiveAmount);

                                    incentiveOi.XC_CreditAssignmentAmount__c = creditAssignmentAmount;
                                    bundleItem.XC_CreditAssignmentAmount__c = creditAssignmentAmount;
                                }
                                oiToUpdate.add(incentiveOi);

                            }

                        //other bundle parent item field updates - 20200408 - FI
                        bundleItem.XC_BundleIncentiveText__c = relatedEquipment.XC_Product_Subtype__c + '_' + attrNameValueMap.get(Label.XC_CL_Incentive_Type) + '_' + attrNameValueMap.get(Label.XC_CL_Incentive_Amount);
                        bundleItem.XC_IncentiveName__c = incentiveOi.NE__ProdName__c;
                        oiToUpdate.add(bundleItem);

                    }
                }
                if(!oiToUpdate.isEmpty()){
                    XC_UTIL_Sobject.updateListRecords(oiToUpdate);
                }
            }
        }

    }


     /**
	* @author Andrea Di Cicco   
	* @description Method used to copy fathers' billing model to the Children
	* @param confItemAttributeList  
    * @param itemBundleIds  
	* @return orderItemAttributeWithFather  the map where the key is the id of the configuration item attribute and the value the Configuration Item father
    */  
    public static List<NE__OrderItem__c> copyBillingModelFromFatherToChild(Map<Id, NE__OrderItem__c> orderItemMapToUpdate){
        List<NE__OrderItem__c> childrenItem = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> listchildrenItem = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> lischildrenItem = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> childrenToUpdate = new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            childrenItem = [SELECT  id, XC_BillingModel__c, NE__Root_Order_Item__c FROM  NE__OrderItem__c where (XC_Segment__c ='B2B' OR XC_Segment__c ='B2G') and NE__Root_Order_Item__c IN: orderItemMapToUpdate.keySet() ];
        }

        if(!childrenItem.isEmpty()){
            for(NE__OrderItem__c oi : childrenItem){
                if(orderItemMapToUpdate.get(oi.Id) != null ){
                    continue;
                }
                    // * @ Mod CV CR.NR2044 @date 13/10/2021 @Description skip copyBillingModelFromFatherToChild for Conguaglio -->
                    if(orderItemMapToUpdate.get(oi.NE__Root_Order_Item__c) != null && orderItemMapToUpdate.get(oi.NE__Root_Order_Item__c).NE__ProdName__c != Label.XC_CL_AdjustmentProdName){
                    oi.XC_BillingModel__c = orderItemMapToUpdate.get(oi.NE__Root_Order_Item__c).XC_BillingModel__c;
                    childrenToUpdate.add(oi);
                }
            }
        }
        return childrenToUpdate;
    }

}