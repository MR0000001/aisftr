/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 19/10/2018
* @date Modification dd/mm/yyyy
* @description  XC_TR_Configuration_U_UpFinancialAppr – Handler for the setting of the two picklists used for the financial info
*/

public without sharing class XC_TR_Configuration_U_UpFinancialAppr {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_UpFinancialAppr');
    /**  
     * @author Federico Amici federico.amici@nttdata.com
     * @description updates the approval picklist if satisfied conditions
     * @param listNewConfiguration the list new configuration
     * @param mapOld the map old
     * @param mapNew the map new
     * @date Creation 11/10/2018
     * @date Modification dd/mm/yyyy
     */ 
    
    public static void checkPicklistOnUpdate(List<NE__Order__c> listNewConfiguration, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew){
        List<NE__Order__c> listOrder = XC_UTIL_SObject.getListChanged(
                                                                    new List<String>{'XC_Status__c', 'NE__OrderStatus__c', 'XC_Compliance_Approval__c', 'XC_FinancialApproval__c'},
                                                                    mapOld,
                                                                    mapNew);
        List<NE__Order__c> listFilteredOrder = new List<NE__Order__c>();

        List<NE__Order__c> listOrderCancel = new List<NE__Order__c>();
        Map<Id, NE__Order__c> mapOldCancel = new Map<Id, NE__Order__c>();
        Map<Id, NE__Order__c> mapNewCancel = new Map<Id, NE__Order__c>();

        Id orderRTId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
    
        NE__Order__c orderTmp;
        NE__Order__c oldOrder;

        /*
        *   03/01/2019
        *   @Federico Amici added the comments to accomplish the new provisioning model
        */
        for(NE__Order__c conf : listOrder){ 

            System.debug('@@@ ORDER ' + conf);
            System.debug('@@@ mapnew compliance ' + mapNew.get(conf.id).XC_Compliance_Approval__c);

            orderTmp = mapNew.get(conf.Id);
            oldOrder = mapOld.get(conf.Id);

            if((orderTmp.RecordTypeId == orderRTId) && 
                (String.isBlank(orderTmp.XC_FinancialApproval__c)) &&
                //(String.isBlank(orderTmp.XC_Compliance_Approval__c)) &&
                //(orderTmp.XC_Status__c == 'In Progress') && 
                (orderTmp.NE__OrderStatus__c != Label.XC_CL_Configuration_OrderCancelled)){

                listFilteredOrder.add(orderTmp);
            }/* else if((mapNew.get(orderTmp.Id).XC_FinancialApproval__c == Label.XC_CL_Configuration_Rejected) ||
                        (mapNew.get(orderTmp.Id).XC_Compliance_Approval__c == Label.XC_CL_Configuration_Rejected)) {
                listOrderCancel.add(orderTmp);
                mapNewCancel.put(orderTmp.Id, mapNew.get(orderTmp.Id));
                mapOldCancel.put(orderTmp.Id, mapOld.get(orderTmp.Id));
            }*/
        }
        System.debug(listFilteredOrder);
        if(!listFilteredOrder.isEmpty()){
            updateFields(listFilteredOrder, mapOld, mapNew);
        }
        /*if(!listOrderCancel.isEmpty()) {
            XC_TR_Configuration_U_RejectCancel.cancelOrder(listOrderCancel, mapOldCancel, mapNewCancel);
        }*/
    }

    /**
     * @description Update fields.
     *
     * @param listConfigurationNew the list configuration new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void updateFields(List<NE__Order__c> listConfigurationNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew) {
        
        System.debug('invocato corpo configurationItem');
        System.debug('@@@ listnew updatePICK ' + listConfigurationNew);

        List<Id> listConfigurationId = XC_UTIL_Sobject.getIds(listConfigurationNew);

        System.debug('@@@ listconfId' + listConfigurationId);

        List<NE__Order__c> listOrderToUpdate = XC_TR_Configuration_U_UpFinancialAppr_D.getOrderByListId(listConfigurationId);

        Set<Id> listConfigurationItemId = XC_UTIL_Configuration.getAllConfItemIds(listOrderToUpdate);
        Map<Id, List<NE__Order_Item_Attribute__c>> mapOrderIdToOrderItemAttrs = 
                                XC_UTIL_Configuration.getOrderItemAttributesByListCIId(listConfigurationItemId);  
        System.debug('@@@ out listOrderToUpdate ' + listOrderToUpdate); 
        System.debug('@@@ query size' + listOrderToUpdate.size());

        Boolean financialCondition;     
        Integer complianceCondition; 

        Id orderRTId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();

        for(NE__Order__c order : listOrderToUpdate) { 
            financialCondition = false;
            complianceCondition = 0; 
            System.debug('@@@ current order' + order);
            System.debug('@@@ financial ' + order.XC_FinancialApproval__c);
            System.debug('@@@ complianceCondition ' + order.XC_Compliance_Approval__c);
            System.debug('@@@ mapNew.get(id) ' + mapNew.get(order.Id));

            populateFinancialFields(mapNew.get(order.Id), mapOld.get(order.Id));

            if(mapOrderIdToOrderItemAttrs.get(order.Id) != null) {

                System.debug('map order ' + mapOrderIdToOrderItemAttrs.get(order.Id));
                financialCondition = 
                    checkConfigurationPaymentMethod(mapOrderIdToOrderItemAttrs.get(order.Id));
                         // check if the payment method of the configuration is Financial Institute Loan;
                    
                if(financialCondition) {
                    System.debug('@@@ in financialCondition ');
                    mapNew.get(order.Id).XC_FinancialApproval__c = Label.XC_CL_Configuration_ToDo;
                }
            }

            /*          COMPLIANCE VERIFICATION
            complianceCondition = checkComplianceApproval(order);
            if(complianceCondition == 1) {
                System.debug('@@@ in complianceCondition ');
                mapNew.get(order.Id).XC_Compliance_Approval__c = Label.XC_CL_Configuration_ToDo;
            } else if(complianceCondition == 2) {
                mapNew.get(order.Id).XC_Create_Flow_Case__c = true;
            } else if(complianceCondition == 3) {
                System.debug('@@@ compliancecondition 3');
                mapNew.get(order.Id).XC_Compliance_Approval__c = Label.XC_CL_Configuration_ToDo;
                mapNew.get(order.Id).XC_Create_Flow_Case__c = true;
            }*/
    
            if(financialCondition &&   // || (complianceCondition == 1) || (complianceCondition == 3)) &&
                (orderRTId == mapNew.get(order.Id).RecordTypeId)){
                    System.debug('@@@ in financialCondition OR complianceCondition');
                    mapNew.get(order.Id).XC_Status__c = Label.XC_CL_Configuration_OrderToBeValidated;
            }

            if(mapOrderIdToOrderItemAttrs.get(order.Id) != null) {
                copyShipment(mapNew.get(order.Id), mapOrderIdToOrderItemAttrs.get(order.Id)); 
            } 
        } 
    }

    /**
     * @description Copy shipment. 
     * @param order the order
     * @param configurationAttributeChildren the configuration attribute children
     */
    private static void copyShipment(NE__Order__c order, List<NE__Order_Item_Attribute__c> configurationAttributeChildren) {

        if(!configurationAttributeChildren.isEmpty()) {
            for(NE__Order_Item_Attribute__c item : configurationAttributeChildren) {
                //System.debug('@@@ attri ' + item);
                System.debug('@@@ ' +  item.NE__Value__c);  //If configuration item contains that product {
                System.debug('@@@ ' +  item.XC_DeveloperName__c);   //If configuration item contains that product {

                if(item.XC_DeveloperName__c ==  Label.XC_CL_ConfigurationItemAttribute_Shipment_type) {
                    order.XC_DeliveryType__c = item.NE__Value__c;           
                } else if(item.XC_DeveloperName__c == Label.XC_CL_ConfigurationItemAttribute_PODId) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'item.XC_DeveloperName__c -->' + Label.XC_CL_ConfigurationItemAttribute_PODId);
                    //order.XC_DeliveryAddress__c = item.NE__Value__c;  
                }
            }
        } 
    } 

    /**
    * @author Federico Amici federico.amici@nttdata.com
    * @description check the payment method of a configuration
    * @date Creation 11/10/2018
    * @date Modification dd/mm/yyyy
    * @return Boolean
    * @param configurationAttributeChildren 
    */

    private static Boolean checkConfigurationPaymentMethod(List<NE__Order_Item_Attribute__c> configurationAttributeChildren){
        
        if(!configurationAttributeChildren.isEmpty()) {
            for(NE__Order_Item_Attribute__c item : configurationAttributeChildren) {
                //System.debug('@@@ attri ' + item);
                System.debug('@@@ ' +  item.NE__Value__c);  //If configuration item contains that product {
                System.debug('@@@ ' +  item.XC_DeveloperName__c);   //If configuration item contains that product {

                if((item.XC_DeveloperName__c == Label.XC_CL_ConfigurationItemAttribute_PaymentType) 
                    && (item.NE__Value__c == Label.XC_CL_ConfigurationItemAttribute_FinancialInstitute)) {
                    System.debug('@@@ ' +  item.NE__Value__c);  //If configuration item contains that product {
                    return true;                
                }
            }           
        }
        return false;
    }


    /**
     * @author Giulio Serra giserra@deloitte.it
     * @description Populate financial fields. 
     * @param order the order
     * @param oldOrder the old order
     * @date Creation 11/10/2018
     * @date Modification dd/mm/yyyy
     * @description populate the financial fields of a draft configuration
     */
    private static void populateFinancialFields(NE__Order__c order, NE__Order__c oldOrder){
        System.debug('@@@ Configuration status ' + order.XC_Status__c + ' - oldOrder ' + oldOrder.XC_Status__C);
        if((oldOrder.XC_Status__c == Label.XC_CL_Configuration_Draft) && (order.XC_Status__C == Label.XC_CL_Configuration_OrderInProgress)) {

            Id orderRTId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Configuration_RtOrder).getRecordTypeId();
            Boolean financialBlankCondition = String.isBlank(order.XC_FinancialApproval__c);
            //Boolean complianceBlankCondition = String.isBlank(order.XC_Compliance_Approval__c);  
            System.debug('@@@ financialBlankCondition ' + financialBlankCondition); 
            if(order.RecordTypeId == orderRTId && financialBlankCondition) {  //&& complianceBlankCondition){
                order.XC_FinancialApproval__c = Label.XC_CL_Configuration_NotNeeded;
                //order.XC_Compliance_Approval__c = Label.XC_CL_Configuration_NotNeeded;
            }
        }
    }

}