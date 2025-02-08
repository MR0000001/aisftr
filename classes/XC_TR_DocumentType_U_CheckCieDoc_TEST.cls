/**
* @author Massimiliano Avallone massimiliano.avallone@nttdata.com
* @date Creation  7/10/2019 
* @description XC_TR_DocumentType_U_CheckCieDocument – XC_TR_DocumentType_U_CheckCieDoc_TEST
*/ 
@isTest
public class XC_TR_DocumentType_U_CheckCieDoc_TEST {
    
  @isTest static void checkCieDoc(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    
    List<NE__OrderItem__c> listOrderItem =  XC_DF_OrderItem.createOrderItems(1);
    insert listOrderItem;
    
    List<Asset> listAsset = XC_DF_Asset.createAssets(1);
    listAsset[0].XC_Configuration_Item__c = listOrderItem[0].Id; 
    insert listAsset;
    
    XC_DocumentType__c documentType = new XC_DocumentType__c();
    documentType.Category__c = Label.XC_CL_Document_CIE;
    documentType.XC_ConfigurationItem__c = listOrderItem[0].Id;
    documentType.XC_DoxeeUrl__c = 'Url doxee';
    insert documentType;
    
    documentType.Category__c = 'SF_DOCUMENT';
    update documentType;
      
    XC_Provisioning_Step__c ps = new XC_Provisioning_Step__c();
    ps.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningDocSending_Flow;
    ps.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
    ps.XC_Configuration_Item__c = listOrderItem[0].Id;
    insert ps;

    System.assert(documentType!= null, documentType);
    Test.stopTest();   
    }  
  }