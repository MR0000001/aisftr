/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 15/05/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description XC_LCC008_LeadCallToCommodity_TEST 
*/  
@isTest
public class XC_LCC008_LeadCallToCommodity_TEST {

 /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  Method to test callCommodity method
*/
static testMethod void callCommodityTestFake(){

    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        List<Lead> bo = XC_DF_Lead.createResidentialLeads(1);
        insert bo;
        XC_LCC008_LeadCallToCommodity.ResultWrapper rw = XC_LCC008_LeadCallToCommodity.callCommodity(bo[0].id);
        System.assert(rw.success);
    Test.stopTest();
    
   
    }
    /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  Method to test callCommodity method
*/
    static testMethod void callCommodityTestReal(){

    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
            XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
            ic.XC_activeInterface__c = true;
            ic.Name = Label.XC_CL_Lead_CallToCommodityURL;
            ic.XC_interfaceName__c =Label.XC_CL_Lead_CallToCommodityURL; 
            insert ic;
        List<Lead> bo = XC_DF_Lead.createResidentialLeads(1);
        insert bo;
        XC_LCC008_LeadCallToCommodity.ResultWrapper rw = XC_LCC008_LeadCallToCommodity.callCommodity(bo[0].id);
        System.assert(rw.success);
    Test.stopTest();
    
   
    }
    

    
    
}