/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 05/06/2019
* @date Modification dd/mm/yyyy
* @description  – XC_UTIL_LeadAssignment_TEST - Test class for XC_UTIL_LeadAssignment
*/ 
@isTest
public class XC_UTIL_LeadAssignment_TEST {
    /** 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation  05/06/2019 
    * @description insert records
    */ 
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        Integer n = 10;

        Group g = new Group();
        g.Type = 'Queue';
        g.Name = 'Queue';
        insert g;

        List<XC_LeadAssignmentMaster__c> leadAssignmentMasterList = new List<XC_LeadAssignmentMaster__c>();
        for(Integer i = 0; i<n; i++){
            XC_LeadAssignmentMaster__c lam = new XC_LeadAssignmentMaster__c();
            lam.XC_LegalEntity__c  = 'EndesaX';
            lam.XC_RecordTypePick__c = 'Spain';
            lam.XC_ProductCategoryOfInterest__c = 'Caldera'; 
            lam.XC_Email__c = 'Testleadtest@test.it';
            lam.XC_Country__c = 'Spain';
            lam.XC_City__c = 'Madrid';
            lam.XC_PrimaryPhone__c = 'No';
            lam.XC_Address__c = 'Yes';
            lam.XC_ZipCode__c = '28001';
            lam.XC_AssignedToCreator__c = true;
            lam.XC_Status__c = Label.XC_CL_Lead_Assigned;
            
            system.debug('@TEST@ lam->'+ lam);
            leadAssignmentMasterList.add(lam); 
        } 
        insert leadAssignmentMasterList;
        
        Lead ld = new Lead();
        ld.Lastname = 'Test';
        ld.Company = 'Test company';
        ld.Email = 'Testleadtest@test.it';
        ld.XC_ProductCategoryOfInterest__c = 'Caldera';
        ld.XC_Country__c = 'Spain';
        ld.XC_City__c = 'Madrid';
        ld.XC_ZipCode__c = '28001';
        ld.XC_DocumentType__c = '';
        ld.XC_MainLegalEntity__c = 'EndesaX';
        ld.XC_DocumentCountry__c = 'Spain';
        insert ld;
        
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(n);
        insert leadList;
        List<Individual> individualList = new List<Individual>();
        for(Integer i = 0; i<n; i++){
            Individual ind = new Individual();
            ind.LastName = 'Test n.' + i;
            individualList.add(ind);
        }
        insert individualList;
        List<XC_LegalEntityConsent__c> legalEntityConsentList = new List<XC_LegalEntityConsent__c>();
        for(Integer i = 0; i<n; i++){
        	XC_LegalEntityConsent__c legalEntityConsent = new XC_LegalEntityConsent__c();
            legalEntityConsent.XC_GiveDataToNew__c = 'Yes';
            legalEntityConsent.XC_LeCountry__c = 'Spain';
            legalEntityConsent.XC_LegalEntity__c = 'EndesaX';
            legalEntityConsent.XC_Individual__c = individualList[i].id;
            legalEntityConsentList.add(legalEntityConsent);
        }
        insert legalEntityConsentList;
    }
    
    static testMethod void assignLeadTEST(){ 
/*        Map<String,List<XC_LegalEntityConsent__c>> legalEntityMap = new Map<String,List<XC_LegalEntityConsent__c>>();
        List<XC_LegalEntityConsent__c> lamList = [SELECT Id, XC_LegalEntity__c FROM XC_LegalEntityConsent__c];*/
        List<Lead> leadList = [SELECT Id,Name, Status, XC_Country__c,XC_Segment__c, XC_City__c, XC_ZipCode__c, Email,XC_LeadPhone__c, XC_Address__c, XC_ProductCategoryOfInterest__c, OwnerId, XC_Channel__c, XC_MainLegalEntity__c
                                 FROM Lead]; //NA 2506
        XC_ProductCategoryOfInterest__c product = new XC_ProductCategoryOfInterest__c();
        product.Name = 'Boiler';
        product.XC_CommercialVisit__c = true;
        insert product;
        
        XC_LeadAssignmentMaster__c lam1 = new XC_LeadAssignmentMaster__c();
        lam1.XC_Email__c = 'Yes';
        lam1.XC_RecordTypePick__c = 'Spain';
        lam1.XC_AssignedToCreator__c = true;
        lam1.XC_ProductCategoryOfInterest__c = 'Caldera';
        lam1.XC_AssignedToCreator__c = true;
        lam1.XC_Status__c = Label.XC_CL_Lead_Assigned;
        insert lam1;
        /*for(Lead ld : leadList){
        	legalEntityMap.put(ld.Id, lamList);
        }*/
        
        test.startTest(); 
    	//XC_UTIL_LeadAssignment.assignLead(leadList, legalEntityMap);
    	XC_UTIL_LeadAssignment.assignLead(leadList);

        test.stopTest();
        
        System.assertEquals(11, leadList.size());
    }
    
    
    static testMethod void assignLeaduserTEST(){ 

        XC_LeadAssignmentMaster__c lam2 = new XC_LeadAssignmentMaster__c();
        lam2.XC_Email__c = 'Yes';
        lam2.XC_RecordTypePick__c = 'Spain';
        lam2.XC_AssignedToUser__c = userinfo.getUserId();
        lam2.XC_ProductCategoryOfInterest__c = 'Caldera';
        lam2.XC_OrderOfEvaluation__c=1;
        lam2.XC_AssignedToCreator__c = false;
        lam2.XC_Status__c = Label.XC_CL_Lead_Assigned;
        insert lam2;
        List<Lead> leadList = [SELECT Id,Name, Status, XC_Country__c,XC_Segment__c,XC_City__c, XC_ZipCode__c, Email,XC_LeadPhone__c, XC_Address__c, XC_ProductCategoryOfInterest__c, OwnerId, XC_Channel__c, XC_MainLegalEntity__c FROM Lead];
        XC_ProductCategoryOfInterest__c product = new XC_ProductCategoryOfInterest__c();
        product.Name = 'Boiler';
        product.XC_CommercialVisit__c = false;
        insert product;
        
        test.startTest(); 
    	XC_UTIL_LeadAssignment.assignLead(leadList);
		system.debug('lam2.XC_AssignedToUser__c => ' + lam2.XC_AssignedToUser__c);
        test.stopTest();
        
        System.assertEquals(11, leadList.size());
    }
    
    static testMethod void assignLeadQueueTEST(){ 

        XC_LeadAssignmentMaster__c lam2 = new XC_LeadAssignmentMaster__c();
        lam2.XC_Email__c = 'Yes';
        lam2.XC_RecordTypePick__c = 'Spain';
        lam2.XC_AssignedToQueue__c = 'Queue';
        lam2.XC_ProductCategoryOfInterest__c = 'Caldera';
        lam2.XC_OrderOfEvaluation__c=1;
        lam2.XC_AssignedToCreator__c = false;
        lam2.XC_Status__c = Label.XC_CL_Lead_Assigned;
        insert lam2;
        List<Lead> leadList = [SELECT Id,Name,XC_Segment__c ,Status, XC_Country__c, XC_City__c, XC_ZipCode__c, Email,XC_LeadPhone__c, XC_Address__c, XC_ProductCategoryOfInterest__c, OwnerId, XC_Channel__c, XC_MainLegalEntity__c FROM Lead];

        test.startTest(); 
    	XC_UTIL_LeadAssignment.assignLead(leadList);
        		system.debug('lam2.XC_AssignedToQueue__c => ' + lam2.XC_AssignedToQueue__c);

        test.stopTest();
        
        System.assertEquals(11, leadList.size());
    }    
    
    static testMethod void checkExactMatchTEST(){

        List<XC_LegalEntityConsent__c> lamList = [SELECT Id, XC_LegalEntity__c FROM XC_LegalEntityConsent__c];
        XC_UTIL_LeadAssignment.LeadAssignmentWrapper leadAssiWr = new XC_UTIL_LeadAssignment.LeadAssignmentWrapper();
       	XC_UTIL_LeadAssignment.CheckMatchLeadWrapper checkLeadWrapper = new XC_UTIL_LeadAssignment.CheckMatchLeadWrapper();
        XC_UTIL_LeadAssignment.LeadAssignmentWrapperResult leadAssignWrappResult = new XC_UTIL_LeadAssignment.LeadAssignmentWrapperResult ();
        leadAssignWrappResult.status = 'Success';
        leadAssignWrappResult.assignedTo = 'Candidatos - Cola Grupo A';
        
        XC_LeadAssignmentMaster__c lam = new XC_LeadAssignmentMaster__c();
        lam.XC_Email__c = 'Yes';
        lam.XC_RecordTypePick__c = 'Spain';
        lam.XC_PrimaryPhone__c = 'Yes';
        lam.XC_Address__c = 'Yes';
        //lam.XC_Channel__c = 'Retail';
        //lam.XC_Channel__c = 'Web';
        lam.XC_Country__c = 'Spain';
        lam.XC_City__c = 'Madrid';
        lam.XC_AssignedToCreator__c = true;
        lam.XC_ProductCategoryOfInterest__c = 'Caldera';
        lam.XC_ZipCode__c = '08000'; 
        lam.XC_LegalEntity__c = 'EndesaX';
        lam.XC_Status__c = Label.XC_CL_Lead_Assigned;
        insert lam;

        String consentLE = 'EndesaX';
        Lead ld = new Lead();
        ld.Lastname = 'Test';
        ld.Company = 'Test company';
        ld.Email = 'Testlead@test.it';
        ld.XC_PhonePrefix__c = '+39';
        ld.XC_LeadPhone__c = '0112345667';
		ld.XC_Address__c = 'Calle Espana';  
        ld.XC_LeadSource__c = 'BLOG';
        ld.XC_Channel__c = 'Web';
        //ld.XC_Channel__c = 'Retail';
        ld.XC_Country__c = 'Spain';
        ld.XC_City__c = 'Madrid';
        ld.XC_ZipCode__c = '08000';
        ld.XC_ProductCategoryOfInterest__c = 'Caldera';
        ld.XC_DocumentType__c = '';
        ld.XC_DocumentCountry__c= 'Spain';
        insert ld;
        leadAssignWrappResult.lead = ld;
        checkLeadWrapper.resultWrapper = leadAssignWrappResult;
        
        XC_UTIL_LeadAssignment.CheckMatchWrapper checkWrapper = new XC_UTIL_LeadAssignment.CheckMatchWrapper();
        checkWrapper.jump = false;
        checkWrapper.skipped = true;
        checkWrapper.ld = ld;
        checkWrapper.lam = lam;
        checkWrapper.consentLE = consentLE;
        checkWrapper.resultMatch = checkLeadWrapper;
        
        leadAssiWr.orderOfEvaluation = 1;
        leadAssiWr.isEmail = 'Yes';
        leadAssiWr.isPhone = 'Yes';
        leadAssiWr.isAddress = 'Yes';
        leadAssiWr.receivingChannel = 'Web';
        leadAssiWr.productCategoryofInterest = 'Boiler'; 
        leadAssiWr.country = 'Spain';
        leadAssiWr.city = 'Madrid';
        leadAssiWr.zipCode = '08000';  
        leadAssiWr.lead = ld;  
        checkWrapper.leadWrapper = leadAssiWr;
            
        test.startTest(); 
        XC_UTIL_LeadAssignment_U_Check.checkExactMatch(checkWrapper);
        XC_UTIL_LeadAssignment_U_Check.checkWildCardMatch(checkWrapper);

        ld.Status = Label.XC_CL_Lead_Assigned;
        XC_UTIL_LeadAssignment_U.setDateTime(ld);

        ld.Status = Label.XC_CL_Lead_PendingScheduling;
        XC_UTIL_LeadAssignment_U.setDateTime(ld);
        
        test.stopTest();
    	System.assertEquals(11, lamList.size());
    }
    
    
}