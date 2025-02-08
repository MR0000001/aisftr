/**
* @author            : Giuseppe Di Bonito
* @date Creation     : 19/02/2021
* @description XC_REST_SendPEC_TEST – Test class for XC_REST_SendPEC and XC_REST_SendPEC_U
*/
@isTest
public class XC_REST_SendPEC_TEST {
    
    static testMethod void sendRequestFail(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_REST_SendPEC_U.RequestWrapper wr = new XC_REST_SendPEC_U.RequestWrapper();
        
        XC_REST_SendPEC_U.ResponseWrapper rw = XC_REST_SendPEC.sendRequest(wr);
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    static testMethod void sendRequest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_REST_SendPEC_U.RequestWrapper wr = new XC_REST_SendPEC_U.RequestWrapper();
        wr.SendPEC.receiver_pec = 'test';
        wr.SendPEC.body= 'test';
        wr.SendPEC.subject= 'test';
        wr.SendPEC.sender_pec='test';
        wr.SendPEC.legal_entity= 'test';
        wr.SendPEC.email_type =  'test';   
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'SendPEC';
        ic.XC_interfaceName__c = 'SendPEC';
        insert ic;
   
        XC_REST_SendPEC_U.ResponseWrapper rw = XC_REST_SendPEC.sendRequest(wr);
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
}