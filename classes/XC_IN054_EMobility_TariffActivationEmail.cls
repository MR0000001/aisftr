/**
 * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation 25/05/2020
 * @date Modification dd/mm/yyyy
 * @description  – public class with invocable method. It is invoked by a Flow to create a XC_CustomerInteraction record
 */ 


public without sharing class XC_IN054_EMobility_TariffActivationEmail {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN054_EMobility_TariffActivationEmail');

    /** 
    * @description InputWrapper the input wrapper.
    */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;       
    }


    /** 
    * @description Invocable method to launch the creation of a customer interaction
    * @param inputWrapperList
    */
    @InvocableMethod 
    public static void emailForTariffActivation(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN054_EMobility_TariffActivationEmail');

        List<XC_IN021_EMobility_EmailForUserCreation.InputWrapper> inputWrList = new List<XC_IN021_EMobility_EmailForUserCreation.InputWrapper>();
        for(InputWrapper wr : inputWrapperList) {
            XC_IN021_EMobility_EmailForUserCreation.InputWrapper inWr = new XC_IN021_EMobility_EmailForUserCreation.InputWrapper();
            inWr.stepId = wr.stepId;
            inputWrList.add(inWr);
        }

        XC_IN021_EMobility_EmailForUserCreation.UtilWrapper utilWrap = XC_IN021_EMobility_EmailForUserCreation.getParentsInfo(inputWrList);
        XC_IN021_EMobility_EmailForUserCreation.populateFieldsOnOrder(utilWrap);
        createCustomerInteraction(utilWrap);
    }


    /**
     * @description Create the Customer Interaction.
     * @param wrapper the UtilWrapper
     **/
    private static void createCustomerInteraction(XC_IN021_EMobility_EmailForUserCreation.UtilWrapper wrapper) {
        
        Map<String,Object> data = new Map<String,Object>();
        data.put('customerType', Label.XC_CL_CustomerInteraction_B2B2CTariffActivation);
        data.put('legalEntity', wrapper.legalEntity);
        data.put('accountId', wrapper.accountId);
        data.put('contactId', wrapper.contactId); 
        data.put('fullName', wrapper.contactName);
        data.put('email', wrapper.email);
        data.put('preferredlanguage', wrapper.preferredlanguage);
        data.put('orderId', wrapper.configurationId);
        data.put('opportunityId', wrapper.optyId);
        data.put('productId', wrapper.productId);
        data.put('segment', wrapper.stream);
        data.put('skipComunication', false);
        data.put('sent', false);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@NM data Map -->' + data);

        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        interactions.add(data);
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(interactions);
    }

}