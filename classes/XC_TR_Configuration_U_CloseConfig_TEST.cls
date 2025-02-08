/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  20/05/2019 
    * @description XC_TR_Configuration_U_CloseConfig_TEST – Test class for XC_TR_Configuration_U_CloseConfiguration
    */ 
    @isTest
    public with sharing class XC_TR_Configuration_U_CloseConfig_TEST {

        @TestSetup
        static void insertRecord(){
            Integer n = 1;
            Id configOptyId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
            List<NE__Order__c> orderList = new List<NE__Order__c>();
            insert XC_DF_OneOrg.createOneOrg('Spain'); 
            List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(n, true);
            oppList[0].XC_ProductCategoryOfInterest__c = 'Aire acondicionado';
            insert oppList; 
            List<Case> listCase= XC_DF_Case.createCases(n);
            insert listCase;
        
            List<WorkOrder> woList = new List<WorkOrder>();
            for(Integer i = 0; i<n; i++){
                NE__Order__c order = new NE__Order__c();
                order.NE__OptyId__c = oppList[i].Id;
                order.NE__AccountId__c = oppList[i].AccountId;
                order.RecordTypeId = configOptyId;
                order.NE__Type__c = Label.XC_CL_Configuration_TypeDisconnection;
                order.XC_CaseId__c =listCase[i].Id;
                orderList.add(order);
            }
            insert orderList;
        } 
        
        //Test method closeConfiguration
        static testMethod void closeConfiguration(){
            //insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
            List<NE__Order__c> conf = XC_DF_Order.createOrders(1, 'Quote');
            List<NE__OrderItem__c> confitem = XC_DF_OrderItem.createOrderItems(1);
            insert confitem;
              
            update confitem;
            String confitemId = confitem[0].Id;
            XC_Provisioning_Step__c provstep= XC_DF_ProvisioningStep.createProvisioningStep(confitemId);
            /*provstep.XC_Status__c = 'Completed OK';
            System.debug('@@@- CONF ITEM INFO '+ conf.XC_NumberOfConfigurationItem__c);
            System.debug('@@@- CONF ITEM INFO '+ conf.XC_NumberOfConfigurationItemCompleted__c);
            System.debug('@@@- CONF ITEM INFO '+ confitem);*/
            
            system.debug(LoggingLevel.FINEST,'provStep'+provstep);
            System.assertEquals(1, conf.size());
            Test.stopTest();
        }

        static testMethod void closeCase() {
            /*
            List<NE__Order__c> orderList  = [SELECT Id FROM NE__Order__c WHERE XC_CaseId__c != null AND NE__Type__c = :Label.XC_CL_Configuration_TypeDisconnection];              
            insert orderList;       
            NE__OrderItem__c confitem = XC_DF_OrderItem.createOrderItem(orderList[0]);
            List<NE__OrderItem__c> confItemList= new List<NE__OrderItem__c>();
            confItemList.add(confitem);
            insert confItemList;
            //confitem[0].NE__Status__c ='Completed';  
            
            String confitemId = confitem.Id;
            XC_Provisioning_Step__c provstep= XC_DF_ProvisioningStep.createProvisioningStep(confitemId);
            provstep.XC_Status__c='Completed OK';
            insert provstep;            
            Test.startTest();
            update confItemList;
            Test.stopTest();
            System.assertEquals(10, orderList.size(),'Error assertEquals');
            */
            //List<NE__Order__c> conf  = [SELECT Id,XC_Status__c,NE__Type__c FROM NE__Order__c WHERE XC_CaseId__c != null AND NE__Type__c = :Label.XC_CL_Configuration_TypeDisconnection ];   
            List<NE__Order__c> conf = XC_DF_Order.createOrders(1, 'Disconnection');
            insert conf;
            Test.startTest();
            List<Case> listCase= XC_DF_Case.createCases(1);
            insert listCase;
            conf[0].XC_CaseId__c =listCase[0].Id;
            List<NE__OrderItem__c> confitem = XC_DF_OrderItem.createOrderItems(1);
            confitem[0].NE__OrderId__c=conf[0].Id;

            //confitem.add(confit);
            insert confitem;
            //confitem[0].NE__Status__c ='Completed';  
            
            String confitemId = confitem[0].Id;
            System.debug('Order con status: '+ conf[0].XC_Status__c + ' type: '+ conf[0].NE__Type__c);
            XC_Provisioning_Step__c provstep= XC_DF_ProvisioningStep.createProvisioningStep(confitemId);
            provstep.XC_Status__c='Completed OK';
            insert provstep;
            conf[0].XC_Status__c = Label.XC_CL_Configuration_Closed;
            update conf;
            System.assertEquals(1, confitem.size());
            Test.stopTest();
    }
}