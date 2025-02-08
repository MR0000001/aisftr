/**
 * Created by snekkanti002 on 22/11/2022.
 */

@IsTest
public class TestIAMCallout {

    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
        TestDataFactory.createAccounts();
    }

    @IsTest
    public static void iamCallout() {
        List<Account> accounts = [SELECT Date_Time_Sent_To_IAM__pc, ToBeSentIAM__pc, PersonEmail, PersonHomePhone, PersonMobilePhone, Fax, Fiscal_Code__pc FROM Account];

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseIAM());

        Test.startTest();
        IAMCallout.iamCallout(accounts);
        Test.stopTest();
    }
}