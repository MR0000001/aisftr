@isTest
public with sharing class TA_LCC216_GeneratedReportCnt_Test {
    
        @testSetup 
        static void setup( ) 
        {
            NE__Order__c order = new NE__Order__c();
            order.NE__Type__c = 'Order';
            order.XC_Country__c = 'Spain';
            order.XC_Segment__c = 'B2C';
            order.XC_LegalEntity__c ='EndesaX';
            order.XC_FinancialInstitution__c ='institutionFinancial';
            order.XC_FinancialPracticeNumber__c ='testFinancial01';
            order.XC_FinancialPracticeStatus__c ='OK';
            insert order;
            String param = '{"quoteToAccept":"' + order.Id + '"}';
    
            List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
            wo[0].XC_Configuration__c = order.Id;
            insert wo;
    
            ContentVersion contentVersion = new ContentVersion
            (
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;    
    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = order.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
    
        }
    
        @isTest
        static void init_test( ) 
        {
            WorkOrder wo = [ SELECT Id FROM WorkOrder LIMIT 1 ];
    
            Test.startTest( );
            TA_LCC216_GeneratedReportCnt.init( wo.Id, true );
            TA_LCC216_GeneratedReportCnt.init( null, null );
            Test.stopTest( );
        }
    }