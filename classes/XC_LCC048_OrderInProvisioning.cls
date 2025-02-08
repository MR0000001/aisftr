/**
 * @description XC_LCC048_OrderInProvisioning - Controller for component XC_LCP048_OrderInProvisioning
 */
public without sharing class XC_LCC048_OrderInProvisioning {

    private static String className ='XC_LCC048_OrderInProvisioning';
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC048_OrderInProvisioning');

    /** The order type. */
    public static String orderType = '';

    /** The order subtype. */
    public static String orderSubtype = '';

    /** @description ChangeOrderSentWrapper */
    private class ChangeOrderSentWrapper {
        List<XC_Provisioning_Step__c> stepList = new List<XC_Provisioning_Step__c>();
        String recordId;
        XC_UTIL_ResultWrapper wr;
        Boolean finish = false;
    }

    /**
     * @description Insert provisioning steps
     * @date Modification 13/08/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param recordId the record id
     * @return the xC_UTIL_provisioningstep. result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ProvisioningStep.ResultWrapper insertProvisioningSteps(String recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_LCC048_OrderInProvisioning - insertProvisioningSteps');
        if(!Schema.SObjectType.NE__Order__c.isAccessible()) {
            return new XC_UTIL_ProvisioningStep.ResultWrapper();
        }
        Map<Id,NE__Order__c> configurationListMap = new Map<Id,NE__Order__c>([
                SELECT Id, NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c, XC_Compliance_Approval__c, NE__Type__c, XC_Subtype__c, XC_InstallationAddress__r.XC_Address__c, XC_InstallationAddress__r.XC_PostalCode__c, XC_InstallationAddress__r.XC_City__c, XC_InstallationAddress__r.XC_AddressCountry__c, XC_InstallationAddress__c, XC_Segment__c, 
                (SELECT Id FROM Work_Orders__r WHERE  XC_WorkTypeLabel__c = :Label.XC_CL_WorkType_DeliveryInstallation)   //To change XC_WorkTypeLabel__c with XC_WorkTypeCategory__c
                FROM NE__Order__c
                WHERE Id =: recordId]);

        List<NE__Order__c> configurationList = configurationListMap.values();

        if(!configurationList.isEmpty()){
            orderType = configurationList[0].NE__Type__c;
            orderSubtype = configurationList[0].XC_Subtype__c;
        }
        /*if(orderType == Label.XC_CL_Configuration_TypeInOrder || (orderType == Label.XC_CL_Configuration_TypeChangeOrder && orderSubtype != Label.XC_CL_ConfigurationSubtype_EarlyCancellation)|| orderType == Label.XC_CL_Configuration_TypeDisconnection ){
            String valueInsertDMLLog = XC_CS_UtilityGlobalValues__c.getInstance('GenerateWOB2Win_Log').Value__c;
            String generateResult = '';
            if(valueInsertDMLLog == 'true') {
                generateResult = B2WExtCat.WS_WorkOrders.generateWorkOrdersLogs(recordId, true);
            }else 
            	generateResult = B2WExtCat.WS_WorkOrders.generateWorkOrders(recordId);
            XC_UTIL_IntegrationLog.insertGenerateWorkOrderLog(generateResult, recordId, 'GenerateWorkOrder-' + className);
            
        }*/
        
        XC_UTIL_ProvisioningStep.ResultWrapper result = XC_UTIL_ProvisioningStep.insertSteps(recordId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ insertProvisioningSteps result='+result);
        result.order = configurationListMap.values()[0];
        return result;
    }
    
    /**
     * @description Insert provisioning steps
     * @date Created 30/08/2021 - Marina Ciavarra - mciavarra@delolitte.it
     * @param recordId the record id
     * @param parentClass the class name which called the method
     * @return the xC_UTIL_provisioningstep. result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ProvisioningStep.ResultWrapper insertProvisioningSteps(String recordId, String parentClass){
        if(parentClass != null)
            className= parentClass;
        return insertProvisioningSteps(recordId);
    }

    /**
     * @description Update order status
     * @param recordId the record id
     * @return the XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper updateOrderStatus(String recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_LCC048_OrderInProvisioning - updateOrderStatus - recordId='+recordId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'USED QUERIES->' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();

        if(!Schema.SObjectType.XC_Provisioning_Step__c.isAccessible()) {
            return new  XC_UTIL_ResultWrapper();
        }


        if(recordId != null){
            Map<Id, XC_Provisioning_Step__c> stepMap = new Map<Id, XC_Provisioning_Step__c>([
                    SELECT Id,XC_Step_Order__c,XC_PlatformEventName__c, XC_Template_Name__c, XC_LegalEntity__c,XC_Segment__c,XC_Configuration_Item__c,XC_Status__c,XC_Step_Code__c,XC_Mandatory_Steps__c,XC_Synchronous__c,XC_Flow_API_Name__c,
                            XC_Country__c, XC_ConfigurationId__c,XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c, XC_Configuration_Item__r.NE__OrderId__c,
                            XC_Configuration_Item__r.NE__OrderId__r.XC_AssetsCreated__c, XC_Configuration_Item__r.NE__OrderId__r.NE__FulfilmentStatus__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OrderStatus__c
                    FROM XC_Provisioning_Step__c
                    WHERE XC_Configuration_Item__r.NE__OrderId__c =: recordId
                    AND XC_Configuration_Item__r.XC_IsAProduct__c = true
                    AND XC_Step_Order__c = 1]);
            List<XC_Provisioning_Step__c> stepList = stepMap.values();
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'stepList->' + stepList);

            ChangeOrderSentWrapper changeOrderSentWrapper = new ChangeOrderSentWrapper();
            changeOrderSentWrapper.stepList = stepList;
            changeOrderSentWrapper.recordId = recordId;
            Boolean assetCreated = false;
            if(!stepList.isEmpty()){
                assetCreated = stepList[0].XC_Configuration_Item__r.NE__OrderId__r.XC_AssetsCreated__c;
                checkWrapperResultForOrder(changeOrderSentWrapper, assetCreated);
            }
            if(changeOrderSentWrapper.finish) {
                return changeOrderSentWrapper.wr;
            }

            //non ci sono step, aggiorno cmq l'ordine
            XC_UTIL_ResultWrapper wr = XC_UTIL_Configuration.changeOrderStatusSent(recordId, assetCreated);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@# without step @#@#@# wr->' + wr);
            return wr;
        }else{
            rw.success = false;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ updateOrderStatus rw='+rw);
        return rw;
    }

    /**
     * @description Check for WrapperResult
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Modification 13/08/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param changeOrderSentWrapper - ChangeOrderSentWrapper
     * @param assetCreated - Boolean
     */
    private static void checkWrapperResultForOrder(ChangeOrderSentWrapper changeOrderSentWrapper, Boolean assetCreated) {
        if(!changeOrderSentWrapper.stepList.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@# NE__Type__c->' + changeOrderSentWrapper.stepList[0].XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c);
            if(changeOrderSentWrapper.stepList[0].XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c == Label.XC_CL_Configuration_TypeInOrder
                    || changeOrderSentWrapper.stepList[0].XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c == Label.XC_CL_Configuration_TypeChangeOrder
                    || changeOrderSentWrapper.stepList[0].XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c == Label.XC_CL_Configuration_TypeDisconnection){
                //XC_UTIL_ProvisioningStep.startInitialSteps(changeOrderSentWrapper.stepList);
                changeOrderSentWrapper.wr = XC_UTIL_Configuration.changeOrderStatusSent(changeOrderSentWrapper.recordId, assetCreated);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@# wr->' + changeOrderSentWrapper.wr);
                changeOrderSentWrapper.finish = true;
            }
            if(changeOrderSentWrapper.stepList[0].XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c == Label.XC_CL_Configuration_TypeDisconnection){
                XC_UTIL_ProvisioningStep.startInitialSteps(changeOrderSentWrapper.stepList);
            }
            //FIX SS 07/05/19
            if(changeOrderSentWrapper.wr.success){
                XC_UTIL_ProvisioningStep_U.startProvisioningStepsOnConfigurationItems(changeOrderSentWrapper.recordId);
            }
            /*XC_UTIL_ProvisioningStep.startInitialSteps(changeOrderSentWrapper.stepList);
            wr.resultMessage = Label.XC_CL_Provisioning_Started;
            wr.success = true;
            changeOrderSentWrapper.finish = true;;*/
        }
    }

    /**
     * @description Check compliance 1 status
     * @param recordId the record id
     * @return the boolean
     */
    @AuraEnabled
    public static Boolean checkCompliance1Status(String recordId) {     // NM LR - 11/01/2019 - ESCEP-802 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'USED QUERIES->' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        if(!Schema.SObjectType.NE__Order__c.isAccessible()) {
            return false;
        }
        Map<Id,NE__Order__c> configurationListMap = new Map<Id,NE__Order__c>([
                SELECT Id, XC_Compliance_Approval__c, NE__Type__c,  XC_Subtype__c
                FROM NE__Order__c WHERE Id =: recordId]);

        List<NE__Order__c> configurationList = configurationListMap.values();



        if(!configurationList.isEmpty()){
            orderType = configurationList[0].NE__Type__c;
            orderSubtype = configurationList[0].XC_Subtype__c;
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'orderType ---> ' + orderType);
            if(orderType == Label.XC_CL_Configuration_TypeInOrder || orderSubtype == Label.XC_CL_ConfigurationSubtype_ChangeOfOwnership){
                return checkForConfiguration(configurationList);
            } else if(orderType == Label.XC_CL_Configuration_TypeDisconnection){
                return true;
            } else if(orderType == Label.XC_CL_Configuration_TypeChangeOrder){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'orderType ---> ' + orderType);
                return true;
            }
            return false;
        }
        return false;
    }

    /*@AuraEnabled
    public static XC_UTIL_ResultWrapper changeOrderStatus(String recordId){  
        XC_UTIL_ProvisioningStep.insertSteps(recordId);
        return XC_UTIL_Configuration.changeOrderStatusSent(recordId);
    }*/

    /**
     * @description Check for Configuration
     * @param configurationList - List<NE__Order__c>
     * @return Boolean
     */
    private static Boolean checkForConfiguration(List<NE__Order__c> configurationList){
        if(configurationList[0].XC_Compliance_Approval__c == Label.XC_CL_OK ||
                configurationList[0].XC_Compliance_Approval__c == Label.XC_CL_Configuration_NotNeeded
                ){
            return true;
        }
        return false;
    }
}