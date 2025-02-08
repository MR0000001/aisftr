@isTest
public class XC_SegmentUtilitiesTest {

    private static String SEGMENT = 'B2B';
    private static String LEGAL_ENTITY = 'EnelX';

    @testSetup
    static void setup() {
        Account acc = new Account();
        acc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Condominium').getRecordTypeId();
        acc.Name = 'AccountTest';
        acc.PrimaryEmail__c = 'testacc@test.com'; 
        acc.XC_DocumentCountry__c = 'Spain';
        acc.IdentityType__c = 'NIF';
        acc.IdentityNumber__c = '84715536G';
        acc.XC_Segment__c = SEGMENT;
        insert acc;

        Asset asst = new Asset();
        asst.Name = 'TestAsset';
        asst.AccountId = acc.Id;
        insert asst;
        
        XC_Customer_Interaction__c cI=  new XC_Customer_Interaction__c();
        cI.Name = 'Test Ci';
        cI.XC_AccountId__c = acc.Id;
        cI.XC_Communication_Type__c = 'Lead_Welcome_Email';
        cI.XC_Channel__c ='Email';
        cI.XC_LegalEntity__c='EndesaX';
        cI.XC_SurveyId__c ='test01';
        cI.XC_Preferredlanguageofcontact__c='English';
        insert cI;
    }

    @isTest
    static void testSegment() {
        Asset currAsset = [SELECT Id FROM Asset WHERE Name = 'TestAsset'][0];
        XC_Customer_Interaction__c cI = [SELECT Id FROM XC_Customer_Interaction__c WHERE Name = 'Test Ci'];
        // Custom field
		System.assertEquals(SEGMENT, XC_SegmentUtilities.getParentSegment(cI.Id, 'XC_AccountId__c'));
        // Standard field
        System.assertEquals(SEGMENT, XC_SegmentUtilities.getParentSegment(currAsset.Id, 'Account'));
    }

    private static List<XC_CM_LegalEntity_Configuration__mdt> getCmdtData(String orgId, String legalEntity, String stream) {
        return [
            SELECT XC_OrgId__c, XC_LegalEntity__c, XC_RecordType_Opportunity__c, XC_RecordType_Contract__c, XC_RecordType_WorkOrder__c
            FROM XC_CM_LegalEntity_Configuration__mdt
            WHERE XC_OrgId__c = :orgId AND XC_LegalEntity__c = :legalEntity AND XC_Stream__c = :stream
        ];
    }
    
    @isTest
    static void testCMDT() {
        Asset currAsset = [SELECT Id FROM Asset WHERE Name = 'TestAsset'][0];
        XC_CM_LegalEntity_Configuration__mdt[] cmdtData = getCmdtData(UserInfo.getOrganizationId(), LEGAL_ENTITY, SEGMENT);
	
        try {
            XC_SegmentUtilities.RTConfigWrapper rtw = XC_SegmentUtilities.getLegEntityConfig(currAsset.Id, 'Account', UserInfo.getOrganizationId(), LEGAL_ENTITY);
            System.assertEquals(cmdtData[0].XC_RecordType_Opportunity__c, rtw.opportunityRT);
            System.assertEquals(cmdtData[0].XC_RecordType_Contract__c, rtw.contractRT);
            System.assertEquals(cmdtData[0].XC_RecordType_WorkOrder__c, rtw.workOrderRT);

            rtw = XC_SegmentUtilities.getLegEntityConfig(currAsset.Id, 'Account', UserInfo.getOrganizationId(), null);
        } catch (Exception e) {
            System.assertEquals(XC_SegmentUtilities.ERROR_MESSAGE, e.getMessage());
        }
    }

}