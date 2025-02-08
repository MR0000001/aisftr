/**
 * The Class XC_IN034_UploadFreekWh_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 07/10/2019
 * @date Modification : 
 * @description       : XC_IN034_UploadFreekWh_TEST - Test class for XC_IN034_UploadFreekWh, XC_IN034_UploadFreekWh_D and XC_REST_UploadFreekWh
 **/

@isTest
public without sharing class XC_IN034_UploadFreekWh_TEST {


    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;

        NE__Family__c  family = new NE__Family__c (Name = 'KWH Free', XC_LIC_Family_Name__c = 'KWH Free');
        insert family; 

        List<NE__DynamicPropertyDefinition__c> dpdList = new List<NE__DynamicPropertyDefinition__c>();
        NE__DynamicPropertyDefinition__c dpd = new NE__DynamicPropertyDefinition__c(Name = 'Activation Free', XC_LIC_DynamicPropertyDefinition__c = 'Activation Free');
        NE__DynamicPropertyDefinition__c dpd2 = new NE__DynamicPropertyDefinition__c(Name = 'Duration', XC_LIC_DynamicPropertyDefinition__c = 'Duration');
        dpdList.add(dpd);
        dpdList.add(dpd2);
        insert dpdList;

        List<NE__ProductFamilyProperty__c> pfpList = new List<NE__ProductFamilyProperty__c>();
        NE__ProductFamilyProperty__c pfp = new NE__ProductFamilyProperty__c(NE__PropId__c = dpd.Id, NE__FamilyId__c = family.Id);
        NE__ProductFamilyProperty__c pfp2 = new NE__ProductFamilyProperty__c(NE__PropId__c = dpd2.Id, NE__FamilyId__c = family.Id);
        pfpList.add(pfp);
        pfpList.add(pfp2);
        insert pfpList;

        zqu__Quote__c  zquote = new zqu__Quote__c  (Name = 'test');
        insert zquote; 

        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, false);
        oppList[0].XC_LegalEntity__c = 'EndesaX';
        Contact c = [SELECT Id, LastName FROM Contact LIMIT 1][0];
        c.XC_PrimaryContact__c = true;
        update c; 
        Individual ind = new Individual (Contact__c = c.Id, LastName = c.LastName);
        insert ind;
        insert oppList;
       

        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c ordIt = orderItemList[0];
        ordIt.XC_ZQuoteId__c = zquote.Id;
        insert ordIt;
        
        NE__Order__c order = [SELECT Id FROM NE__Order__c WHERE Id =: ordIt.NE__OrderId__c][0];
        order.NE__OptyId__c = oppList[0].Id;
        update order; 


        List<NE__Order_Item_Attribute__c> itemAttrList = new List<NE__Order_Item_Attribute__c>();
        NE__Order_Item_Attribute__c itemAttr = XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItemList[0], 'Activation Free', 'true');
        itemAttr.NE__FamPropId__c = pfp.Id;
        NE__Order_Item_Attribute__c itemAttr2 = XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItemList[0], 'Duration', '5'); 
        itemAttr2.NE__FamPropId__c = pfp2.Id;
        itemAttrList.add(itemAttr);
        itemAttrList.add(itemAttr2);
        insert itemAttrList;
        
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset ast = assetList[0];
        ast.XC_Configuration_Item__c = ordIt.Id;
        ast.XC_Original_Configuration_Item__c = ordIt.Id;
        insert ast;

        
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = '/workflows/UploadFreekWh/run';
        ic.Name = Label.XC_CL_UploadFreekWh;
        ic.XC_interfaceName__c = Label.XC_CL_UploadFreekWh;
        insert ic;
    }


    /*
	*@ Description  upload free kWh - Response OK
	*/
    static testMethod void uploadFreeKwhTEST(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN034_UploadFreekWh.InputWrapper inw = new XC_IN034_UploadFreekWh.InputWrapper();
        List<XC_IN034_UploadFreekWh.InputWrapper> inputWrapperList = new List<XC_IN034_UploadFreekWh.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        Test.setMock(HttpCalloutMock.class, new UploadFreeKwhMock());
        XC_IN034_UploadFreekWh.applyFreekWh(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size(), 'Wrong assert result');
    }


    /*
	*@ Description  upload free kWh - Without legal entity 
	*/
    static testMethod void uploadFreeKwhTEST1(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];

        Opportunity opp = [SELECT Id FROM Opportunity];
        opp.XC_LegalEntity__c = '';
        update opp;
        
        XC_IN034_UploadFreekWh.InputWrapper inw = new XC_IN034_UploadFreekWh.InputWrapper();
        List<XC_IN034_UploadFreekWh.InputWrapper> inputWrapperList = new List<XC_IN034_UploadFreekWh.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        Test.setMock(HttpCalloutMock.class, new UploadFreeKwhMock());
        XC_IN034_UploadFreekWh.applyFreekWh(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size(), 'Wrong assert result');
    }


    /*
	*@ Description  upload free kWh - Response KO
	*/
    static testMethod void uploadFreeKwhTEST2(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN034_UploadFreekWh.InputWrapper inw = new XC_IN034_UploadFreekWh.InputWrapper();
        List<XC_IN034_UploadFreekWh.InputWrapper> inputWrapperList = new List<XC_IN034_UploadFreekWh.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        Test.setMock(HttpCalloutMock.class, new UploadFreeKwhMock_KO());
        XC_IN034_UploadFreekWh.applyFreekWh(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size(), 'Wrong assert result');
    }



    /*
	*@ Description mock class to call zuora - upload free kWh
	*/
    public without sharing class UploadFreeKwhMock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('/workflows/UploadFreekWh/run')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"id":13010,"name":"WF-6969-00000002","originalWorkflowId":6969,"type":"Workflow::Instance","status":"Queued"}');
                response.setStatusCode(200); 
            } 
            return response;
        }
    }


    /*
	*@ Description mock class to call zuora - upload free kWh KO
	*/
    public without sharing class UploadFreeKwhMock_KO implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('/workflows/UploadFreekWh/run')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('');
                response.setStatusCode(406); 
            } 
            return response;
        }
    }


}