/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation  04/02/2020 
* @description XC_TR_Lead_U_CheckStatus_TEST – Test class for XC_TR_Lead_U_CheckStatus
*/ 
@isTest
public class XC_TR_CampaignMember_TEST {
    
    @testSetup
    static void setupVoucher(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        XC_Voucher__c v = new XC_Voucher__c();
        Id recordTypeId = Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByName().get('Campaign Individual Voucher').getRecordTypeId();
        v.RecordTypeId = recordTypeId;
        v.name = 'regalo';
        Date diobrando = System.Today();
        v.XC_StartDate__c = diobrando.AddDays(-1);
        v.XC_EndDate__c = diobrando.AddDays(1);
        v.XC_Voucher_To_Be_Created__c = 3;
        v.XC_Type_of_Discount__c = 'Percentage';
        v.XC_Amount__c = 30;        
        insert v;
        System.Debug('voucher: '+v);
    }
        
    @isTest 
    static void campaignMemberTest(){
		
        List<XC_Voucher__c> vq = ([SELECT id, XC_VoucherCode__c, XC_RecordTypeName__c FROM XC_Voucher__c]);
        Campaign c = new Campaign();
        c.Name = 'Super Sconti';
        c.XC_Code__c = vq[0].XC_VoucherCode__c;
        System.debug('voucher code: '+c.XC_Code__c);
        insert c;
        
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(4);
        insert contlist;
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = contlist[0].id;
        cm.campaignId = c.id;
        cm.Status = 'Sent';
        insert cm;
        
        List<CampaignMember> cmss = new List<CampaignMember>();
        for(integer i = 1; i<=3; i++){
            CampaignMember cms = new CampaignMember();
        	cms.ContactId = contlist[i].id;
        	cms.campaignId = c.id;
       		cms.Status = 'Sent';
        }
        insert cmss; 
        delete cm;
        System.assertEquals('Sent', cm.Status);
    }
}