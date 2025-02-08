/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Data factory for the XC_ProvisioningStep__c object
*/
@isTest
public class XC_DF_ProvisioningStep {
    
    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @description this method creates a provisioning step
    * @param confItemId the id of the configuration item linked to the step
    * @return the provisioning step created
    */
    public static XC_Provisioning_Step__c createProvisioningStep(String confItemId) {

        XC_Provisioning_Step__c ps = new XC_Provisioning_Step__c();
        ps.XC_Configuration_Item__c = confItemId;

        return ps;

    }

}