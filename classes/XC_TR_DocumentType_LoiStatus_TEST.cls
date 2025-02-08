@isTest
public class XC_TR_DocumentType_LoiStatus_TEST {
	
    @isTest
    static void loiStatus(){
        List<XC_DocumentType__c> listNew = new List<XC_DocumentType__c>();
        XC_DocumentType__c doc = new XC_DocumentType__c();
        
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        insert opp;
        
        doc.Category__c = 'SF_LOI_SIGNED';
        doc.opportunity__c = opp[0].id;
        listNew.add(doc);
        Test.startTest();
        	XC_TR_DocumentType_LoiStatus.loiStatus(listNew);
        Test.stopTest();
    }
    
     
    @isTest static void updateOrder(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, Label.XC_CL_Configuration_TypeInOrder);
        insert orderList;
        
        XC_DocumentType__c documentType = new XC_DocumentType__c();
        documentType.Category__c = Label.XC_CL_Document_ContractSigned;
        documentType.XC_Configuration__c =orderList[0].Id;
        documentType.XC_DoxeeUrl__c = 'Url doxee';
        insert documentType;
    	 documentType.XC_DoxeeUrl__c ='Test';
        update documentType;
        System.assert(documentType!= null, documentType);
        Test.stopTest(); 
        }  
}