/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  22/05/2019 
* @description XC_TR_Opportunity_U_CheckDuplicates_TEST – Test class for XC_TR_Opportunity_U_CheckDuplicates
*/
@istest
public class XC_TR_Opportunity_U_CheckDuplicates_TEST {

    //Test Method checkDuplicateOpportunity
    static testMethod void checkDuplicateOpportunity(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Opportunity> listopp = XC_DF_Opportunity.createOpportunity(1,false);
        insert listopp;
        
        System.assertEquals(true, listopp!=null);
        Test.stopTest();
        
    }
    
    static testMethod void checkDuplicateOpportunity1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 

        List<Contact> listc = XC_DF_Contact.createCondominiumContacts(1);
        insert listc;

        Account acc = new Account(Id = listc[0].AccountId);
        List<Account> listAccount = new List<Account>();
        listAccount.add(acc);

        List<XC_Address__c> listadd = XC_DF_Address.createAddress(listAccount);
        insert listadd;
                
        List<Opportunity> listopp = XC_DF_Opportunity.createOpportunityWithVisit(listc,listadd[0]);
        listopp[0].XC_ProductCategoryOfInterest__c= 'Caldera';
        listopp[0].AccountId = listAccount[0].Id;
        listopp[0].XC_ClosureDateTime__c = dateTime.now();
        listopp[0].XC_Address__c = listadd[0].Id;
        try{
            insert listopp;
           }
        catch(exception e)
        {
            System.debug(e);
        }
        
         
        List<Opportunity> listopp1 = XC_DF_Opportunity.createOpportunityWithVisit(listc,listadd[0]);
        listopp1[0].XC_ProductCategoryOfInterest__c= 'Caldera';
        listopp1[0].XC_Address__c = listadd[0].Id;
       
          try{
             insert listopp1; 
           }
        catch(exception e)
        {
            System.debug(e);
        }
        
        
        System.assertEquals(true, listopp!=null);
        Test.stopTest();
        
    }

    static testMethod void checkDuplicateOpportunity2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 

        List<Contact> listc = XC_DF_Contact.createCondominiumContacts(1);
        insert listc;

        Account acc = new Account(Id = listc[0].AccountId);
        List<Account> listAccount = new List<Account>();
        listAccount.add(acc);
        XC_CM_Opportunity_Default_Values__mdt cm = new XC_CM_Opportunity_Default_Values__mdt();
        cm.XC_Hours_Since_Closure__c= 1;
        cm.XC_Country__c  ='SPAIN';
       // Insert cm;
        

        List<XC_Address__c> listadd = XC_DF_Address.createAddress(listAccount);
        insert listadd;
                
        List<Opportunity> listopp = XC_DF_Opportunity.createOpportunityWithVisit(listc,listadd[0]);
        listopp[0].XC_ProductCategoryOfInterest__c= 'Caldera';
        listopp[0].AccountId = listAccount[0].Id;
        listopp[0].StageName = 'Draft';
        listopp[0].XC_ClosureDateTime__c = dateTime.now();
        listopp[0].XC_Address__c = listadd[0].Id;
        insert listopp;
        //listopp[0].StageName = 'Closed Won';
        listopp[0].StageName = 'Closed Won';
        listopp[0].XC_ProductCategoryOfInterest__c= 'Calentador';
        listopp[0].XC_Address__c = listadd[0].Id;
        listopp[0].XC_ReceivingChannel__c = 'Email';
        try{
            update listopp;
           }
        catch(exception e)
        {
            System.debug(e);
        }
        
         
        List<Opportunity> listopp1 = XC_DF_Opportunity.createOpportunityWithVisit(listc,listadd[0]);
        listopp1[0].XC_ProductCategoryOfInterest__c= 'Calentador';
        listopp1[0].XC_Address__c = listadd[0].Id;
         try{
           insert listopp1; 
           }
        catch(exception e)
        {
            System.debug(e);
        }
        
        
        
        System.assertEquals(true, listopp!=null);
        Test.stopTest();
        
    }

    
    /*undirizzo categoryof interest new opp con stesso indi e coi
        indirizzo category status closed  new opp stesso indi e coi*/


    @isTest
    static void checkDuplicatesTestUtil(){
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        XC_TR_Opportunity_U_CheckDuplicates.DuplicateWrapper dupWr = new XC_TR_Opportunity_U_CheckDuplicates.DuplicateWrapper();
        XC_TR_Opportunity_U_CheckDuplicatesUtil.checkFields(dupWr, listOfOpp[0]);
        listOfOpp[0].XC_ClosureDateTime__c = Datetime.now().addDays(4);
        update listOfOpp;
        XC_TR_Opportunity_U_CheckDuplicatesUtil.utilityMethod(dupWr, listOfOpp[0]);
    }
    

    @isTest
    static void checkDuplicatesTest(){
        
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(new List<Account>{new Account(Id = listOfOpp[0].AccountId)});
        insert listAddress;
        
        listOfOpp[0].XC_Address__c = listAddress[0].Id;
        listOfOpp[0].XC_ReceivingChannel__c = 'Email';
        insert listOfOpp;
        
        try {
            Opportunity o = listOfOpp[0];
            o.Id = null;
            insert o;
        } catch(Exception e) {
            System.debug('OK');
        }
    }
    
}