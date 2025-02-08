/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  13/05/2019 
* @description XC_LCC109_TakeChargeLead_TEST – Test class for XC_LCC109_TakeChargeLead
*/ 
@isTest
public class XC_LCC109_TakeChargeLead_TEST {
    //Test Method saveAddressApex
    static testMethod void takeLeadChargeProcess(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    	List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        insert listLead;
        String leadId = listLead[0].Id;
         listLead[0].OwnerId=  Userinfo.getUserId(); 
	    XC_UTIL_ResultWrapper rw = XC_LCC109_TakeChargeLead.takeLeadChargeProcess(leadId);   
        System.assertEquals(false, rw.success);
    Test.stopTest();
    }
    
    //Test Method saveAddressApex2
    static testMethod void takeLeadChargeProcess2(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC109_TakeChargeLead.takeLeadChargeProcess('');
        System.debug('@@@ takeLeadChargeProcess2'+ rw);
        System.assertEquals(false, rw.success);
    Test.stopTest();
    }
    
    //Test Method saveAddressApex3
    static testMethod void takeLeadChargeProcess3(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    	List<User> us = XC_DF_User.generateMultipleUser(2);
        insert us; 

        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        listLead[0].OwnerId = us[0].Id;
        insert listLead;
        
        System.runAs(us[0]){
        String leadId = listLead[0].Id;
        system.debug('@@@ownerId1'+listLead[0].OwnerId+' '+Userinfo.getUserId());

        XC_LCC109_TakeChargeLead.manageChangeStatus(listLead[0]);
            
		system.debug('@@@ownerId2'+listLead[0].OwnerId+' '+Userinfo.getUserId());        
        XC_UTIL_ResultWrapper rw = XC_LCC109_TakeChargeLead.takeLeadChargeProcess(leadId);
        System.debug('@@@ takeLeadChargeProcess3'+ rw);
        }
        //System.assertEquals(false, rw.success);
    Test.stopTest();
    }
   
   
    
   static testMethod void takeLeadChargeProcess4(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    	User u = XC_DF_User.createUserAdmin();
        insert u; 
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
       // insert listLead;
        String leadId = listLead[0].Id;
        system.debug('@@@ownerId1'+listLead[0].OwnerId+' '+Userinfo.getUserId());
        listLead[0].OwnerId = u.Id;
      //  update listLead;
		system.debug('@@@ownerId2'+listLead[0].OwnerId+' '+Userinfo.getUserId());        
        XC_UTIL_ResultWrapper rw = XC_LCC109_TakeChargeLead.takeLeadChargeProcess(leadId);
        System.debug('@@@ takeLeadChargeProcess3'+ rw);
    Test.stopTest();
    }
    
    static testMethod void takeLeadChargeProcess5(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        listLead[0].Status = Label.XC_CL_Lead_TakeCharge;
        insert listLead;    
        XC_UTIL_ResultWrapper rw = XC_LCC109_TakeChargeLead.takeLeadChargeProcess(listLead[0].Id);
    Test.stopTest();
    }

}