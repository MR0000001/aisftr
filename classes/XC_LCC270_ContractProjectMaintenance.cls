/**
 * @description       : XC_LPC270_ContractProjectMaintenance controller
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 20-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public without sharing class XC_LCC270_ContractProjectMaintenance {

    /**
    * @description creates project tasks for contract services that are with status == 'To Plan'
    * @author pedro.danielalmeida@nttdata.com | 27-04-2022 
    * @param contractId 
    * @return String 
    **/
    @AuraEnabled
    public static String createProjectTasks(Id contractId){
        Contract selectedContract = [SELECT Id,StartDate,EndDate,XC_Project__c,XC_LegalEntity__c,XC_Segment__c FROM Contract WHERE Id =: contractId];  
        if (String.isBlank(selectedContract.XC_Project__c)) return 'A Maintenance Project is not associated to the contract';
        if (selectedContract.XC_LegalEntity__c != 'EnelSole' || selectedContract.XC_Segment__c == 'B2C' || String.isBlank(selectedContract.XC_Segment__c)) return 'To complete this process Legal Entity must be EnelSole and segment must be B2B or B2G';
        

        List<project_cloud__Project_Task__c> newpt = new list<project_cloud__Project_Task__c>();
        
        //get new contract services 
        List<XC_ContractItem__c> lstNewContractServices = getContractServices(selectedContract.Id);
        Boolean isServiceFrequencyFilled = true;
        for (XC_ContractItem__c contractService : lstNewContractServices) {
            if (contractService.XC_ServiceFrequency__c == null){
                isServiceFrequencyFilled = false;
            }
        }
        if (isServiceFrequencyFilled == false) return 'The Service Frequency must be filled before the Planning.';
  
        //phase creation
        List<project_cloud__Project_Phase__c> lstProjectPhases = new List<project_cloud__Project_Phase__c>();
        Map<Id, project_cloud__Project_Phase__c> mapContractServicesProjectPhases = new Map<Id, project_cloud__Project_Phase__c>();
        for (XC_ContractItem__c newContractService : lstNewContractServices) {
            if (newContractService.XC_Service_Status__c != 'To Plan') continue;
            project_cloud__Project_Phase__c phase = new project_cloud__Project_Phase__c(
                name = newContractService.Name+' '+newContractService.XC_ProdName__c+' - '+'Phase Reminder',
                project_cloud__Project__c = selectedContract.XC_Project__c,
                XC_ContractService__c = newContractService.Id
            );
            mapContractServicesProjectPhases.put(newContractService.Id,phase);
        }

        try {
            Database.insert(mapContractServicesProjectPhases.values());
        } catch (DmlException e) {
            return 'A problem has occured creating project tasks, please contact your administrator';
        }
        
        //project tasks creation
        for (XC_ContractItem__c newContractService : lstNewContractServices) {
            if (newContractService.XC_Service_Status__c != 'To Plan') continue;
            Date projStartDate = newContractService.XC_StartDate__c;
            Integer serviceFrequency = Integer.valueOf(newContractService.XC_ServiceFrequency__c);
            Integer serviceDuration = projStartDate.daysBetween(newContractService.XC_EndDate__c);

            //get phase for contract service
            project_cloud__Project_Phase__c phase = new project_cloud__Project_Phase__c();
            phase = mapContractServicesProjectPhases.get(newContractService.Id); 

            
            if(serviceFrequency > serviceDuration){
                project_cloud__Project_Task__c pt = new project_cloud__Project_Task__c(
                    name='Reminder Project Task'+' '+'1',
                    project_cloud__Units__c='Duration',
                    project_cloud__Duration__c = 1,
                    project_cloud__Project_Phase__c = phase.id,
                    XC_TaskType__c = 'Reminder',
                    XC_TaskReason__c = 'Create Maintenance Plan', 
                    XC_TaskStatus__c = 'Planned',
                    project_cloud__Autonomous_Start__c = projStartDate,
                    XC_ContractLineItem__c = newContractService.id,
                    project_cloud__Completed_Date__c = projStartDate.addDays(1)
                );
                newpt.add(pt);
            }
            else {
                for(Integer i = 0;i < Math.roundToLong(ServiceDuration / ServiceFrequency);i++){
                    Integer days = i * ServiceFrequency;
                    Integer ptduration = ServiceFrequency;
                    Integer z = i+1;

                    project_cloud__Project_Task__c pt = new project_cloud__Project_Task__c(
                        name='Reminder Project Task'+' '+z,
                        project_cloud__Units__c = 'Duration',
                        project_cloud__Duration__c = 1,
                        project_cloud__Project_Phase__c = phase.id,
                        XC_TaskType__c = 'Reminder',
                        XC_TaskReason__c = 'Create Maintenance Plan',
                        XC_TaskStatus__c = 'Planned',
                        project_cloud__Autonomous_Start__c = projStartDate.addDays(days),
                        XC_ContractLineItem__c = newContractService.id,
                        project_cloud__Completed_Date__c = projStartDate.addDays(days).addDays(1)
                    );
                    newpt.add(pt);
                }
            }
            newContractService.XC_ServiceFirstExecution__c = projStartDate;
            newContractService.XC_Service_Status__c = 'Planned';
        }
        	
        if (!newpt.isEmpty()) {
            try {
                Database.Insert(newpt);
                Database.update(lstNewContractServices);
                return 'Project Tasks created';
            } catch (DmlException e) {
                return 'A problem has occured creating project tasks, please contact your administrator';
            }
        }
        else {
            return 'There are no Contract Services available to plan';
        }  
    }

    /**
    * @description get contract services related to the contract
    * @author pedro.danielalmeida@nttdata.com | 27-04-2022 
    * @param selectedContractId 
    * @return List<XC_ContractItem__c> 
    **/
    public static List<XC_ContractItem__c> getContractServices(Id selectedContractId){
        List<XC_ContractItem__c> lstNewContractServices = [SELECT Id,Name, XC_ProdName__c, XC_Contract__c,XC_Active__c,
                                                           XC_ConfigurationItem__c,XC_Country__c,XC_Family__c,XC_ProductCode__c,
                                                           XC_Quantity__c,XC_ServiceFirstExecution__c,XC_ServiceFrequency__c,
                                                           XC_Service_Status__c,XC_Service_Type__c,XC_Status__c,XC_StartDate__c,
                                                           XC_EndDate__c 
                                                           FROM XC_ContractItem__c WHERE XC_Contract__c = :selectedContractId];
        return lstNewContractServices;
    }

}