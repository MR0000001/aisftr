/**
 * @author Nicola Mariniell - nmariniello@deloitte.it
 * @date Creation 18/10/2021
 * @description XC_IN083_OpenChargeB2BNotification – public class with invocable method.
 **/


public without sharing class XC_IN083_OpenChargeB2BNotification {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN083_OpenChargeB2BNotification');
	

	/**
     * @description InputWrapper
     **/  
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;

        @Invocablevariable
        public Boolean isActivationOK = true;

        @Invocablevariable
        public Boolean isDisconnection = false;
    }


    /**
     * @description 
     * @param inputWrapperList the input wrapper list
     **/
    @InvocableMethod 
    public static void createCustomerInteraction(List<InputWrapper> inputWrapperList) {
	
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'In XC_IN083_OpenChargeB2BNotification');

		if(!inputWrapperList.isEmpty()) {
            XC_IN022_EMobility_ActivationCode.InputWrapper inputWr = new XC_IN022_EMobility_ActivationCode.InputWrapper();
            inputWr.stepId = inputWrapperList[0].stepId;
            List<XC_IN022_EMobility_ActivationCode.InputWrapper> inputWrList = new List<XC_IN022_EMobility_ActivationCode.InputWrapper>{inputWr};
            XC_IN022_EMobility_ActivationCode.UtilWrapper utilWr = XC_IN022_EMobility_ActivationCode.getParentsInfo(inputWrList);
            createCustomerInteraction(utilWr, inputWrapperList[0].isActivationOK, inputWrapperList[0].isDisconnection);
        }
    }


    /**
     * @description Method to create a Customer Interaction record.
     * @param wrapper
     **/
    private static void createCustomerInteraction(XC_IN022_EMobility_ActivationCode.UtilWrapper wrapper, Boolean isActivationOK, Boolean isDisconnection) {
        
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        Map<String,Object> data = new Map<String,Object>();

        data.put('customerType', (isDisconnection) ? Label.XC_CL_CustomerInter_ComType_OpenChargeB2BDeactivation : ((isActivationOK) ? Label.XC_CL_CustomerInter_ComType_OpenChargeB2BActivation : Label.XC_CL_CustomerInter_ComType_OpenChargeB2BActivationKO));
        data.put('email', wrapper.eMail);
        data.put('preferredlanguage', wrapper.preferredlanguage);
        data.put('accountId', wrapper.accountId);
        data.put('contactId', wrapper.contactId);
        data.put('fullName', wrapper.contactName);
        data.put('orderId', wrapper.orderId);
        data.put('orderItemID', wrapper.orderItemID);
        data.put('productId', wrapper.productId);
        data.put('opportunityId', wrapper.optyId);
        data.put('legalEntity', wrapper.legalEntity);
        data.put('segment', wrapper.stream);
        data.put('skipComunication', false);
        data.put('sent', false);

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ data Map -->' + data);
        interactions.add(data);
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(interactions);
    }

}