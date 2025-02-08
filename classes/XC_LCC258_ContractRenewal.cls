/**
 * @author: Eleni Tsiolaki - etsiolaki@deloitte.gr
 * @date Creation 08/10/2021
 * @date Modification 
 * @description XC_LCC258_ContractRenewal – Controller of XC_LCP258_ContractRenewal (to manage the Contract Management: Renewal - Change end date of contract(s) )
 */


public with sharing class XC_LCC258_ContractRenewal {
    

    /**
     * @author Eleni Tsiolaki - etsiolaki@deloitte.gr
     * @date Creation 09/10/2021
     * @date Modification dd/mm/yyyy
     * @description 
     * @return XC_UTIL_ResultWrapper
     */ 
    @AuraEnabled 
    public static XC_UTIL_ResultWrapper initComponent(){
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper(); 
        resWrapper.success = false;
        
        List<String> zones = XC_UTIL_Sobject.getPicklistValues('Contract', 'XC_Zone__c');
        List<String> businessLines = XC_UTIL_Sobject.getPicklistValues('Opportunity', 'XC_BusinessLine__c');
        List<String> legalEntities = XC_UTIL_Sobject.getPicklistValues('Contract', 'XC_LegalEntity__c');

        if(!businessLines.isEmpty() && !legalEntities.isEmpty()){
            resWrapper.success = true;
            resWrapper.resultMessage ='';
            resWrapper.fieldName = JSON.serialize(businessLines);
            resWrapper.fieldName2 = JSON.serialize(legalEntities);
            resWrapper.fieldName3 = JSON.serialize(zones);
        }

        return resWrapper;
    }


    /**
     * @description Search contracts based on the input fields in the component
     * @param paramsMap input Map<String,Object>
     * @return XC_UTIL_ResultWrapper
     **/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper searchContracts(Map<String,Object> paramsMap){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();

        String contractNumber = String.valueOf(paramsMap.get('contractNumber'));
        String endDateString = String.valueOf(paramsMap.get('endDate'));
        String contractZone = String.escapeSingleQuotes(String.valueOf(paramsMap.get('contractZone')));
        String businessLine = String.valueOf(paramsMap.get('businessLine'));
        String legalEntity = String.valueOf(paramsMap.get('legalEntity'));

        Date endD = Date.valueOf(endDateString);
        String endDate = DateTime.newInstance(endD.year(),endD.month(),endD.day()).format('yyyy-MM-dd');
		//START-CR772-elisa.caldini@accenture.com-28.03.2022
        String endDateMinString = String.valueOf(paramsMap.get('endDateMin'));
        Date endDMin = Date.valueOf(endDateMinString);
        String endDateMin = DateTime.newInstance(endDMin.year(),endDMin.month(),endDMin.day()).format('yyyy-MM-dd');
        //END-CR772-elisa.caldini@accenture.com-28.03.2022												  
        String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('Contract');
        query += ' , Account.Name,  Opportunity__r.XC_BusinessLine__c, (SELECT XC_Status__c, XC_Contract__c, XC_EndDateBeforeExtension__c, XC_EndDateAfterLastExtension__c, XC_RevaluationEffectiveDate__c  FROM Contract_Amendments__r order by XC_EndDateAfterLastExtension__c ASC), ';
        query += ' (SELECT Id, NE__Order_Config__r.Name FROM assets1__r WHERE NE__Order_Config__r.NE__Type__c =\'' +  Label.XC_CL_Configuration_TypeDisconnection +'\' OR ';
        query += ' (NE__Order_Config__r.NE__Type__c =\'' +  Label.XC_CL_Configuration_TypeChangeOrder + '\' AND ';
        query += ' ((NE__Order_Config__r.XC_Status__c =\'' + Label.XC_CL_Order_StatusCancelled +'\' AND NE__Order_Config__r.XC_NumberOfConfigurationItem__c > 0) OR (NE__Order_Config__r.XC_Status__c !=\'' + Label.XC_CL_Order_StatusCancelled + '\' AND  NE__Order_Config__r.XC_Status__c != \'' +  Label.XC_CL_Configuration_Closed + '\' )))) ' ;
        query += ' FROM Contract ';
        query += ' WHERE EndDate <= ' + endDate;
        query += ' AND XC_Zone__c = \'' + contractZone + '\'';
        //query += ' AND Status = \'Active\' AND EndDate >= TODAY'; //CR772-elisa.caldini@accenture.com-28.03.2022
        query += ' AND Status = \'Active\' ';//CR772-elisa.caldini@accenture.com-28.03.2022-remove filter endDate
        query += ' AND  EndDate >= ' + endDateMin;//CR772-elisa.caldini@accenture.com-01.06.2022																									 
		
        if (String.isNotBlank(contractNumber)) {
            query += ' AND ContractNumber = \'' + contractNumber + '\'';
        }
												
        if (paramsMap.get('startDate') != null) {
            String startDateString = String.valueOf(paramsMap.get('startDate'));
            Date startD = Date.valueOf(startDateString);
            String startDate = DateTime.newInstance(startD.year(),startD.month(),startD.day()).format('yyyy-MM-dd');
            query += ' AND  StartDate = ' + startDate;
        }
        if (String.isNotBlank(businessLine)) {
            query += ' AND  Opportunity__r.XC_BusinessLine__c = \'' + businessLine + '\'';
        }
        if (String.isNotBlank(legalEntity)) {
            query += ' AND XC_LegalEntity__c = \'' + legalEntity + '\'';
        }

        System.debug('Query is: ' + query);
        List<Contract> allContracts = Database.query(query);
        //List<Contract> contracts = Database.query(query);
        

        //[Begin - Gestione Cruscotto - excludes a contract that has an error or a scheduled amendment  - 24/03/2022]
        Map<Id, String> contrIdErrorMessage = new Map<Id, String>();
        List<Contract> contracts = filterContract(allContracts, contrIdErrorMessage);
       //[End - Gestione Cruscotto - excludes a contract that has an error or a scheduled amendment  - 24/03/2022]

        if(contracts.size() > 0) {
										
			//XC_ContractManagement_D.DataWrapper dataReturned = XC_ContractManagement_D.getRecurringContracts(contracts, false);																													 
			//START-CR772-elisa.caldini@accenture.com-30.05.2022
            XC_ContractManagement_D.DataWrapper dataReturned = XC_ContractManagement_D.getRecurringContractsFromAssetByRangeDate(contracts,endDateMin,endDate);
            //END-CR772-elisa.caldini@accenture.com-30.05.2022
			rw.success = true;
            rw.resultMessage = '';
            rw.fieldName = JSON.serialize(dataReturned.contracts);
            rw.fieldName2 = JSON.serialize(dataReturned.assetIds);
            rw.fieldName3 = JSON.serialize(dataReturned.orderItemIds);
            rw.fieldName4 = JSON.serialize(dataReturned.orderItemContractMap);
        }else if(allContracts.size() == 1 && !String.isBlank(contractNumber)){ 
            //[Begin - Gestione Cruscotto - Exlude hat has at least one contract amendment in error  - 24/03/2022]
            // the contract found is unique and has at least one contract amendment in error\scheduled
            rw.resultMessage = contrIdErrorMessage.get(allContracts[0].id); 
            //[End - Gestione Cruscotto - Exlude contract with at least one contract amendment in error - 24/03/2022]
        }else {
            rw.resultMessage = Label.XC_NoRecordsFound;
        }

        return rw; 
    }


    /**
     * @description method to filter contracts that have at least one error or a scheduled amendment
     * @param allContracts List<Contract>
     * @param contrIdErrorMessage input Map<Id, String>
     * @return List<Contract> 
     **/
    public static List<Contract> filterContract(List<Contract> allContracts, Map<Id, String> contrIdErrorMessage){

        List<Contract> filteredContracts = new List<Contract>(); 
        for(Contract con : allContracts){
            Boolean hasInError = false;
            Boolean hasScheduledAmendment = false;
            Boolean hasDisconnectOrPendingChange = false;
            for(XC_ContractAmendment__c ca : con.Contract_Amendments__r){
                if(ca.XC_Status__c == Label.XC_CL_ContractAmendmentStatusError){
                    hasInError = true;
                    contrIdErrorMessage.put(con.Id, Label.XC_CL_ContractAmendmentInError);
                    break;
                }
                if(!hasScheduledAmendment){
                    if(ca.XC_EndDateBeforeExtension__c != null && ca.XC_EndDateAfterLastExtension__c != null){
                        if(ca.XC_EndDateBeforeExtension__c > ca.XC_EndDateAfterLastExtension__c){//termination --> It is no longer possible to amend the contract
    
                            hasScheduledAmendment = true;
                            contrIdErrorMessage.put(con.Id, Label.XC_CL_ScheduledContractAmendErrorMessage);
                        }else if(ca.XC_EndDateBeforeExtension__c < ca.XC_EndDateAfterLastExtension__c && Date.today() <= ca.XC_EndDateBeforeExtension__c){//extension
                            hasScheduledAmendment = true;
                            contrIdErrorMessage.put(con.Id, Label.XC_CL_ScheduledContractAmendErrorMessage);
                        }
                    }
                    if(ca.XC_RevaluationEffectiveDate__c != null && Date.today() < ca.XC_RevaluationEffectiveDate__c){
                        hasScheduledAmendment = true;
                        contrIdErrorMessage.put(con.Id, Label.XC_CL_ScheduledContractAmendErrorMessage);
                    }
                } 
            }

            if(!con.assets1__r.isEmpty()){
                hasDisconnectOrPendingChange = true;
                contrIdErrorMessage.put(con.Id, Label.XC_CL_DashboardDisconnectChangeError + ' ' + con.assets1__r[0].NE__Order_Config__r.Name);
            }
            if(!hasInError && !hasScheduledAmendment && !hasDisconnectOrPendingChange){
                filteredContracts.add(con);
            } 
        }

        return filteredContracts;
    }
	
	//FM CR772 START
     @AuraEnabled
     public static XC_UTIL_ResultWrapper saveDates(Map<String,Object> draftValueMap, Map<String,Object> paramsMap){
         return saveDatesD(draftValueMap, paramsMap, null, null);
     }
     //FM CR772 END			 
	 /**
     * @description Save the new End dates
     * @param draftValueMap input Map<String,Object>
     * @param paramsMap input Map<String,Object>
     * @param selectedContracts input List<String>
     * @return XC_UTIL_ResultWrapper
     **/
    @AuraEnabled
     public static XC_UTIL_ResultWrapper saveDatesD(Map<String,Object> draftValueMap, Map<String,Object> paramsMap, Date endDateMin, Date endDateMax){ //FM CR772 changed method name

        List<Object> contractsObject = (List<Object>) paramsMap.get('selectedContracts');
        List<string> selectedContracts= new List<string> ();
        for(Object a: contractsObject){
            selectedContracts.add(String.valueOf(a));
        }

        Map<Object, Object> mapObject = (Map<Object, Object>) paramsMap.get('orderItemContractMap');
        Map<string, string> orderItemContractMap= new Map<string, string> ();
        for(Object a: mapObject.keySet()){
            orderItemContractMap.put(String.valueOf(a), String.valueOf(mapObject.get(a)));
        }


        List<Contract> contracts = [SELECT Id, EndDate, XC_Configurations__c, ContractNumber FROM Contract WHERE Id IN :selectedContracts];
						
		//FM CR772 START
        //XC_ContractManagement_D.DataWrapper dataReturned = XC_ContractManagement_D.getRecurringContracts(contracts, false);
        XC_ContractManagement_D.DataWrapper dataReturned;
        if(endDateMin != null && endDateMax != null){
              dataReturned = XC_ContractManagement_D.getRecurringContractsFromAssetByRangeDate(contracts, String.valueOf(endDateMin), String.valueOf(endDateMax));
        }else{
              dataReturned = XC_ContractManagement_D.getRecurringContracts(contracts, false);
        }
        //FM CR772 END
													 
																																								
			  
																						   
		 
					  
        List<NE__OrderItem__c> orderItems = dataReturned.orderItems;
        List<Asset> assetsToUpdate = dataReturned.assets;
        //List<NE__OrderItem__c> orderItems = [SELECT Id, NE__RecurringChargeOv__c, NE__Parent_Order_Item__c, NE__EndDate__c FROM NE__OrderItem__c WHERE Id IN :orderItemContractMap.keySet()];
        System.debug('modified contracts are ' + contracts);
        System.debug('selected contracts are ' + selectedContracts);
        System.debug('draftvalue map ' + draftValueMap);

        Map<String, XC_ContractAmendment__c> contrToCustomContAmMap = new Map<String, XC_ContractAmendment__c>();
        Map<String,Date> contrPreviousDateMap = new Map<String,Date>();
        Map<String, XC_ContractAmendment__c> orderItemToCustomContAmMap = new Map<String, XC_ContractAmendment__c>();
        Map<string, string> contractsMap= new Map<string, string> ();
        for(Contract c : contracts) {
            if(draftValueMap.get(c.Id) != null) {
                String formattedDate = String.valueOf(draftValueMap.get(c.Id)).split('T')[0];
                contrPreviousDateMap.put(c.Id,c.EndDate);

                c.EndDate = Date.valueOf(formattedDate);
            }
            contractsMap.put(c.Id, c.ContractNumber);
            c.XC_LastAdjustmentDate__c = System.TODAY();
        }
        XC_UTIL_ResultWrapper resultContract =  new XC_UTIL_ResultWrapper();
        List<XC_UTIL_Sobject.WrapperResult> dmlResContract = XC_UTIL_DML.updateRecords(contracts);
        XC_UTIL_Sobject.WrapperResult globalResContract = XC_UTIL_Sobject.getGlobalDMLResults(dmlResContract);
        resultContract.success = globalResContract.success;
        
        if(!resultContract.success) {
            resultContract.resultMessage = globalResContract.errorMessage;
            return resultContract;
        } 

        //[Begin - Gestione Cruscotto - Calculate recurring duration - 22/03/2022]
        // Only one asset should always be linked to the configuration item.
        Map<Id,Asset> oiIdAsset = new Map<Id,Asset>();
        for(Asset ass : assetsToUpdate){
            if(!String.isBlank(ass.XC_Configuration_Item__c)){
                oiIdAsset.put(ass.XC_Configuration_Item__c, ass);
            }
        }
        //[End - Gestione Cruscotto - Calculate recurring duration - 22/03/2022]

        Map<Id,Integer> assetIdRecurringDur  =  new Map<Id,Integer>();
        for(NE__OrderItem__c orderItem : orderItems) {
			String formattedDate = (orderItemContractMap.containsKey(orderItem.Id) && draftValueMap.containsKey(orderItemContractMap.get(orderItem.Id)) && String.valueOf(draftValueMap.get(orderItemContractMap.get(orderItem.Id))).split('T')[0] != null) ? String.valueOf(draftValueMap.get(orderItemContractMap.get(orderItem.Id))).split('T')[0] : String.valueOf(Date.today()) ;
            //Cast datetime to date
            //Date endDate = date.newinstance(orderItem.NE__EndDate__c.year(), orderItem.NE__EndDate__c.month(), orderItem.NE__EndDate__c.day()); //FM CR772 commented
            //orderItem.XC_RecurringDuration__c = orderItem.XC_RecurringDuration__c + endDate.monthsBetween(Date.valueOf(formattedDate));
            orderItem.NE__EndDate__c = Date.valueOf(formattedDate);
            orderItem.XC_CA_RenewalDate__c = Date.valueOf(formattedDate);
            orderItem.XC_CA_UpdateDate__c = true;
            orderItem.XC_CA_UpdatePrice__c = false;
            orderItem.NE__Action__c = 'Change';
            // [Begin - Gestione Cruscotto - Calculate recurring duration - 22/03/2022]
            if(oiIdAsset.get(orderItem.Id) != null && oiIdAsset.get(orderItem.Id).Status != Label.XC_CL_Asset_StatusInactive){ //Add logic to calculate recurring duration 
                Integer recurringDuration = calculateRecurringDuration(oiIdAsset.get(orderItem.Id), draftValueMap);
                assetIdRecurringDur.put(oiIdAsset.get(orderItem.Id).Id, recurringDuration);
                orderItem.XC_RecurringDuration__c = recurringDuration;
            }
            // [End - Gestione Cruscotto - Calculate recurring duration - 22/03/2022]
            XC_ContractAmendment__c contrAmendement = new XC_ContractAmendment__c();
            contrAmendement.XC_EndDateBeforeExtension__c = contrPreviousDateMap.get(orderItemContractMap.get(orderItem.Id));
            contrAmendement.XC_EndDateAfterLastExtension__c = Date.valueOf(formattedDate);
            contrAmendement.XC_Contract__c = orderItemContractMap.get(orderItem.Id);
            contrAmendement.XC_Status__c = 'New';
            contrAmendement.XC_LastExtensionDate__c = System.TODAY();
            contrAmendement.Name = contractsMap.get(orderItemContractMap.get(orderItem.Id));
            orderItemToCustomContAmMap.put(orderItem.Id,contrAmendement);
        }

        XC_UTIL_ResultWrapper result =  new XC_UTIL_ResultWrapper();
        List<XC_UTIL_Sobject.WrapperResult> dmlRes = XC_UTIL_DML.updateRecords(contracts);
        XC_UTIL_Sobject.WrapperResult globalRes = XC_UTIL_Sobject.getGlobalDMLResults(dmlRes);
        result.success = globalRes.success;
        if(!result.success) {
            result.resultMessage = globalRes.errorMessage;
            return result;
        } else {
            XC_UTIL_ResultWrapper resultOrderItems =  new XC_UTIL_ResultWrapper();
            // [Begin - Gestione Cruscotto - Skip update triggers - 01/03/2022]
            XC_TR_ConfigurationItem_Handler.bypassBeforeUpdate = true;
            XC_TR_ConfigurationItem_Handler.bypassAfterUpdate = true;
            // [End - Gestione Cruscotto - Skip update triggers - 01/03/2022]
            List<XC_UTIL_Sobject.WrapperResult> dmlResOrI = XC_UTIL_DML.updateRecords(orderItems);
            XC_UTIL_Sobject.WrapperResult globalResOrI = XC_UTIL_Sobject.getGlobalDMLResults(dmlResOrI);
            resultOrderItems.success = globalResOrI.success;
            if(!resultOrderItems.success) {
                resultOrderItems.resultMessage = globalResOrI.errorMessage;
                return resultOrderItems;
            } else {
                //List<Asset> assetsToUpdate = [SELECT Id, Name, XC_ContractEndDate__c, XC_Contract__c, NE__Action__c, XC_Configuration_Item__c FROM Asset WHERE XC_Contract__c IN : selectedContracts AND NE__EndDate__c >= TODAY AND XC_Configuration_Item__r.XC_BillingModel__c = 'Recurring' and Id IN :assetIds];
                System.debug('assetsToUpdate ' + assetsToUpdate);
                List<string> assetIds= new List<string> ();
                for(Asset a :assetsToUpdate) {
                    assetIds.add(a.Id);
                    String formattedDate = (draftValueMap.containsKey(a.XC_Contract__c)) ? String.valueOf(draftValueMap.get(a.XC_Contract__c)).split('T')[0] : String.valueOf(Date.Today());
                    a.XC_ContractEndDate__c = Date.valueOf(formattedDate);
                    a.NE__EndDate__c = (draftValueMap.containsKey(a.XC_Contract__c)) ? Date.valueOf(String.valueOf(draftValueMap.get(a.XC_Contract__c))) : Date.Today();
                    a.NE__Action__c = 'Change';
                    //[Begin - Gestione Cruscotto - Calculate recurring duration - 22/03/2022]
                    if(assetIdRecurringDur.containsKey(a.id)){
                        a.XC_RecurringDuration__c = assetIdRecurringDur.get(a.id);
                    }
                    //[End - Gestione Cruscotto - Calculate recurring duration - 22/03/2022]
                    XC_ContractAmendment__c customObject = orderItemToCustomContAmMap.get(a.XC_Configuration_Item__c);
                    customObject.XC_Asset__c = a.Id;
                    customObject.Name = customObject.Name + ' - ' + a.Name;
                    orderItemToCustomContAmMap.put(a.XC_Configuration_Item__c,customObject);
                }

                for(String key : orderItemToCustomContAmMap.keySet()) {
                    if(orderItemToCustomContAmMap.get(key).XC_Asset__c == null) {
                        orderItemToCustomContAmMap.remove(key);
                    }
                }
                
                XC_UTIL_ResultWrapper resultCustomObject =  new XC_UTIL_ResultWrapper();
                List<XC_UTIL_Sobject.WrapperResult> dmlResult = XC_UTIL_DML.insertRecords(orderItemToCustomContAmMap.values());
                XC_UTIL_Sobject.WrapperResult cADmlResult = XC_UTIL_Sobject.getGlobalDMLResults(dmlResult);
                resultCustomObject.success = cADmlResult.success;
                if (!cADmlResult.success){
                    resultCustomObject.resultMessage = cADmlResult.errorMessage;
                    return resultCustomObject;
                }
                
                Map<String,String> contractAmendementsMap = new Map<String,String>();
                for(XC_ContractAmendment__c c: orderItemToCustomContAmMap.values()) {
                    contractAmendementsMap.put(c.XC_Asset__c, c.Id);
                }
                for(Asset a : assetsToUpdate) {
                    if(contractAmendementsMap.get(a.Id) != null) {
                        a.XC_Contract_Amendment__c = contractAmendementsMap.get(a.Id);
                    }
                }
                XC_UTIL_ResultWrapper resultAsset =  new XC_UTIL_ResultWrapper();
                // [Begin - Gestione Cruscotto - Skip update triggers - 01/03/2022]
                XC_TR_Asset_Handler.bypassBeforeUpdate = true;
                XC_TR_Asset_Handler.bypassAfterUpdate = true;
                // [End - Gestione Cruscotto - Skip update triggers - 01/03/2022]
                List<XC_UTIL_Sobject.WrapperResult> dmlResAsset = XC_UTIL_DML.updateRecords(assetsToUpdate);
                XC_UTIL_Sobject.WrapperResult globalResAsset = XC_UTIL_Sobject.getGlobalDMLResults(dmlResAsset);
                resultAsset.success = globalResAsset.success;
    
                if(!resultAsset.success) {
                    resultAsset.resultMessage = globalResAsset.errorMessage;
                    return resultAsset;
                } else {

                    for(NE__OrderItem__c orderItem : orderItems) {
                        if(orderItem.NE__Parent_Order_Item__c != null) {
                            if(orderItemToCustomContAmMap.get(orderItem.Id) != null) {
                                XC_ContractAmendment__c customObject = orderItemToCustomContAmMap.get(orderItem.Id);
                                if(orderItemToCustomContAmMap.get(orderItem.NE__Parent_Order_Item__c) != null ) {
                                    customObject.Contract_Amendment_Parent__c = orderItemToCustomContAmMap.get(orderItem.NE__Parent_Order_Item__c).Id;
                                    orderItemToCustomContAmMap.put(orderItem.Id,customObject);
                                }
                            }
                        }   
                    }
                    XC_UTIL_ResultWrapper resultUpdateCustom =  new XC_UTIL_ResultWrapper();
                    List<XC_UTIL_Sobject.WrapperResult> dmlResCustom = XC_UTIL_DML.updateRecords(orderItemToCustomContAmMap.values());
                    XC_UTIL_Sobject.WrapperResult globalResCustom = XC_UTIL_Sobject.getGlobalDMLResults(dmlResCustom);
                    resultUpdateCustom.success = globalResCustom.success;
                    if(!resultUpdateCustom.success) {
                        resultUpdateCustom.resultMessage = globalResCustom.errorMessage;
                        return resultUpdateCustom;
                    }
                }
            }
        }

        return result;
    }


    

    /**
	* @description calculates the recurring duration
    * @param ass - Asset
    * @param draftValueMap - Map<String,Object>
    * @return Integer
	**/
    private static Integer calculateRecurringDuration(Asset ass, Map<String,Object> draftValueMap){

        Date endDate = (draftValueMap.containsKey(ass.XC_Contract__c)) ? Date.valueOf(String.valueOf(draftValueMap.get(ass.XC_Contract__c))) : Date.Today();
        Date startDate;
        Integer recurringDuration = 0; 
        if(!String.isBlank(ass.NE__Action__c) && ass.NE__Action__c.equalsIgnoreCase('None')){
            startDate = Date.valueOf(ass.NE__StartDate__c);
        }else{
            startDate = Date.valueOf(ass.NE__StartDate__c) != null ? Date.valueOf(ass.NE__StartDate__c) : ass.XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c;
        }

        String billingPeriod = ass.NE__RecurringChargeFrequency__c;

        if(!String.isBlank(billingPeriod) && startDate != null && endDate != null){
            startDate = Date.newInstance(startDate.year(),startDate.month(),startDate.day());
            endDate = Date.newInstance(endDate.year(),endDate.month(),endDate.day());
            if (billingPeriod.equalsIgnoreCase('Biennial') || billingPeriod.equalsIgnoreCase('Annual')){
                recurringDuration = (startDate.monthsBetween(endDate)) / 12;
            } else{
                recurringDuration = (startDate.monthsBetween(endDate));
            }
        }

        return recurringDuration;
    }
    
}