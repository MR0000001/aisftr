/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  21/05/2019 
* @description XC_UTIL_Opportunity_TEST – Test class for XC_UTIL_Opportunity 
*/
@istest
public class XC_UTIL_Opportunity_TEST{
    
    //Test Method createOpportunity
    static testMethod void createOpportunity(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();  
        
        list <account> lstacc = XC_DF_Account.createCondominiumAccounts(1);
        list <lead> lstld = XC_DF_Lead.createCondominiumLeads(1);
        
        opportunity opp = XC_UTIL_Opportunity.createOpportunity(lstacc[0] , lstld[0]);
        
        //System.assertEquals(true, opp!=null);
        Test.stopTest();
        
    }
    
    
     //Test Method getRecordTypeByCountry
    static testMethod void getRecordTypeByCountry(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();  
        
        list<string> ls = new list<string>();
        
        XC_UTIL_Opportunity.getRecordTypeByCountry(ls);
        
        //System.assertEquals(true, ls!=null);
        Test.stopTest();
        
    }
    
    
    //Test Method getDefaultCloseDateByCountry
    static testMethod void getDefaultCloseDateByCountry(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();  
        
        list<string> ls = new list<string>();
        ls.add('SPAIN');
        
        Map<String, Date> mp = XC_UTIL_Opportunity.getDefaultCloseDateByCountry(ls);
        
        //System.assertEquals(true, ls!=null);
        Test.stopTest();
        
    }
    
    
   
}