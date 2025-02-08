/**
* @author Marco Lazzaroni - mlazzaroni@pic-informatica.it
* @date Creation 27/01/2022
* @description TAM_AsyncPublishCDE – Test class for change data event integration
*/

@IsTest
private class TAM_CDCObjectEventTest {
    @TestSetup
    static void Init() {
        Id FolderId = [SELECT Id FROM Folder WHERE Name = 'Technical Asset Integration'].Id;

        insert new List<Document>{
                new Document(
                        Name = 'Support JSON TEST',
                        DeveloperName = 'TAM_Support_TEST_JSON',
                        Body = Blob.valueOf('{"Name": %Name%, "Switchboard": %Switchboard%}'),
                        FolderId = FolderId
                ),
                new Document(
                        Name = 'Case JSON TEST',
                        DeveloperName = 'TAM_Case_TEST_JSON',
                        Body = Blob.valueOf('{"CaseNumber": %CaseNumber%}'),
                        FolderId = FolderId
                ),
                new Document(
                        Name = 'Support Fields TEST',
                        DeveloperName = 'TAM_Support_TEST_fields',
                        Body = Blob.valueOf('["Name", "Location.Longitude", "Location.Latitude"]'),
                        FolderId = FolderId
                ),
                new Document(
                        Name = 'Support queries TEST',
                        DeveloperName = 'TAM_Support_TEST_queries',
                        Body = Blob.valueOf('{"Main": "SELECT Id, Name, Location.Longitude, Location.Latitude FROM Asset WHERE Id in %Ids%", "Switchboard": "SELECT RelatedAsset.Id, RelatedAsset.Name, AssetId FROM AssetRelationship WHERE AssetId in %Ids%"}'),
                        FolderId = FolderId
                ),
                new Document(
                        Name = 'Case queries TEST',
                        DeveloperName = 'TAM_Case_TEST_queries',
                        Body = Blob.valueOf('{"Main": "SELECT Id, CaseNumber FROM Case WHERE Id in %Ids%"}'),
                        FolderId = FolderId
                )

        };

        Schema.Location Loc = new Schema.Location(
                Name = TAM_CDCObjectEventHelper.getKey(),
                Latitude = 1.1,
                Longitude = 1.1
        );
        insert Loc;

        Account Acc = XC_DF_Account.createSohoAccounts(1)[0];
        insert Acc;

        Contact Con = XC_DF_Contact.createSohoContacts(1)[0];
        Con.AccountId = Acc.Id;
        insert Con;

        List<Asset> aList = XC_DF_Asset.createAssets(1);
        Asset a = aList[0];
        a.Name = TAM_CDCObjectEventHelper.getKey();
        a.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'TAM_Support'].Id;
        a.AccountId = Acc.Id;
        a.Status = 'Installed';
        a.Country__c = 'Italy';
        a.LocationId = Loc.Id;
        a.TAM_IsTechnical__c = true;
        a.TAM_Make__c = 'Make';
        a.XC_Model__c = 'Model';
        a.TAM_ModelOrPartNumber__c = 'PN';
        a.SerialNumber = 'SN';
        a.XC_Segment__c = 'B2G';
        a.XC_LegalEntity__c = 'EnelXItalia';
        insert a;
    }

    public class publishCDEPayloadMockImpl implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(202);
            res.setStatus('Ok');
            res.setBody('{"result":{"code":202,"message":"Messages accepted"},"expires_in": 3600}');
            return res;
        }
    }

    @IsTest
    static void LocationChangeEventTrigger() {
        Test.setMock(HttpCalloutMock.class, new publishCDEPayloadMockImpl());
        Schema.Location Loc = [SELECT Id, Latitude, Longitude FROM Location LIMIT 1];

        Test.enableChangeDataCapture();

        Loc.Latitude = 1.2;
        Loc.Longitude = 1.2;

        update Loc;

        Test.getEventBus().deliver();

    }

    @IsTest
    static void AssetChangeEventTrigger() {
        Test.setMock(HttpCalloutMock.class, new publishCDEPayloadMockImpl());
        Asset A = [SELECT Id, Name FROM Asset LIMIT 1];

        Test.enableChangeDataCapture();

        A.Name = A.Name + '-01';
        update A;

        Test.getEventBus().deliver();

    }

    @IsTest
    static void CaseChangeEventTrigger() {
        Test.setMock(HttpCalloutMock.class, new publishCDEPayloadMockImpl());
        Asset A = [SELECT Id, Name, AccountId FROM Asset LIMIT 1];

        Test.enableChangeDataCapture();

        Case cs = XC_DF_Case.createCases(1)[0];
        cs.Status = 'ESTA001';
        cs.XC_TechnicalAsset__c = A.Id;
        cs.XC_LegalEntity__c = 'EnelXItalia';
        cs.Country__c = 'Italy';
        cs.AccountId = A.AccountId;
        cs.ContactId = [SELECT Id FROM Contact LIMIT 1].Id;
        insert cs;

        Test.getEventBus().deliver();
    }

    @IsTest
    static void CNamesChangeEvent() {
        Set<String> ss = TAM_CDCObjectEventHelper.CNames;
    }

    @IsTest
    static void XUNamesChangeEvent() {
        Set<String> ss = TAM_CDCObjectEventHelper.XUNames;
    }

}