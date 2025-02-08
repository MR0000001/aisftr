/**
* @author Roberta Cossiga - rcossiga@deloitte.it 
* @date Creation 06/05/2019
* @description XC_DF_ServiceResource – Data Factory for ServiceResource
*/

@isTest
public class XC_DF_ServiceResource {
    
         /** 
     * Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to create Service Resources from a list of partner account in input
     * @param n - number of service resource to insert
     * @return  List<ServiceResource> to insert
     */
    public static List<ServiceResource> createServiceResources(Integer n){
        List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true];
        if(n>=usersList.size()){
            n = usersList.size();
        }
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(n);
        return createServiceResourcesFromAccount(accountList); 
    }
    
     /** 
     * Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to create Service Resources from a list of partner account in input
     * @param accountList - List of account
     * @return  List<ServiceResource> to insert
     */
    public static List<ServiceResource> createServiceResourcesFromAccount(List<Account> accountList){
        return createServiceResourcesFromAccount(accountList, false);  
    }
    
    
    /** 
     * Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to create Service Resources from a list of partner account in input
     * @param accountList - List of account
     * @param automaticDeactivation - Boolean to set the automatic Deactivation checkbox
     * @return  List<ServiceResource> to insert
     */
    public static List<ServiceResource> createServiceResourcesFromAccount(List<Account> accountList, Boolean automaticDeactivation){
        List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true];

        List<ServiceResource> serviceResourcesToInsert = new List<ServiceResource>();
        Integer i = 0;
        for(Account accnt : accountList){
            ServiceResource serviceRes = new ServiceResource();
            serviceRes.Name = accnt.Name;
            serviceRes.XC_Account__c = accnt.Id;
            serviceRes.IsActive = true;
            serviceRes.IsCapacityBased = true;
            serviceRes.XC_AutomaticDeactivation__c = automaticDeactivation;
            if(!usersList.isEmpty() && i<usersList.size()) {
                serviceRes.RelatedRecordId = usersList[i].Id; // serviceRes.RelatedRecordId = accnt.Users[0].Id
                serviceResourcesToInsert.add(serviceRes);
            }
            i++;
        }
        insert serviceResourcesToInsert;
        return serviceResourcesToInsert;   
    }

    /** 
     * Roberta Cossiga - rcossiga@deloitte.it
     * @description Method to create Service Resources Skill for a Service Resource
     * @param servResource
     * @return  List<ServiceResourceSkill> to insert
     */
    public static ServiceResourceSkill createServiceResourcesSkill(ServiceResource servResource){
        ServiceResourceSkill servResSkill = new ServiceResourceSkill();
        List<Skill> skillList = [SELECT Id, MasterLabel, DeveloperName FROM Skill];
        servResSkill.SkillId = skillList[0].Id;
        servResSkill.ServiceResourceId = servResource.Id;
        servResSkill.SkillLevel = 1;
        servResSkill.XC_CertificationStartDate__c = System.today();
        servResSkill.XC_CertificationEndDate__c = System.today().addYears(5);
        servResSkill.EffectiveEndDate = System.today().addYears(5);
        servResSkill.EffectiveStartDate = System.today();
        servResSkill.XC_AssignmentStartDate__c = System.today();
        servResSkill.XC_AssignmentEndDate__c = System.today().addYears(5);
        return servResSkill;   
    }
}