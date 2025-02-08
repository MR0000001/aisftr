/**
 * @description       : class with invocable methods for flow XC_FL_CreateMaintenanceServices
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 20-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public without sharing class XC_IN088_CreateContractServices {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN088_CreateContractServices');

    public class FlowInputs{
        
        @InvocableVariable
        public String contractId;
        
    }

    public class FlowOutputs{
        
        @InvocableVariable
        public String DMLResult;
    }

    /**
    * @description create contract services to the contract, quick action (XC_CreateMaintenanceServices)
    * @author pedro.danielalmeida@nttdata.com | 27-04-2022 
    * @param request 
    * @return List<FlowOutputs> 
    **/
    @InvocableMethod 
    public static List<FlowOutputs> createContractServices(List<FlowInputs> request) {
        FlowOutputs result = new FlowOutputs();
        result.DMLResult = 'A problem has occured, please contact your administrator';
        List<FlowOutputs> results = new List<FlowOutputs>();
        if (request.isEmpty()) return results;
        Contract selectedContract = [SELECT Id,StartDate,EndDate,XC_Project__c,XC_Configurations__r.XC_Country__c  FROM Contract WHERE Id =: request[0].contractId];        

        List<String> lstAvailableContractServices = new List<String>();
        lstAvailableContractServices = getAvailableContractServices();

        List<XC_ContractItem__c> lstNewContractServices = new List<XC_ContractItem__c>();
        for (String contractName : lstAvailableContractServices) {
            XC_ContractItem__c newContractService = new XC_ContractItem__c();
            newContractService.XC_ProdName__c = contractName;
            newContractService.XC_Contract__c = selectedContract.Id;
            newContractService.XC_Active__c = true;
            newContractService.XC_ConfigurationItem__c = null;
            newContractService.XC_Country__c = String.isBlank(selectedContract.XC_Configurations__r.XC_Country__c) ? null : selectedContract.XC_Configurations__r.XC_Country__c;
            newContractService.XC_Family__c = null;
            newContractService.XC_ProductCode__c = null;
            newContractService.XC_Quantity__c = null;
            newContractService.XC_ServiceFirstExecution__c = null;
            newContractService.XC_ServiceFrequency__c = null;
            newContractService.XC_Service_Status__c = 'To Plan';
            newContractService.XC_Service_Type__c = null;
            newContractService.XC_Status__c = null;
            newContractService.XC_StartDate__c = selectedContract.StartDate;
            newContractService.XC_EndDate__c = selectedContract.EndDate;
            lstNewContractServices.add(newContractService);
        }

        if (!lstNewContractServices.isEmpty()) {
            try {
                Database.insert(lstNewContractServices,false); 
                result.DMLResult = 'Maintenance Services were successful created';
                results.add(result);
                return results;
            } catch (DmlException e) {
                System.debug('Exception Caught: '+e.getMessage());
                result.DMLResult = e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? e.getMessage().replace('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,','').replace(': []','') : 'A problem has occured, please contact your administrator';
                results.add(result);
                return results;
            }
        }
        results.add(result);
        return results;
    }

    /**
    * @description get contract services setup on custom settings (XC_MaintenanceContractServices)
    * @author pedro.danielalmeida@nttdata.com | 27-04-2022 
    * @return List<String> 
    **/
    public static List<String> getAvailableContractServices(){
        List<String> lstAvailableContractServices = new List<String>();
        XC_MaintenanceContractServices__c contracts = XC_MaintenanceContractServices__c.getOrgDefaults();
        if (String.isNotBlank(contracts.XC_ContractServicesAvailable__c)) {
            lstAvailableContractServices = contracts.XC_ContractServicesAvailable__c.split('\r\n');
        }

        return lstAvailableContractServices;
    }
}