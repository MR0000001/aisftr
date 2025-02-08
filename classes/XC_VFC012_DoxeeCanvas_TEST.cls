/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation  05/02/2020
* @description XC_VFC012_DoxeeCanvas_TEST – Test class for XC_VFC012_DoxeeCanvas
*/ 
@isTest
public class XC_VFC012_DoxeeCanvas_TEST {
    
    @isTest
    static void testMethod1(){
        insert XC_DF_Lead.createResidentialLeads(1);
        Individual ind = [SELECT id FROM Individual LIMIT 1];
        XC_VFC012_DoxeeCanvas d = new XC_VFC012_DoxeeCanvas(new ApexPages.StandardController(ind));
        d.getCountry();
        d.getCompany();
    }
}