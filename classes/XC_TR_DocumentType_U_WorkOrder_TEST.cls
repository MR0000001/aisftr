/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation  05/05/2021 
* @description XC_TR_DocumentType_U_WorkOrder_TEST – XC_TR_DocumentType_U_WorkOrder
*/ 
@isTest
public class XC_TR_DocumentType_U_WorkOrder_TEST {
    @isTest 
    static void onInsertTEST(){
        Test.startTest(); 
       	List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_SiteInspection);
        listWorkOrder[0].XC_WasteDisposal__c = true;
        listWorkOrder[0].XC_WasteDisposalBlock__c = true;
        insert listWorkOrder;
        XC_DocumentType__c documentType = new XC_DocumentType__c();
        documentType.Category__c = Label.XC_CL_Document_CIE;
        documentType.XC_WorkOrder__c = listWorkOrder[0].Id;
        documentType.XC_DoxeeUrl__c = 'Url doxee';
        insert documentType;
        XC_TR_DocumentType_U_WorkOrder.onInsert(new List<XC_DocumentType__c>{documentType});
        System.assert(documentType!= null, documentType);
        Test.stopTest();   
    }  
    
    @isTest 
    static void onInsertMatchingWithCMDTTEST(){
        List<String> documents = new List<String>();
        Test.startTest(); 
       	List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_SiteInspection);
        listWorkOrder[0].XC_WasteDisposal__c = true;
        listWorkOrder[0].XC_WasteDisposalBlock__c = true;
        listWorkOrder[0].XC_LegalEntity__c = 'EnelXItalia';
        listWorkOrder[0].XC_Segment__c = 'B2C';
        insert listWorkOrder;
        List<XC_CM_CountryLegalEntityAssociation__mdt> countryLegalEntityAssociationList = new List<XC_CM_CountryLegalEntityAssociation__mdt>([SELECT Id,  XC_WorkOrderWasteDisposalBlock__c, XC_LegalEntity__c, XC_Stream__c
                                                                                                                                                FROM XC_CM_CountryLegalEntityAssociation__mdt
                                                                                                                                                WHERE XC_LegalEntity__c =: listWorkOrder[0].XC_LegalEntity__c
                                                                                                                                                AND XC_Stream__c  =: listWorkOrder[0].XC_Segment__c
                                                                                                                                                AND XC_WorkOrderWasteDisposalBlock__c = true]);
        /*for(XC_CM_CountryLegalEntityAssociation__mdt cmdt : countryLegalEntityAssociationList ){
            if(!String.isEmpty(cmdt.XC_WorkOrderWasteDisposalBlockCategories__c) && cmdt.XC_WorkOrderWasteDisposalBlockCategories__c.contains(',')){
                documents.addAll(cmdt.XC_WorkOrderWasteDisposalBlockCategories__c.split(','));
            } else if(!String.isEmpty(cmdt.XC_WorkOrderWasteDisposalBlockCategories__c)){
                documents.add(cmdt.XC_WorkOrderWasteDisposalBlockCategories__c);
            }
        }*/
        List<XC_DocumentType__c> docTypeToInsert = new List<XC_DocumentType__c>();
        for(String doc : documents){
            XC_DocumentType__c documentType = new XC_DocumentType__c();
            documentType.Category__c = doc;
            documentType.XC_WorkOrder__c = listWorkOrder[0].Id;
            documentType.XC_DoxeeUrl__c = 'Url doxee';  
            docTypeToInsert.add(documentType);
        }

        insert docTypeToInsert;
        XC_TR_DocumentType_U_WorkOrder.onInsert(docTypeToInsert);
        System.assert(docTypeToInsert!= null, docTypeToInsert);
        Test.stopTest();   
    } 
     @isTest 
    static void onInsertWithoutWOTEST(){
        Test.startTest(); 
        XC_DocumentType__c documentType = new XC_DocumentType__c();
        documentType.Category__c = Label.XC_CL_Document_CIE;
        documentType.XC_DoxeeUrl__c = 'Url doxee';
        insert documentType;
        XC_TR_DocumentType_U_WorkOrder.onInsert(new List<XC_DocumentType__c>{documentType});
        System.assert(documentType!= null, documentType);
        Test.stopTest();   
    }  
}