/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  16/05/2019 
* @description XC_LCC049_ProvisioningTemplateP_TEST – Test class for XC_LCC049_ProvisioningTemplatePreview
*/ 
@isTest
public with sharing class XC_LCC049_ProvisioningTemplateP_TEST {
    //Test Method getPickListValues
    static testMethod void getPickListValues(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    XC_LCC049_ProvisioningTemplatePreview.ResultWrapper re = XC_LCC049_ProvisioningTemplatePreview.getPickListValues();
    System.assert(!re.pickListValuesList.isEmpty());
    Test.stopTest();
    }
 
}