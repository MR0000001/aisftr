/* --------------------------------------------------
Strike by Appiphony

Version: 0.10.0
Website: http://www.lightningstrike.io
GitHub: https://github.com/appiphony/Strike-Components
License: BSD 3-Clause License
-------------------------------------------------- */
@isTest
private class strike_tst_lookupController {

    @isTest static void test_getRecentRecords() {
        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'"}';

        Test.startTest();
        String responseString = strike_lookupController.getRecentRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');

        //System.AssertEquals(true, response.get('isSuccess'));
    }

    @isTest static void test_getRecordLabel() {

        //FIX F.IMPERIOLI 13_09_19
        List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
        insert accs;

        // Account a = new Account(Name='Test Account');
        // insert a;

        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'"}';

        Test.startTest();
        String responseString = strike_lookupController.getRecordLabel(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        String objectLabel = String.valueOf(results.get('objectLabel'));

        //System.AssertEquals('Account', objectLabel);
    }

    @isTest static void test_getData() {
        //FIX F.IMPERIOLI 13_09_19
        List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
        accs[0].Name='Test Account';
        insert accs[0];

        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'", "order": "Name", "limit": "5", "searchTerm": "Test"}';

        Test.startTest();
        String responseString = strike_lookupController.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');

        //System.AssertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>)data.get(0);

        //System.AssertEquals(accs[0].Id, record.get('value'));
    }

    @isTest static void test_getData_subtitleField() {
        //FIX F.IMPERIOLI 13_09_19
        List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
        accs[0].Name='Test Account';
        insert accs[0];

        String jsonString = '{"searchField":"Name", "subtitleField": "Name", "object": "Account", "filter": "Name = \'Test Account\'", "searchTerm": "Test"}';

        Test.startTest();
        String responseString = strike_lookupController.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');

        //System.AssertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>)data.get(0);

        //System.AssertEquals(accs[0].Id, record.get('value'));
    }

    @isTest static void test_getData_addressField() {

        //FIX F.IMPERIOLI 13_09_19
        List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
        accs[0].Name='Test Account';
        accs[0].BillingStreet='Test Street';
        accs[0].BillingCity='Test City';
        accs[0].BillingState='Test State';
        accs[0].BillingCountry='Test Country';
        accs[0].BillingPostalCode='Test Postal Code';
        insert accs[0];

        String jsonString = '{"searchField":"Name", "subtitleField": "BillingAddress", "object": "Account", "filter": "Name = \'Test Account\'", "searchTerm": "Test"}';

        Test.startTest();
        String responseString = strike_lookupController.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');

        //System.AssertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>)data.get(0);

        //System.AssertEquals(accs[0].Id, record.get('value'));
    }

    @isTest static void test_getData_reference() {
        List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
        insert accs;
        
        List<Contact> cons = XC_DF_Contact.createResidentialContacts(1);
        cons[0].LastName = 'Contact';
        cons[0].FirstName='Test';
        cons[0].accountId=accs[0].Id;
        insert cons[0];

        String jsonString = '{"searchField":"FirstName", "subtitleField": "Account.Name", "object": "Contact", "filter": "Name = \'Test Contact\'", "searchTerm": "Test"}';

        Test.startTest();
        String responseString = strike_lookupController.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');

        //System.AssertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>)data.get(0);

        //System.AssertEquals(cons[0].Id, record.get('value'));
    }
}
/* --------------------------------------------------
Copyright 2017 Appiphony, LLC

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following 
disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote 
products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------- */