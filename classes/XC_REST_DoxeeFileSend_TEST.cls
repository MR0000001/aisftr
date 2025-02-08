/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  28/05/2019 
* @description XC_REST_DoxeeFileSend_TEST – Test class for XC_REST_DoxeeFileSend
*/
@isTest
public class XC_REST_DoxeeFileSend_TEST {
    
    //Test Method createFile
    static testMethod void createFile(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_REST_DoxeeFileSend_U.RequestWrapper wr = new XC_REST_DoxeeFileSend_U.RequestWrapper();
        
        
        XC_REST_DoxeeFileSend_U.ResponseWrapper rw = XC_REST_DoxeeFileSend.createFile(wr);
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method createFile1
    static testMethod void createFile1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_REST_DoxeeFileSend_U.RequestWrapper wr = new XC_REST_DoxeeFileSend_U.RequestWrapper();
        wr.File.FileName = 'test';
        wr.File.FileCreationDate= 'test';
        wr.File.FileCategory= 'test';
        wr.File.FileBase64='test';
        wr.File.ObjectType= 'test';
        wr.File.ObjectID =  'test';
        wr.File.Company ='test';
        wr.File.Country = 'SPAIN';
     
        
        /*XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = Label.XC_CL_CreateFile;
        ic.XC_interfaceName__c = Label.XC_CL_CreateFile;
        insert ic;*/
        
        XC_REST_DoxeeFileSend_U.ResponseWrapper rw = XC_REST_DoxeeFileSend.createFile(wr);
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method createFile2
    static testMethod void createFile2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_REST_DoxeeFileSend_U.RequestWrapper wr = new XC_REST_DoxeeFileSend_U.RequestWrapper();
        wr.File.FileSize =1;
        wr.File.FileName = 'test';
        wr.File.FileCreationDate= 'test';
        wr.File.FileCategory= 'test';
        wr.File.FileBase64='test';
        wr.File.ObjectType= 'test';
        wr.File.ObjectID =  'test';
        wr.File.Company ='test';
        wr.File.Country = 'SPAIN';
        
        
        XC_REST_DoxeeFileSend_U.ResponseWrapper rw = XC_REST_DoxeeFileSend.createFile(wr);
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method createFile3
    static testMethod void createFile3(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_REST_DoxeeFileSend_U.RequestWrapper wr = new XC_REST_DoxeeFileSend_U.RequestWrapper();
        wr.File.FileSize =1;
        wr.File.FileName = 'test';
        wr.File.FileCreationDate= 'test';
        wr.File.FileCategory= 'SF_QUALITY_CONTROL_RECORD';
        wr.File.FileBase64='test';
        wr.File.ObjectType= 'CONFIGURATION';
        wr.File.ObjectID =  'test';
        wr.File.Company ='test';
        wr.File.Country = 'SPAIN';
        	
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CreateFile;
        ic.XC_interfaceName__c = Label.XC_CL_CreateFile;
        insert ic;
        
        XC_REST_DoxeeFileSend_U.ResponseWrapper rw = XC_REST_DoxeeFileSend.createFile(wr);
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    //Test Method createFile4
    static testMethod void createFile4(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_REST_DoxeeFileSend_U.RequestWrapper wr = new XC_REST_DoxeeFileSend_U.RequestWrapper();
        wr.File.FileSize =1;
        wr.File.FileName = 'test';
        wr.File.FileCreationDate= 'test';
        wr.File.FileCategory= 'SF_QUALITY_CONTROL_RECORD';
        wr.File.FileBase64='test';
        wr.File.ObjectType= 'CONFIGURATION';
        wr.File.ObjectID =  'test';
        wr.File.Company ='test';
        wr.File.Country = 'SPAIN';
        	
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CreateFile;
        ic.XC_interfaceName__c = Label.XC_CL_CreateFile;
        insert ic;
        
        XC_REST_DoxeeFileSend_U.ResponseWrapper rw = XC_REST_DoxeeFileSend.createFile(wr);
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
}