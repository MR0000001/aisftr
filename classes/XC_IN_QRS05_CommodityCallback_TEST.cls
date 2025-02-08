/**
 * @File Name          : XC_IN_QRS05_CommodityCallback_TEST.cls
 * @Description        : TEST CLASS FOR XC_IN_QRS05_CommodityCallback
 * @Author             : Marco Ottaviano - mottaviano@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 11-04-2020
 * @Modification Log   : 
 * @TestClass          : 
 * Ver       Date            Author      		    Modification
 * 1.0    13/07/2020   Marco Ottaviano - mottaviano@deloitte.it     Initial Version
**/



@isTest
public without sharing class XC_IN_QRS05_CommodityCallback_TEST {

    @TestSetup
    static void makeData(){
       List<XC_QueuedRequest__c> qrList = XC_DF_QueuedRequest.createQueuedRequest(1);
       insert qrList;

       XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
       csInt.Name = 'OrderChargerCallback';
       csInt.XC_activeInterface__c = true;
       csInt.XC_interfaceName__c = 'OrderChargerCallback';
       csInt.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
       csInt.XC_Country__c = 'Italy';
       csInt.XC_ServerSystem__c = 'Test';
       insert csInt;
    }

    @isTest 
    static void test_one() {
        XC_QueuedRequest__c qr = [SELECT Id,XC_Status__c FROM XC_QueuedRequest__c];
        qr.XC_Status__c ='In Error';
         update qr;
        List<XC_QueuedRequestStep__c> qstlist=[SELECT Id,XC_Status__c,XC_ErrorMessage__c,XC_StepLabel__c FROM XC_QueuedRequestStep__c WHERE XC_QueuedRequest__c =: qr.Id ORDER BY XC_StepSequence__c ASC];
        List<XC_QueuedRequestStep__c> qsttuoUp = new List<XC_QueuedRequestStep__c>();
        XC_QueuedRequestStep__c qstCallb;
        for(XC_QueuedRequestStep__c qs :qstlist) {
            if(qs.XC_StepLabel__c !='Commodity Callback') {
                qs.XC_Status__c ='Completed KO';
                qs.XC_ErrorMessage__c ='errorMsg';
                qsttuoUp.add(qs);
            } else {
                qstCallb = new XC_QueuedRequestStep__c(Id = qs.Id);
            }
        }

        update qsttuoUp;
        Test.startTest();
       
            XC_IN_QRS05_CommodityCallback.InputWrapper inWr = new XC_IN_QRS05_CommodityCallback.InputWrapper();
            inWr.stepId = qstCallb.Id;
            XC_IN_QRS05_CommodityCallback.executeCommodityCallBack(new List<XC_IN_QRS05_CommodityCallback.InputWrapper>{inWr});
        Test.stopTest();
    }

      @isTest 
    static void test_two() {
        XC_QueuedRequest__c qr = [SELECT Id,XC_Status__c FROM XC_QueuedRequest__c];
       
        List<XC_QueuedRequestStep__c> qstlist=[SELECT Id,XC_Status__c,XC_ErrorMessage__c,XC_StepLabel__c FROM XC_QueuedRequestStep__c WHERE XC_QueuedRequest__c =: qr.Id ORDER BY XC_StepSequence__c ASC];
        List<XC_QueuedRequestStep__c> qsttuoUp = new List<XC_QueuedRequestStep__c>();
        XC_QueuedRequestStep__c qstCallb;
        for(XC_QueuedRequestStep__c qs :qstlist) {
            if(qs.XC_StepLabel__c !='Commodity Callback') {
                qs.XC_Status__c ='Completed OK';
                qs.XC_ErrorMessage__c ='';
                qsttuoUp.add(qs);
            } else {
                qstCallb = new XC_QueuedRequestStep__c(Id = qs.Id);
            }
        }

        update qsttuoUp;
        Test.startTest();
       
            XC_IN_QRS05_CommodityCallback.InputWrapper inWr = new  XC_IN_QRS05_CommodityCallback.InputWrapper();
            inWr.stepId = qstCallb.Id;
            XC_IN_QRS05_CommodityCallback.executeCommodityCallBack(new List<XC_IN_QRS05_CommodityCallback.InputWrapper>{inWr});
        Test.stopTest();
    }

    @isTest 
    static void test_three() {
        XC_QueuedRequest__c qr = [SELECT Id,XC_Status__c FROM XC_QueuedRequest__c];
        qr.XC_Status__c ='In Error';
        qr.XC_CallbackRequested__c=true;
        qr.XC_clientSystem__c = 'CommodityItalyB2B';
         update qr;
        List<XC_QueuedRequestStep__c> qstlist=[SELECT Id,XC_Status__c,XC_ErrorMessage__c,XC_StepLabel__c FROM XC_QueuedRequestStep__c WHERE XC_QueuedRequest__c =: qr.Id ORDER BY XC_StepSequence__c ASC];
        List<XC_QueuedRequestStep__c> qsttuoUp = new List<XC_QueuedRequestStep__c>();
        XC_QueuedRequestStep__c qstCallb;
        for(XC_QueuedRequestStep__c qs :qstlist) {
            if(qs.XC_StepLabel__c !='Commodity Callback') {
                qs.XC_Status__c ='Completed KO';
                qs.XC_ErrorMessage__c ='errorMsg';
                qsttuoUp.add(qs);
            } else {
                qstCallb = new XC_QueuedRequestStep__c(Id = qs.Id);
            }
        }

        update qsttuoUp;
        Test.startTest();
       
            XC_IN_QRS05_CommodityCallback.InputWrapper inWr = new XC_IN_QRS05_CommodityCallback.InputWrapper();
            inWr.stepId = qstCallb.Id;
            XC_IN_QRS05_CommodityCallback.executeCommodityCallBack(new List<XC_IN_QRS05_CommodityCallback.InputWrapper>{inWr});
        Test.stopTest();
    }
}