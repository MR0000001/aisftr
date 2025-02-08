/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation  04/05/2021
* @description 
*/ 

@isTest
public class XC_LCC241_SendPEC_TEST {
    
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;  
        insert org;
        
        XC_B2BG_QualityCheck__c cc = new XC_B2BG_QualityCheck__c();
       	cc.XC_CheckDate__c = Date.today();
        cc.XC_ReportDiSopralluogoRedattoIl__c = Date.today();
        insert cc;
        
		Case c = XC_DF_Case.createCases(1)[0];
        c.Reason = 'XCMOT010';
        c.SubCause__c = 'ATCL008';
        c.XC_LegalEntity__c = 'EndesaX';
        insert c;

    }
    
    
    
    
    @isTest
	static void test(){
        
        case c = [select id from case limit 1];
 
        test.startTest();
        XC_LCC241_SendPEC.retrieveInformation(c.id);
        test.stopTest();

    }
    
    
     @isTest
	static void test1(){
        Map<String,String> n = new Map<String,String>();
        string s = json.serialize(n);
        
        test.startTest();
        XC_LCC241_SendPEC.sendPec(s);
        test.stopTest();
    }
    
    
     @isTest
	static void test2(){
        case c = [select id from case limit 1];
        c.XC_CheckList__c = [select id from XC_B2BG_QualityCheck__c limit 1][0].id;
        update c;
 
        test.startTest();
        XC_LCC241_SendPEC.retrieveInformation(c.id);
        test.stopTest();

    }
    
         @isTest
	static void test3(){
        case c = [select id from case limit 1];
        XC_B2BG_QualityCheck__c cc = [select id from XC_B2BG_QualityCheck__c limit 1][0];
        cc.XC_AnswerL2__c = 'NC';
        cc.XC_NotCompliance_CommentsL2__c = 'test';
        update cc;
        c.XC_CheckList__c = [select id from XC_B2BG_QualityCheck__c limit 1][0].id;
        update c;
 
        test.startTest();
        XC_LCC241_SendPEC.retrieveInformation(c.id);
        test.stopTest();

    }
    

}