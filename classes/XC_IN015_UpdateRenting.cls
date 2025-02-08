/** 
 * @author      Federico Amici - federico.amici@nttdata.com
 * @date        18/03/2019
 * @description Handles the update of the prices inside the Billing Process provisioning step
 */
public class XC_IN015_UpdateRenting {

	public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN015_UpdateRenting');

    /** 
     * @author      Federico Amici - federico.amici@nttdata.com
     * @date        18/03/2019
     * @description Wrapper used by flow
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;       
    }

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Method that updates renting
     * @param inputWrapperList - map Id -> old value of record
    */
    @InvocableMethod 
    public static void updateRenting(List<InputWrapper> inputWrapperList) { 
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN015_UpdateRenting');
        
        if(!inputWrapperList.isEmpty()){

            List<String> listStepIds = new List<String>();
            List<XC_Provisioning_Step__c> provisioningStepsToComplete = new List<XC_Provisioning_Step__c>();
            String orderId = ''; 
            XC_Provisioning_Step__c step;

            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
            }

            Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN011_ChangeProvBillingProcess_D.getMapSteps(listStepIds);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapSteps-->' +mapSteps);

            String confItemId;

            for(InputWrapper inputWr : inputWrapperList) {
                step = mapSteps.get(inputWr.stepId);
                //NE__OrderItem__c confItem = configurationMap.get(step.XC_Configuration_Item__c);
                orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
                confItemId = step.XC_Configuration_Item__c;

                //COMPLETE STEP - Salvatore Scarpato 14/3/2019
                step.XC_Status__c = Label.XC_CL_Completed_Ok;
                provisioningStepsToComplete.add(step); 
            } 
           
            /************** Get item actions and split in two lists **************/
            Map<Id, NE__OrderItem__c> configItem =  XC_IN015_UpdateRenting_D.getItemsByOrderId(orderId, confItemId);
           
            /*************** ***************** *********************************/

            XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr = XC_IN011_ChangeProvBillingProcess_D.getItemsByOldIds(new List<Id>(configItem.keySet()));
            List<String> listZquoteIds = new List<String>();

            Map<String, List<String>> mapZquoteIdAddRP = new Map<String, List<String>>();
            Map<String, List<String>> mapZquoteIdRemoveRP = new Map<String, List<String>>();

            String newItemId;
            String oldItemId;
            NE__OrderItem__c oldItem;
            NE__OrderItem__c newItem;
            
            //System.enqueueJob(new AsyncExecutionExample(listIdZQ));
            //XC_TR_ConfigurationItem_U_CheckForZQuote.doFutureSendZuora(listIdZQ);
            NE__OrderItem__c confItemToUpdate = wr.mapNewItems.get(confItemId);
            confItemToUpdate.XC_ZQuoteId__c = wr.zQuoteId;
            wr.confItemId = confItemId;
            wr.orderId = orderId;

            XC_TR_ConfigurationItem_U_UpdateZQuote.createAddRemoveProductsAmendmentQuote(wr);

            //UPDATE STEP AND ORDERITEM
            //updateProvisioningStepsAndConfigurationItem(provisioningStepsToComplete, confItemToUpdate);
            //System.enqueueJob(new ManageDMLQueuable(confItemToUpdate,provisioningStepsToComplete));
        } 
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to update the configuration item and the provisioning step.
     * @param provisioningStepsToUpdate provisioningStep list
     * @param orderItemsToUpdate item To update
    **/ 
    public static void updateProvisioningStepsAndConfigurationItem(List<XC_Provisioning_Step__c> provisioningStepsToUpdate, NE__OrderItem__c orderItemsToUpdate){
        List<XC_UTIL_Sobject.WrapperResult> listDMLResultOnStep = XC_UTIL_Sobject.updateListRecords(provisioningStepsToUpdate);
        if(listDMLResultOnStep[0].success){
            XC_UTIL_Sobject.WrapperResult dmlResultOnItems = XC_UTIL_Sobject.updateRecord(orderItemsToUpdate);
        }
    }
}