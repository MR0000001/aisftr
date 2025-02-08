/**
 * @author Marina Ciavarra - mciavarra@deloitte.it
 * @date Creation 23/03/2021
 * @date Modification 19/10/2021 by Nicola Mariniello nmariniello@deloitte.it
 * @description XC_IN072_CallCommodityAPI – public class with invocable method.
 */


public without sharing class XC_IN072_CallCommodityAPI {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN072_CallCommodityAPI');
	

	/**
     * @description InputWrapper
     */  
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;
    }

    
    /**
     * @description 
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod 
    public static void callCommodityAPI(List<InputWrapper> inputWrapperList) {
	
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'In XC_IN072_CallCommodityAPI');
		if(!inputWrapperList.isEmpty()){
            List<String> listStepIds = new List<String>();
            List<String> listBPLI = new List<String>();
            List<String> listAddress = new List<String>();
			for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
			}
            
            Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>([SELECT ID, XC_Configuration_Item__r.NE__ProdId__c, XC_Configuration_Item__r.XC_Bit2WIN_TranslatedProductName__c,
                                                                                                    XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.NE__OrderId__r.XC_TimeSlot__c, XC_Configuration_Item__r.NE__OrderId__r.CreatedDate,
                                                                                                    XC_Configuration_Item__r.NE__OrderId__r.XC_TimeSlotDate__c, XC_Configuration_Item__r.NE__OrderId__r.XC_RequestDate__c, XC_Configuration_Item__r.NE__OrderId__r.XC_POD__c,
                                                                                                    XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_CommodityBillBPLI__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_ContractualPower__c,
                                                                                                    XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_CustomerBaseEE__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.Owner.XC_Receiving_Channel__c,
                                                                                                    XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.Owner.Name, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.Owner.CompanyName,
                                                                                                    XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_Address__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_StreetNumber__c,
                                                                                                    XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_PostalCode__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_City__c,
                                                                                                    XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_AddressProvince__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_Region__c
                                                                                                FROM XC_Provisioning_Step__c 
                                                                                                WHERE Id IN: listStepIds]); 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapSteps -> ' + mapSteps);

            listBPLI = populateListBPLI(mapSteps);
            Map<Id,XC_BillingProfileLineItem__c> mapBPLI = new Map<Id,XC_BillingProfileLineItem__c>([SELECT ID, XC_Account__c, XC_Account__r.XC_Segment__c, XC_Account__r.XC_LastName__c, XC_Account__r.XC_FirstName__c,
                                                                                                        XC_Account__r.XC_AccountPhonePrefix__c, XC_Account__r.XC_AccountPhone__c, XC_Account__r.Name,
                                                                                                        XC_Account__r.PrimaryEmail__c, XC_Account__r.Account_Type__c, XC_Account__r.BusinessName__c,
                                                                                                        XC_BillingProfile__c, XC_BillingProfile__r.XC_OPDocumentType__c,
                                                                                                        XC_BillingProfile__r.XC_OPDocumentNumber__c, XC_BillingProfile__r.XC_CommodityCupsID__c,
                                                                                                        XC_BillToContactId__c, XC_BillToContactId__r.FirstName, XC_BillToContactId__r.LastName,
                                                                                                     	XC_BillToContactId__r.Email, XC_BillToContactId__r.XC_PhonePrefix__c, XC_BillToContactId__r.XC_ContactPhone__c
                                                                                                    FROM XC_BillingProfileLineItem__c
                                                                                                    WHERE id IN:listBPLI]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapBPLI -> ' + mapBPLI);
            
            for(InputWrapper inputWr : inputWrapperList){
                XC_Provisioning_Step__c step = mapSteps.get(inputWr.stepId);
                Id bpli = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_CommodityBillBPLI__c;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'commodityBPLI -> ' + bpli);
                
                if(!mapBPLI.isEmpty()) {
                    XC_REST_Lead_W.WrapperLeadRequest wrapper = new XC_REST_Lead_W.WrapperLeadRequest();
                    wrapper.Lead.LastName = (mapBPLI.get(bpli).XC_Account__r.Account_Type__c != 'Residential') ? mapBPLI.get(bpli).XC_BillToContactId__r.LastName : mapBPLI.get(bpli).XC_Account__r.XC_LastName__c;
                    wrapper.Lead.FirstName = (mapBPLI.get(bpli).XC_Account__r.Account_Type__c != 'Residential') ? mapBPLI.get(bpli).XC_BillToContactId__r.FirstName : mapBPLI.get(bpli).XC_Account__r.XC_FirstName__c;
                    wrapper.Lead.PhonePrefix = (String.isNotBlank(mapBPLI.get(bpli).XC_Account__r.XC_AccountPhonePrefix__c)) ? mapBPLI.get(bpli).XC_Account__r.XC_AccountPhonePrefix__c : mapBPLI.get(bpli).XC_BillToContactId__r.XC_PhonePrefix__c;
                    wrapper.Lead.Phone = (String.isNotBlank(mapBPLI.get(bpli).XC_Account__r.XC_AccountPhone__c)) ? mapBPLI.get(bpli).XC_Account__r.XC_AccountPhone__c : mapBPLI.get(bpli).XC_BillToContactId__r.XC_ContactPhone__c;
                    wrapper.Lead.PrimaryEmail = (String.isNotBlank(mapBPLI.get(bpli).XC_Account__r.PrimaryEmail__c)) ? mapBPLI.get(bpli).XC_Account__r.PrimaryEmail__c : mapBPLI.get(bpli).XC_BillToContactId__r.Email;
                    wrapper.Lead.IdentityType = mapBPLI.get(bpli).XC_BillingProfile__r.XC_OPDocumentType__c;
                    wrapper.Lead.IdentityNumber = mapBPLI.get(bpli).XC_BillingProfile__r.XC_OPDocumentNumber__c;
                    wrapper.Lead.LeadType = (mapBPLI.get(bpli).XC_Account__r.XC_Segment__c != 'B2C') ? mapBPLI.get(bpli).XC_Account__r.XC_Segment__c : mapBPLI.get(bpli).XC_Account__r.Account_Type__c;
                    wrapper.Lead.BusinessName = (String.isBlank(mapBPLI.get(bpli).XC_Account__r.BusinessName__c)) ? mapBPLI.get(bpli).XC_Account__r.Name : mapBPLI.get(bpli).XC_Account__r.BusinessName__c;
                    wrapper.Lead.AccountID = mapBPLI.get(bpli).XC_Account__c;
                    wrapper.Lead.BillingExternalID = mapBPLI.get(bpli).XC_BillingProfile__c;
                    //wrapper.Lead.OrderID = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__c;
                    //wrapper.Lead.ProductID = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__ProdId__c;
                    wrapper.Lead.ProductName = (mapBPLI.get(bpli).XC_Account__r.XC_Segment__c != 'B2C') ? 'Open Charge B2B' : mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.XC_Bit2WIN_TranslatedProductName__c;
                    wrapper.Lead.RequestDate = (String.isNotBlank(mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.XC_RequestDate__c)) ? mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.XC_RequestDate__c : mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.CreatedDate.format('EEE MMM dd yyyy HH:mm:ss \'GMT\'Z \'(\'z\')\'');
                    wrapper.Lead.ContactRequestTimeSlot = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.XC_TimeSlot__c;
                    if(mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.XC_TimeSlotDate__c != null) {
                        wrapper.Lead.ContactRequestDate = String.valueOf(mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.XC_TimeSlotDate__c);
                    }
                    wrapper.Lead.SendToGenesys = (mapBPLI.get(bpli).XC_Account__r.XC_Segment__c != 'B2C') ? false : true;
                    wrapper.Lead.Stream = null;
                    wrapper.Lead.ContractedPower = (mapBPLI.get(bpli).XC_Account__r.XC_Segment__c != 'B2C') ? String.valueOf(mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_ContractualPower__c) : null;
                    wrapper.Lead.CustomerBaseEE = (mapBPLI.get(bpli).XC_Account__r.XC_Segment__c != 'B2C') ? mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_CustomerBaseEE__c : null;
                    wrapper.Lead.OpportunityOwnerReceivingChannel = (mapBPLI.get(bpli).XC_Account__r.XC_Segment__c != 'B2C') ? mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.Owner.XC_Receiving_Channel__c : null;
                    wrapper.Lead.OpportunityOwnerName = (mapBPLI.get(bpli).XC_Account__r.XC_Segment__c != 'B2C') ? mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.Owner.Name : null;
                    wrapper.Lead.OpportunityOwnerCompany = (mapBPLI.get(bpli).XC_Account__r.XC_Segment__c != 'B2C') ? mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.Owner.CompanyName : null;
                    
                    List<XC_UTIL_Address.PoSWrapper> poss = new List<XC_UTIL_Address.PoSWrapper>();
                    XC_UTIL_Address.PoSWrapper pos = new XC_UTIL_Address.PoSWrapper();
                    pos.POS = mapBPLI.get(bpli).XC_BillingProfile__r.XC_CommodityCupsID__c;
                    poss.add(pos);
                    XC_UTIL_Address.AddressWrapper adr = new XC_UTIL_Address.AddressWrapper('REST');
                    if(mapBPLI.get(bpli).XC_Account__r.XC_Segment__c != 'B2C') {
                        adr.Address = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_Address__c;
                        adr.StreetNumber = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_StreetNumber__c;
                        adr.ZipCode = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_PostalCode__c;
                        adr.City = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_City__c;
                        adr.Province = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_AddressProvince__c;
                        adr.Region = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Address__r.XC_Region__c;
                    }
                    wrapper.Lead.address = adr;
                    wrapper.Lead.address.PointOfService = poss;
                    callCommodityAPIAndSetStepStatus(JSON.serialize(wrapper), JSON.serialize(step));
                }
            }
		}
	}
	
	/**
     * @param wrapperSerialize the wrapperCallCommodityAPI serialized
     * @param stepSerialize the step serialized
     * @description Method to do the logic required for CallCommodityAPI.
     */   
    @future (callout=true)
    public static void callCommodityAPIAndSetStepStatus(String wrapperSerialize, String stepSerialize) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In CallCommodityAPIAndSetStepStatus');
        XC_Provisioning_Step__c step = (XC_Provisioning_Step__c) JSON.deserialize(stepSerialize, XC_Provisioning_Step__c.class);
        XC_REST_Lead_W.WrapperLeadRequest wrapper = (XC_REST_Lead_W.WrapperLeadRequest)JSON.deserialize(wrapperSerialize,XC_REST_Lead_W.WrapperLeadRequest.class);
        
        XC_REST_Lead_Outbound_U.ResponseWrapper wrResponse = XC_REST_Lead_Outbound.sendRequest(wrapper,'CommodityItalyB2C');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'[CallComodityAPI] ' + wrResponse); 

        setStepStatus(wrResponse, step);
        XC_UTIL_Sobject.updateRecord(step);
    }


    /**
     * Set step status.
     * @param wrResponse the CallCommodityAPI wrapper response
     * @param step the provisioning step to update
     * @description Method to set step status
     */
    private static void setStepStatus(XC_REST_Lead_Outbound_U.ResponseWrapper wrResponse, XC_Provisioning_Step__c step){
        if(String.isNotBlank(wrResponse.Result.ErrorCode) && wrResponse.Result.ErrorCode == '0'){
            step.XC_Status__c = Label.XC_CL_Completed_Ok;
        } else {
            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            step.XC_ErrorMessage__c = wrResponse.Result.Message;
        }
    }


    /**
     * Populate List BPLI.
     * @param mapSteps the map Steps
     * @description Method to populate the bpli list
     */
    private static List<String> populateListBPLI(Map<Id, XC_Provisioning_Step__c> mapSteps){
        List<String> listBPLI = new List<String>();
        for(Id stepId : mapSteps.keySet()){
            listBPLI.add(mapSteps.get(stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_CommodityBillBPLI__c);
        }
        return listBPLI;
    }


    /*private static List<String> populateListAddress(Map<Id, XC_BillingProfileLineItem__c> mapBPLI){
        List<String> listAddress = new List<String>();
        for(Id BPLIId : mapBPLI.keySet()){
            listAddress.add(mapBPLI.get(BPLIId).XC_BillToAddress__c);
        }
        return listAddress;
    }*/
    
}