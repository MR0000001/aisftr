/**
* @author Valeria Martino valeria.martino@nttdata.com
* @date Creation 19/08/2019
* @date Modification 12/01/2022
* @description XC_IN030_ChangeOrder_ContractChange – 
*/
public without sharing class XC_IN030_ChangeOrder_ContractChange {

private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN030_ChangeOrder_ContractChange');


    /** 
    * @description InputWrapper the input wrapper.
    */
    public class InputWrapper{
        @Invocablevariable
        public String stepId; 
    }
     /**
    * @description Change Contract and Assets of a Order
    * @author Valeria Martino valeria.martino@nttdata.com
    * @param inputWrapperList - List<InputWrapper> 
    */  
    @InvocableMethod
    public static void callContractChange(List<InputWrapper> inputWrapperList) { 

        if(inputWrapperList.isEmpty()){
            return;
        }
        Savepoint sp = Database.setSavePoint();

        List<String> stepIdList = new List<String>();
        for(InputWrapper inputWr : inputWrapperList){
            stepIdList.add(inputWr.stepId);
        }
        XC_Provisioning_Step__c provisioningStep = XC_IN030_ChangeOrder_ContractChange_U.getProvisioningStep(stepIdList);
        List<Asset> listAccountAsset = new List<Asset>();
        //List<String> listIdAsset = new List<String>();
        List<Asset> assetChild = new List<Asset>();
        List<Case> listCaseFather = new List<Case>(); 
        List<WorkOrder> listWOFather = new List<WorkOrder>();
        List<Case> listCaseChildren = new List<Case>(); 
        List<WorkOrder> listWOChildren = new List<WorkOrder>();
        Map<String,Object> utilMap = new Map<String,Object>();
        XC_Provisioning_Step__c provStepToUpdate = new XC_Provisioning_Step__c();
        String orderId =  provisioningStep.XC_Configuration_Item__r.NE__OrderId__c;

        NE__Order__c order = XC_IN030_ChangeOrder_ContractChange_U.getOrder(orderId);    
        String statusOpportunity = order.NE__OptyId__r.Stagename;
        String legalEntity = order.XC_LegalEntity__c;
        String segment = order.XC_Segment__c;
        String orderSubtype = order.XC_Subtype__c;
        String changeOwnerType = order.XC_Type__c;
        listAccountAsset.addAll(order.NE__Assets__r);

        provStepToUpdate = XC_IN030_ChangeOrder_ContractChange_U.checkContractFather(provisioningStep, listAccountAsset);
        if(provStepToUpdate!=null){
            XC_UTIL_Sobject.updateRecord(provStepToUpdate);
            return;
        }
        List<Asset> assetChildren = XC_IN030_ChangeOrder_ContractChange_U.getAssetChildren(listAccountAsset);
        for(Asset asset : assetChildren) {
            listCaseFather.addAll(asset.Cases);
            listWOFather.addAll(asset.WorkOrders);
        }

        Boolean isToSkipCoBlock = (orderSubtype == Label.XC_CL_ChangeOfOwnership) ? XC_UTIL_ChangeOrder.getIsToSkipCOBlock(legalEntity, segment) : false;
        utilMap.put('isToSkipCoBlock', isToSkipCoBlock);
        utilMap.put('orderSubtype', orderSubtype);
        utilMap.put('changeOwnerType', changeOwnerType);
        utilMap.put('Savepoint', sp);
        
        //2° Error Message
        checkOpportunityStatus(provisioningStep, statusOpportunity, provStepToUpdate);
        if(provisioningStep.XC_Status__c == Label.XC_CL_Step_CompletedKO) {
            return;
        }
        //provStepToUpdate = checkCaseStatus(provisioningStep, listCaseFather);
        provStepToUpdate = checkCaseStatusExt(provisioningStep, listCaseFather, utilMap);
        if(provisioningStep.XC_Status__c == Label.XC_CL_Step_CompletedKO){
            return;
        }
        //provStepToUpdate = checkWorkOrderStatus(provisioningStep, listWOFather);
        provStepToUpdate = checkWorkOrderStatusExt(provisioningStep, listWOFather, utilMap);
        if(provStepToUpdate!=null){
            return;
        }
        updateAccountOnAsset(provisioningStep, order, assetChildren);
        if(provisioningStep.XC_Status__c == Label.XC_CL_Step_CompletedKO){
            return;
        }

        if(((Map<Id, Case>)utilMap.get('caseToUpdate'))!= null && !((Map<Id, Case>)utilMap.get('caseToUpdate')).isEmpty()){
            if(!XC_UTIL_ChangeOrder.updateCase(utilMap)){
                manageKO(provisioningStep, (String)utilMap.get('ErrorMessage'), sp);
                return; 
            }
        }

        if(((Set<Id>)utilMap.get('woToMigrate')) != null && !((Set<Id>)utilMap.get('woToMigrate')).isEmpty()){
            utilMap.put('order', order);
            migrateWo(utilMap, provisioningStep);
        }
    }

    /**
    * @description if there isn't address on Asset in list of address on Order's Account, insert it
    * @author Valeria Martino valeria.martino@nttdata.com
    * @param accountId - String
    * @param assetChildren - List<Asset>
    * @return XC_UTIL_Sobject.WrapperResult
    */
    public static XC_UTIL_Sobject.WrapperResult copyAddressOnAsset(String accountId, List<Asset> assetChildren) {
        List<Account> listAccountOrder = new List<Account>([SELECT Id, (SELECT Id, XC_FullAddress__c, XC_PostalCode__c, XC_Municipality__c   FROM Addresses__r) FROM Account WHERE Id = :accountId]);
        Account accountOrder = listAccountOrder[0];
        List<XC_Address__c> listAddressOrder = new List<XC_Address__c>();
        XC_UTIL_Sobject.WrapperResult result = new XC_UTIL_Sobject.WrapperResult();
        if(!(accountOrder.Addresses__r.isEmpty())) {
            listAddressOrder.addAll(accountOrder.Addresses__r);
            for(Asset asset : assetChildren) {
                result.success = true;
                if(asset.XC_Address__c!=null && !containsAddress(listAddressOrder, asset.XC_Address__r)){
                    result = cloneAddress(asset.XC_Address__r, accountOrder);
                    return result;
                }
            }
        }
        else {
            result.success = false;
            result.errorMessage = Label.XC_CL_ChangeOwnership_NoAddress;
        }
        return result;
    }
    /**
    * @description update Status and ErrorMessage on ProvisioningStep
    * @author Valeria Martino valeria.martino@nttdata.com
    * @param provisioningStep - XC_Provisioning_Step__c
    * @param errorMessage - String
    */
    public static void errorOperationDML(XC_Provisioning_Step__c provisioningStep, String errorMessage) {
        provisioningStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
        provisioningStep.XC_ErrorMessage__c = errorMessage;
        XC_UTIL_Sobject.updateRecord(provisioningStep);              
    } 
    /**
    * @description clone Address 
    * @param address - XC_Address__c
    * @param account - Account 
    * @return XC_UTIL_Sobject.WrapperResult
    */
    private static XC_UTIL_Sobject.WrapperResult cloneAddress(XC_Address__c address, Account account){
        XC_Address__c addressToClone = new XC_Address__c();
        addressToClone = address;
        XC_Address__c addressCloned = addressToClone.clone(false,true,false,false);
        addressCloned.XC_Account__c = account.Id;
        XC_UTIL_Sobject.WrapperResult dmlResult = XC_UTIL_Sobject.insertRecord(addressCloned);
        return dmlResult;
    }
 
    /**
    * @description update if  Status on WO is not final
    * @author Valeria Martino valeria.martino@nttdata.com
    * @param  provisioningStep - XC_Provisioning_Step__c
    * @param  listWOFather - List<WorkOrder> 
    * @return XC_Provisioning_Step__c
    */
    public static XC_Provisioning_Step__c checkWorkOrderStatus(XC_Provisioning_Step__c provisioningStep, List<WorkOrder> listWOFather){
        /*XC_Provisioning_Step__c provStepToUpdate;

        for(WorkOrder workOrder: listWOFather) {
            if(workOrder.XC_Check_Final_Status__c == false) {
                provStepToUpdate = provisioningStep;
                break;
            }
        }
        if(provStepToUpdate!=null){
            provisioningStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            provisioningStep.XC_ErrorMessage__c = Label.XC_CL_ChangeOwnership_StatusNotAllowed;
            XC_UTIL_Sobject.updateRecord(provStepToUpdate);
            return provStepToUpdate;
        }
        return provStepToUpdate;*/
        return checkWorkOrderStatusExt(provisioningStep, listWOFather, new Map<String,Object>());
    }


     /**
    * @description update if  Status on WO is not final
    * @param  provisioningStep - XC_Provisioning_Step__c
    * @param  listWOFather - List<WorkOrder> 
    * @param  utilMap - Map<String,Object>
    * @return XC_Provisioning_Step__c
    */
    private static XC_Provisioning_Step__c checkWorkOrderStatusExt(XC_Provisioning_Step__c provisioningStep, List<WorkOrder> listWOFather, Map<String,Object> utilMap){

        XC_Provisioning_Step__c provStepToUpdate;

        Set<String> workOrderToManage = new Set<String>{Label.XC_CL_WorkType_Repair, Label.XC_CL_WorkType_PlannedMaintenance,
                                                        'Diagnostic', Label.XC_CL_WorkType_QualityCheckInspection};

        String orderSubtype = !String.isBlank(((String) utilMap.get('orderSubtype'))) ? (String) utilMap.get('orderSubtype') : '' ;
        String changeOwnerType = !String.isBlank(((String) utilMap.get('changeOwnerType')))  ? (String) utilMap.get('changeOwnerType') : '' ;
        Boolean isToSkipCoBlock = ((Boolean) utilMap.get('isToSkipCoBlock') != null) ? (Boolean) utilMap.get('isToSkipCoBlock') : false; 

        Set<Id> woToMigrate = new Set<Id>();
        utilMap.put('woToMigrate', woToMigrate);
        for(WorkOrder workOrder: listWOFather) {
            if(workOrder.XC_Check_Final_Status__c == false) {
                if(orderSubtype == Label.XC_CL_ChangeOfOwnership && isToSkipCoBlock && !String.isBlank(changeOwnerType) && workOrderToManage.contains(workOrder.XC_WorkTypeCategory__c)){
                   populateWOToMigrate(workOrder, changeOwnerType, utilMap);
                }else{
                    provStepToUpdate = provisioningStep;
                    break;
                }
            }
        }
        

        if(provStepToUpdate!=null){
            provisioningStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            provisioningStep.XC_ErrorMessage__c = Label.XC_CL_ChangeOwnership_StatusNotAllowed;
            XC_UTIL_Sobject.updateRecord(provStepToUpdate);
            return provStepToUpdate;
        }
        return provStepToUpdate;
        
    }


    /**
    * @description update if Status on Case is not final
    * @author Valeria Martino valeria.martino@nttdata.com
    * @param  provisioningStep - XC_Provisioning_Step__c
    * @param  listCaseFather - List<Case>
    * @return XC_Provisioning_Step__c
    */
    public static XC_Provisioning_Step__c checkCaseStatus(XC_Provisioning_Step__c provisioningStep, List<Case> listCaseFather){
        /*XC_Provisioning_Step__c provStepToUpdate;
        for(Case caso: listCaseFather) {

            if((caso.Reason =='XCMOT008' && caso.SubCause__c == 'ATCL060') || (caso.Reason =='XCMOT009' && caso.SubCause__c == 'ATCL160')){
                continue;
            }
            else if(caso.Status != Label.XC_CL_Configuration_Closed && caso.Status != Label.XC_CL_Case_Status007 && caso.Status != Label.XC_CL_Case_Status008 /*&& (caso.Reason !='XCMOT008' && caso.SubCause__c != 'ATCL060')) { 
                
                provisioningStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                provisioningStep.XC_ErrorMessage__c = Label.XC_CL_ChangeOwnership_StatusNotAllowed;
                break;
            }
        }

        if(provisioningStep.XC_Status__c == Label.XC_CL_Step_CompletedKO){
            provStepToUpdate = provisioningStep;
            XC_UTIL_Sobject.updateRecord(provisioningStep);
           
        }
        return provStepToUpdate;*/

        return checkCaseStatusExt(provisioningStep, listCaseFather, new Map<String,Object>());
    }


    /**
    * @description update if Status on Case is not final
    * @param  provisioningStep - XC_Provisioning_Step__c
    * @param  listCaseFather - List<Case>
    * @param  utilMap - Map<String,Object>
    * @return XC_Provisioning_Step__c
    */
    public static XC_Provisioning_Step__c checkCaseStatusExt(XC_Provisioning_Step__c provisioningStep, List<Case> listCaseFather, Map<String,Object> utilMap){

        XC_Provisioning_Step__c provStepToUpdate;
        String orderSubtype = !String.isBlank(((String) utilMap.get('orderSubtype'))) ? (String) utilMap.get('orderSubtype') : '' ;
        Boolean isToSkipCoBlock = ((Boolean) utilMap.get('isToSkipCoBlock') != null) ? (Boolean) utilMap.get('isToSkipCoBlock') : false; 
        Map<Id, Case> caseToUpdate = new Map<Id, Case>();

        for(Case caso: listCaseFather) {
            if((caso.Reason =='XCMOT008' && caso.SubCause__c == 'ATCL060') || (caso.Reason =='XCMOT009' && caso.SubCause__c == 'ATCL160')){
                continue;
            }
            else if(caso.Status != Label.XC_CL_Configuration_Closed && caso.Status != Label.XC_CL_Case_Status007 && caso.Status != Label.XC_CL_Case_Status008 /*&& (caso.Reason !='XCMOT008' && caso.SubCause__c != 'ATCL060')*/) { 
                if(orderSubtype == Label.XC_CL_ChangeOfOwnership && isToSkipCoBlock && 
                    (caso.RecordType.DeveloperName.containsIgnorecase('Management_Case') || caso.RecordType.DeveloperName.containsIgnorecase('Information_Case')
                    || caso.RecordType.DeveloperName =='XC_ESP_Case')){
                        caseToUpdate.put(caso.Id, caso);
                } else{
                    provisioningStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                    provisioningStep.XC_ErrorMessage__c = Label.XC_CL_ChangeOwnership_StatusNotAllowed;
                    break;
                }   
            }
        }

        utilMap.put('caseToUpdate', caseToUpdate);
        if(provisioningStep.XC_Status__c == Label.XC_CL_Step_CompletedKO){
            provStepToUpdate = provisioningStep;
            XC_UTIL_Sobject.updateRecord(provisioningStep);
           
        }
        return provStepToUpdate;
    }

    /**
    * @description update if Status on Opportunity is not final
    * @author Valeria Martino valeria.martino@nttdata.com
    * @param  provisioningStep - XC_Provisioning_Step__c
    * @param statusOpportunity - String 
    * @param provStepToUpdate - XC_Provisioning_Step__c
    */
    public static void checkOpportunityStatus(XC_Provisioning_Step__c provisioningStep, String statusOpportunity, XC_Provisioning_Step__c provStepToUpdate) {
        if(statusOpportunity!= Label.XC_CL_Opportunity_ClosedWon && statusOpportunity!= Label.XC_CL_Opportunity_ClosedLost) {
            provisioningStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            provisioningStep.XC_ErrorMessage__c = Label.XC_CL_ChangeOwnership_StatusNotAllowed;
            provStepToUpdate = provisioningStep;
            XC_UTIL_Sobject.updateRecord(provStepToUpdate);
            return;
        }
    }
    /**
    * @description update AccountId on Asset
    * @author Valeria Martino valeria.martino@nttdata.com
    * @param provisioningStep - XC_Provisioning_Step__c
    * @param order - NE__Order__c
    * @param assetChildren - List<Asset> 
    */
    public static void updateAccountOnAsset(XC_Provisioning_Step__c provisioningStep, NE__Order__c order, List<Asset> assetChildren) {
        List<Asset> listToUpdateAsset = new List<Asset>();
        Map<Id, Contract> mapContractToUpdate = new Map<Id, Contract>();
        XC_Provisioning_Step__c provStepToUpdate;
        //Update account of Asset 
        for(Asset asset : assetChildren){
            asset.AccountId = order.NE__AccountId__c;
            asset.ContactId = order.XC_ChangedContact__c;
            Contract contract = new Contract(Id = asset.XC_Contract__c, XC_ContractAccount__c = order.NE__AccountId__c);
            listToUpdateAsset.add(asset);
            mapContractToUpdate.put(contract.Id, contract);
        }

        List<XC_UTIL_Sobject.WrapperResult> resultlistToUpdateAsset = XC_UTIL_Sobject.updateListRecords(listToUpdateAsset);
        List<XC_UTIL_Sobject.WrapperResult> resultlistToUpdateContract = XC_UTIL_Sobject.updateListRecords(mapContractToUpdate.values());
        for(XC_UTIL_Sobject.WrapperResult result: resultlistToUpdateAsset) {
            if(result.success == false) {
                errorOperationDML(provisioningStep,result.errorMessage);
                return;
            }
        }
        for(XC_UTIL_Sobject.WrapperResult result: resultlistToUpdateContract) {
            if(result.success == false) {
                errorOperationDML(provisioningStep, result.errorMessage);
                return;
            }
        }
        XC_UTIL_Sobject.WrapperResult result = copyAddressOnAsset(order.NE__AccountId__c, assetChildren);
        if(result.success == false) {
            errorOperationDML(provisioningStep, result.errorMessage);
            return;
        }
        
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_Ok;
        provStepToUpdate = provisioningStep;
        XC_UTIL_Sobject.updateRecord(provStepToUpdate);
        return;

    }
    /**
    * @description verifiy if Address is a duplicate of another
    * @author Valeria Martino valeria.martino@nttdata.com
    * @param listAddressesAccount - List<XC_Address__c>
    * @param addressAsset - XC_Address__c 
    * @return Boolean
    */
    public static Boolean containsAddress (List<XC_Address__c> listAddressesAccount, XC_Address__c addressAsset) {
        for(XC_Address__c  addressAccount : listAddressesAccount) {
            if(addressAccount.XC_FullAddress__c == addressAsset.XC_FullAddress__c && 
               addressAccount.XC_Municipality__c == addressAsset.XC_Municipality__c && 
               addressAccount.XC_PostalCode__c == addressAsset.XC_PostalCode__c) {
                   return true;
               }
        }
        return false;
    } 



      /**
    * @description method to migrate the work order, service appointment, workorderlineitem to the new contract holder
    * @author Luisana Rocco lrocco@deloitte.it
    * @param utilMap - Map<String,Object>
    * @param provisioningStep - XC_Provisioning_Step__c
    * @return Boolean
    */
    private static void migrateWo(Map<String,Object> utilMap, XC_Provisioning_Step__c provisioningStep){


        NE__Order__c order = (NE__Order__c) utilMap.get('order');
        Set<Id> woToMigrate = (Set<Id>)utilMap.get('woToMigrate');
        Map<Id,WorkOrder> woToUpdate = new Map<Id,WorkOrder>();
        

        Map<Id,WorkOrder> woTomanage = XC_IN030_ChangeOrder_ContractChange_U.getWo(woToMigrate);
        Set<ServiceAppointment> allServiceApp = new Set<ServiceAppointment>();
        Set<WorkOrderLineItem> allWoli = new Set<WorkOrderLineItem>();
        Set<WorkOrderLineItem> woliToUpdate = new Set<WorkOrderLineItem>();

        utilMap.put('allServiceApp', allServiceApp);
        utilMap.put('allWoli', allWoli);

        // update work order
        woToUpdate.putAll(manageWoUpdate(utilMap,woTomanage));
        allServiceApp = (Set<ServiceAppointment>)utilMap.get('allServiceApp');
        allWoli = (Set<WorkOrderLineItem>) utilMap.get('allWoli');

        //update service appointment
        if(!allServiceApp.isEmpty()){
            for(ServiceAppointment sa : allServiceApp){
                sa.ContactId = order.XC_ChangedContact__c;
            }
        }

        // update work order line item
        if(!allWoli.isEmpty()){
            for(WorkOrderLineItem woli: allWoli){
                if(!String.isblank(woli.XC_AccountId__c)){
                    woli.XC_AccountId__c = order.NE__AccountId__c;
                    woliToUpdate.add(woli);
                }
            }
        }

        utilMap.put('allServiceApp', allServiceApp);
        utilMap.put('woliToUpdate', woliToUpdate);
        utilMap.put('woToUpdate',woToUpdate);

        manageUpdateResult(utilMap, provisioningStep);
        if(provisioningStep.XC_Status__c == Label.XC_CL_Step_CompletedKO) {
            return;
        }

        provisioningStep.XC_Status__c = Label.XC_CL_Completed_Ok;
        XC_UTIL_Sobject.updateRecord(provisioningStep);
        return;

    }

    /**
    * @description method to manage the update of the work order, service appointment, woli
    * @author Luisana Rocco lrocco@deloitte.it
    * @param utilMap - Map<String,Object>
    * @param provisioningStep - XC_Provisioning_Step__c
    * @return Boolean
    */
    private static void manageUpdateResult (Map<String,Object> utilMap, XC_Provisioning_Step__c provisioningStep){

        Set<ServiceAppointment> allServiceApp = (Set<ServiceAppointment>)utilMap.get('allServiceApp');
        Set<WorkOrderLineItem> woliToUpdate = (Set<WorkOrderLineItem>) utilMap.get('woliToUpdate');
        Map<Id,WorkOrder> woToUpdate = (Map<Id,WorkOrder>)utilMap.get('woToUpdate');
        SavePoint sp = (SavePoint)utilMap.get('Savepoint');

        List<XC_UTIL_Sobject.WrapperResult> resultlistToUpdate = XC_UTIL_Sobject.updateListRecords(woToUpdate.values());
        for(XC_UTIL_Sobject.WrapperResult result: resultlistToUpdate) {
            if(!result.success) {
                manageKO(provisioningStep, result.errorMessage,sp);
                return;
            }
        }

        if(!allServiceApp.isEmpty()){
            resultlistToUpdate = XC_UTIL_Sobject.updateListRecords(new List<ServiceAppointment>(allServiceApp));
            for(XC_UTIL_Sobject.WrapperResult result: resultlistToUpdate) {
                if(!result.success){
                    manageKO(provisioningStep, result.errorMessage,sp);
                    return;
                }
            }
        }
        
        if(!woliToUpdate.isEmpty()){
            resultlistToUpdate = XC_UTIL_Sobject.updateListRecords(new List<WorkOrderLineItem>(woliToUpdate));
            for(XC_UTIL_Sobject.WrapperResult result: resultlistToUpdate) {
                if(!result.success){
                    manageKO(provisioningStep, result.errorMessage,sp);
                    return;
                }
            }
        }

    }

    /**
    * @description method to populate the workorders that need to be transferred from the old to the new contract owner
    * @author Luisana Rocco lrocco@deloitte.it
    * @param utilMap - Map<String,Object>
    * @param provisioningStep - XC_Provisioning_Step__c
    * @param workOrder - workOrder
    */
    private static void populateWOToMigrate(WorkOrder workOrder, String changeOwnerType, Map<String,Object> utilMap){

        Set<Id> woToMigrate = (Set<Id>)utilMap.get('woToMigrate');
        Set<String> admittedStatus = new Set<String>{Label.XC_CL_WorkOrder_New, Label.XC_CL_WorkOrder_Assigned,Label.XC_CL_OnHold };
        if(admittedStatus.contains(workOrder.Status) && (changeOwnerType == Label.XC_CL_ChangeOwnerWithSubrogation || (changeOwnerType == Label.XC_CL_ChangeOwnerWithoutSubrogation &&  workOrder.XC_WorkTypeCategory__c != Label.XC_CL_WorkType_Repair))){
            woToMigrate.add(!String.isBlank(workOrder.RootWorkOrderId) ?  workOrder.RootWorkOrderId : workOrder.id);
        }
        utilMap.put('woToMigrate', woToMigrate);
        
    }

  
     /**
    * @description method to manage the update of the work order
    * @author Luisana Rocco lrocco@deloitte.it
    * @param utilMap - Map<String,Object>
    * @param woToManage - Map<Id,WorkOrder>
    * @return Map<Id,WorkOrder>
    */
    private static Map<Id,WorkOrder> manageWoUpdate(Map<String,Object> utilMap, Map<Id,WorkOrder> woToManage){
        
        NE__Order__c order = (NE__Order__c) utilMap.get('order');
        String changeOwnerType = !String.isBlank(((String) utilMap.get('changeOwnerType')))  ? (String) utilMap.get('changeOwnerType') : '' ;
        Set<ServiceAppointment> allServiceApp = (Set<ServiceAppointment>)utilMap.get('allServiceApp');
        Set<WorkOrderLineItem> allWoli = (Set<WorkOrderLineItem>) utilMap.get('allWoli');
        Map<Id,WorkOrder> woToUpate = new Map<Id,WorkOrder>();

        for(WorkOrder wo: woToManage.values()){
            if(isSameAddress(wo, order)){
                if(order.XC_Type__c == Label.XC_CL_ChangeOwnerWithoutSubrogation &&  wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair){
                    continue;
                }
                wo.AccountId = order.NE__AccountId__c;
                wo.ContactId = order.XC_ChangedContact__c;
                wo.XC_Address__c = (order.XC_InstallationAddress__c != null) ? order.XC_InstallationAddress__c : (order.XC_DeliveryAddress__c != null && !order.XC_DeliveryAddress__r.XC_PickUpPoint__c) ? order.XC_DeliveryAddress__c : wo.XC_Address__c;
                wo.XC_CustomerPhone__c = order.XC_ChangedContact__r.Phone;
                woToUpate.put(wo.id, wo);

                allServiceApp.addAll(wo.ServiceAppointments);
                allWoli.addAll(wo.WorkOrderLineItems);
            }
        }

        utilMap.put('allServiceApp', allServiceApp);
        utilMap.put('allWoli', allWoli);

        return woToUpate;
    }


    
     /**
    * @description method to check id the address of work order and order are the same
    * @author Luisana Rocco lrocco@deloitte.it
    * @param order -NE__Order__c
    * @param wo - WorkOrder
    * @return boolean
    */
    private static boolean isSameAddress(WorkOrder wo, NE__Order__c order){

        if(!String.isBlank(order.XC_InstallationAddress__c) && !String.isBlank(wo.XC_Address__c)){

            String keyForDuplicationWo1 = wo.XC_Address__r.XC_AddressCountry__c + ' ' + 
                                          wo.XC_Address__r.XC_City__c + ' ' +
                                          wo.XC_Address__r.XC_AddressProvince__c + ' ' +
                                          wo.XC_Address__r.XC_StreetNumber__c;
            String keyForDuplicationWo2 = wo.XC_Address__r.XC_Address__c + ' ' + 
                                          wo.XC_Address__r.XC_StreetTypeText__c + ' ' +  
                                          wo.XC_Address__r.XC_Municipality__c + ' ' +
                                          wo.XC_Address__r.XC_PostalCode__c;

            String keyForDuplicationOR1 = order.XC_InstallationAddress__r.XC_AddressCountry__c + ' ' + 
                                          order.XC_InstallationAddress__r.XC_City__c + ' ' +
                                          order.XC_InstallationAddress__r.XC_AddressProvince__c + ' ' +
                                          order.XC_InstallationAddress__r.XC_StreetNumber__c;
            String keyForDuplicationOR2 = order.XC_InstallationAddress__r.XC_Address__c + ' ' + 
                                          order.XC_InstallationAddress__r.XC_StreetTypeText__c + ' ' +  
                                          order.XC_InstallationAddress__r.XC_Municipality__c + ' ' +
                                          order.XC_InstallationAddress__r.XC_PostalCode__c;

            if(keyForDuplicationWo1 == keyForDuplicationOR1 && keyForDuplicationWo2 == keyForDuplicationOR2){
                return true; 
            }
        }
        
        return false;
    }

     
    /**
    * @description method to manage the rollback in case of KO
    * @author Luisana Rocco lrocco@deloitte.it
    * @param provisioningStep  - XC_Provisioning_Step__c
    * @param errorMessage - String
    * @param sp - SavePoint
    */
    private static void manageKO(XC_Provisioning_Step__c provisioningStep, String errorMessage, SavePoint sp){
        //Rollback
        Database.rollback(sp);
        // Set step KO
        errorOperationDML(provisioningStep, errorMessage);
    }
   
}