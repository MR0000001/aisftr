/**
* @author :             Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Creation :      08/02/2019
* @date Modification :  dd/mm/yyyy
* @description         XC_TR_Conf_U_CheckCompliance1Status – Util to check Compliance 1 Status
*/

public without sharing class XC_TR_Conf_U_CheckCompliance1Status {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Conf_U_CheckCompliance1Status');

    /**
     * @description Check compliance 1 status
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void checkCompliance1Status(List<NE__Order__c> listNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ENTER IN XC_TR_Conf_U_CheckCompliance1Status');
        List<String> fieldList = new List<String>{'XC_Compliance_Approval__c'};
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            checkComp1StatusOfOrder(listChanged, mapNew);
        }
    }


    /**
     * @param orderList the order list
     * @param mapNew the map new
     * @description : Method to verify if the Compliance 1 Status is in KO.
     *                In this case, the Order is cancelled and a new Customer Interaction is created.
     */
    @TestVisible
    private static void checkComp1StatusOfOrder(List<NE__Order__c> orderList, Map<Id, NE__Order__c> mapNew) {
        List<Id> orderIdList = XC_UTIL_Sobject.getIds(orderList);
        Map<Id, NE__Order__c> orderListWithMoreInfos = new Map<Id, NE__Order__c>([SELECT Id, NE__OptyId__c, NE__OptyId__r.XC_LegalEntity__c, NE__OptyId__r.XC_Contact__c,
                                                                                    NE__OptyId__r.XC_Contact__r.Email, NE__OptyId__r.XC_Contact__r.Name, NE__OptyId__r.XC_Contact__r.AccountId,
                                                                                    NE__OptyId__r.XC_Contact__r.Phone, NE__OptyId__r.XC_Contact__r.XC_PhonePrefix__c, NE__OptyId__r.XC_Contact__r.XC_ContactPhone__c,           // Primary Phone of Contact
                                                                                    NE__OptyId__r.XC_Contact__r.MobilePhone, NE__OptyId__r.XC_Contact__r.XC_MobilePrefix__c, NE__OptyId__r.XC_Contact__r.XC_ContactMobile__c,   // Secondary Phone of Contact
                                                                                    NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c, XC_Segment__c,
                                                                                    (SELECT Id, XC_Communication_Type__c FROM XC_Customer_Interactions__r WHERE XC_Communication_Type__c = 'Order_Cancelled')
                                                                                    FROM NE__Order__c
                                                                                    WHERE Id IN: orderIdList]);

        Map<Id,ProcessInstanceWorkitem> processInstanceWIListMap = new Map<Id,ProcessInstanceWorkitem>([SELECT Id, ProcessInstance.TargetObjectId,ProcessInstance.Status FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN: orderIdList]);
        List<ProcessInstanceWorkitem> processInstanceWIList = processInstanceWIListMap.values();

        Map<Id, List<ProcessInstanceWorkitem>> mapConfIdProcessInstance = new Map<Id, List<ProcessInstanceWorkitem>>();
        for(ProcessInstanceWorkitem prIst : processInstanceWIList) {
            if(mapConfIdProcessInstance.containsKey(prIst.ProcessInstance.TargetObjectId)){
                mapConfIdProcessInstance.get(prIst.ProcessInstance.TargetObjectId).add(prIst);
            }
            else {
                List<ProcessInstanceWorkitem> newList = new List<ProcessInstanceWorkitem>();
                newList.add(prIst);
                mapConfIdProcessInstance.put(prIst.ProcessInstance.TargetObjectId, newList);
            }
        }

        List<NE__Order__c> orderListToUpdate = new List<NE__Order__c>();
        List<Map<String,Object>> mapOrderForCustomInteraction = new List<Map<String,Object>>();
        for(NE__Order__c config : orderList) {
            if(config.XC_Compliance_Approval__c == Label.XC_CL_KO) {
                addErrorForApproval(mapNew, config, mapConfIdProcessInstance);
                
                if(config.XC_Status__c == Label.XC_CL_Configuration_OrderInProgress || config.XC_Status__c == Label.XC_CL_Configuration_OrderToBeValidated) {
                    orderListToUpdate.add(cancelOrder(config, orderListWithMoreInfos, mapOrderForCustomInteraction));
                } else {
                    mapNew.get(config.Id).addError(Label.XC_CL_Configuration_ConfigurationNotClosable);
                }
            }
        }
        
        if(!orderListToUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(orderListToUpdate);
        }
        
        if(!mapOrderForCustomInteraction.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> results =
                    XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOrders(mapOrderForCustomInteraction);
        }
    }


    /**
     * @param mapNew - Map<Id, NE__Order__c> 
     * @param config - NE__Order__c
     * @param mapConfIdProcessInstance - Map<Id, List<ProcessInstanceWorkitem>> 
     * @description Check addError for Approval
     */
    @TestVisible
    private static void addErrorForApproval(Map<Id, NE__Order__c> mapNew, NE__Order__c config, Map<Id, List<ProcessInstanceWorkitem>> mapConfIdProcessInstance) {
        if(mapConfIdProcessInstance.containsKey(config.Id)) {
            for(ProcessInstanceWorkitem pwi : mapConfIdProcessInstance.get(config.Id)){
                if(pwi.ProcessInstance.Status == Label.XC_CL_Approval_Pending) {
                    mapNew.get(config.Id).addError(Label.XC_CL_Order_CancelOrderErrorApproval);
                }
            }
        }
    }


    /**
     * @param mapNew - Map<Id, NE__Order__c> 
     * @param config - NE__Order__c
     * @param orderListWithMoreInfos - Map<Id, NE__Order__c> 
     * @description cancel Order
     */
    public static NE__Order__c cancelOrder(NE__Order__c config, Map<Id, NE__Order__c> orderListWithMoreInfos, List<Map<String,Object>> mapOrderForCustomInteraction) {

        NE__Order__c orderToUpdate = new NE__Order__c();
        orderToUpdate.Id = config.Id;
        orderToUpdate.XC_Status__c = Label.XC_CL_Order_StatusCancelled;
        orderToUpdate.XC_Cancellation_Date__c = Date.today();
        orderToUpdate.XC_Mode_of_cancellation__c = 'Manual';
        orderToUpdate.XC_Type_of_cancellation__c = Label.XC_CL_Configuration_CancellationType_Total;
        orderToUpdate.XC_Reason_of_cancellation__c = Label.XC_ESP_Configuration_OrdereCompliance1Ko;

        //First - Call method B2W 
        NE.OrderSummaryButtonExtension.cancelButton(config.Id);

        //Manage the notification to the Client because of the closed Order
        if(orderListWithMoreInfos.get(config.Id).XC_Customer_Interactions__r.isEmpty() && orderListWithMoreInfos.get(config.Id).XC_Segment__c != 'B2B' && orderListWithMoreInfos.get(config.Id).XC_Segment__c != 'B2G'){
            Map<String,Object> data = createCustomInteractionInfo(orderListWithMoreInfos.get(config.Id));
            if(data != null) {
                mapOrderForCustomInteraction.add(data);
            }
        }

        return orderToUpdate;
    }


    /**
     * @param order the order
     * @return the map
     * @description : Method to create a Map for creating a new Customer Interaction
     */
    public static Map<String,Object> createCustomInteractionInfo(NE__Order__c order){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ENTER IN createCustomInteractionInfo');

		Map<String,Object> data = new Map<String,Object>();
		data.put('customerType', 'Order_Cancelled');
	    data.put('orderId', order.Id);
	   	data.put('skipComunication', false);
        data.put('opportunityId', order.NE__OptyId__c); //Marketing Cloud opportunityID required issue - 05/12/2018 - MCutillo, LOrlanducci
        data.put('legalEntity', order.NE__OptyId__r.XC_LegalEntity__c);
        data.put('SurveyId', 'S15');

	   	if(String.isNotBlank(order.NE__OptyId__r.XC_Contact__c)){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Contact--> ' + order.NE__OptyId__r.XC_Contact__c);
	   		data.put('email', order.NE__OptyId__r.XC_Contact__r.Email);
	   		data.put('fullName', order.NE__OptyId__r.XC_Contact__r.Name);
	   		data.put('contactId', order.NE__OptyId__r.XC_Contact__c);
            data.put('accountId', order.NE__OptyId__r.XC_Contact__r.AccountId);
            data.put('preferredlanguage', order.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c); /*ESCEP-1826 MCutillo 10/05/2019*/

            if(String.isNotBlank(order.NE__OptyId__r.XC_Contact__r.Email)) {
                data.put('email', order.NE__OptyId__r.XC_Contact__r.Email);
            } else if(checkPrimaryPhone(order)) {
                data.put('phone', order.NE__OptyId__r.XC_Contact__r.Phone);
            } else if(checkSecondaryPhone(order)) {
                data.put('phone', order.NE__OptyId__r.XC_Contact__r.MobilePhone);
            } 

	   	} else {
            return null;
        }

	   	XC_UTIL_Debug.debug(DEBUGACTIVE, 'Order Map value ' + data);
		return data;
	}


    /**
	 * CheckPrimaryPhone.
	 *
	 * @param order the order
	 * @return the result oh check
	 * @description check the format of Primary Phone of Contact
	 */
    @TestVisible
    private static Boolean checkPrimaryPhone(NE__Order__c order) {
		if(String.isNotBlank(order.NE__OptyId__r.XC_Contact__r.Phone) && (order.NE__OptyId__r.XC_Contact__r.XC_PhonePrefix__c != '+34' || (order.NE__OptyId__r.XC_Contact__r.XC_PhonePrefix__c == '+34' && (String.valueOf(order.NE__OptyId__r.XC_Contact__r.XC_ContactPhone__c).substring(0,1) == '6' || String.valueOf(order.NE__OptyId__r.XC_Contact__r.XC_ContactPhone__c).substring(0,1) == '7')))) {
			return true;
		} else {
			return false;
		}
	}


	/**
	 * CheckSecondaryPhone.
	 *
	 * @param order the order
	 * @return the result of check
	 * @description check the format of Secondary Phone of Contact
	 */
    @TestVisible
    private static Boolean checkSecondaryPhone(NE__Order__c order) {
		if(String.isNotBlank(order.NE__OptyId__r.XC_Contact__r.MobilePhone) && (order.NE__OptyId__r.XC_Contact__r.XC_MobilePrefix__c != '+34' || (order.NE__OptyId__r.XC_Contact__r.XC_MobilePrefix__c == '+34' && (String.valueOf(order.NE__OptyId__r.XC_Contact__r.XC_ContactMobile__c).substring(0,1) == '6' || String.valueOf(order.NE__OptyId__r.XC_Contact__r.XC_ContactMobile__c).substring(0,1) == '7')))) {
			return true;
		} else {
			return false;
		}
	}
}