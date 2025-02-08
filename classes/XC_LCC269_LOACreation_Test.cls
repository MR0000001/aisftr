@isTest
public class XC_LCC269_LOACreation_Test {
    
    static testMethod void testClass() 
    {
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EnelXItalia';
        insert admin;
        System.runAs(admin){
            
            Account customer=new Account();
            customer.XC_FirstName__c='Test1';
            customer.XC_LastName__c='Test2';
            customer.PrimaryEmail__c='test12@test.com';
            customer.XC_Account_Type__c = 'Competitor';
            insert customer;
            Account utility=new Account();
            utility.XC_FirstName__c='Test3';
            utility.XC_LastName__c='Test4';
            utility.PrimaryEmail__c='test34@test.com';
            utility.XC_Account_Type__c = 'Competitor';
            insert utility;
            /*List<Account> accs = XC_DF_Account.createResidentialAccounts(2);
            customer = accs.get(0);
            utility = accs.get(1);
            customer.XC_Account_Type__c = 'Competitor';
            utility.XC_Account_Type__c = 'Competitor';
            insert accs;*/
            List<XC_Address__c> address =  XC_DF_Address.createAddress(2);
            insert address;
            address[0].XC_Account__c = customer.id;
            address[1].XC_Account__c = utility.id;
            update address;
            customer.XC_Account_Type__c = 'End User';
            customer.XC_Addresss__c = address[0].id;
            update customer;
            utility.XC_Account_Type__c = 'Utility';
            utility.XC_Addresss__c = address[1].id;
            update utility;
            List<Account> accs=new List<Account>();
            accs.add(customer);
            accs.add(utility);
            List<Contact> contList = XC_DF_Contact.createResidentialContacts(accs);
            contList.get(0).XC_PrimaryContact__c = true;
            insert contList;
            DR_Site__c site1 = new DR_Site__c(Name = 'Site 1', XC_Address__c=address[0].Id, XC_Account__c =customer.id);
            insert site1;
            List<Service_Account__c> servAccs = new List<Service_Account__c>{
                new Service_Account__c(XC_Customer_Account__c=customer.Id, XC_Utility_Account__c=utility.Id, Name='Service Account 1', XC_DR_Site__c = site1.Id),
                    new Service_Account__c(XC_Customer_Account__c=customer.Id, XC_Utility_Account__c=utility.Id, Name='Service Account 2', XC_DR_Site__c = site1.Id)
                    };
                        insert servAccs;
            
            APXTConga4__Conga_Template__c ctemp = new APXTConga4__Conga_Template__c(APXTConga4__Name__c='Utility Template', Country__c='Italy');
            insert ctemp;
            
            insert new XC_CongaTemplateMapping__c(XC_Utility__c = utility.Id, XC_AccountType__c = 'B2B', XC_CongaIdTemplate__c=ctemp.Id);
            
            Contract con = new Contract();
            con.AccountId = customer.Id;
            con.RecordTypeID = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('XC_LOA').getRecordTypeId();
            con.Status = 'New';
            con.XC_LOA_Start_Date__c = Date.newInstance(2022, 02, 04);
            con.XC_LOA_Validity__c = 1;
            insert con;
            
            XC_LCC269_LOACreation.getInitData(accs.get(0).Id);
            
            XC_LCC269_LOACreation.getServAccounts(accs.get(0).Id, accs.get(1).Id);
            
            XC_LCC269_LOACreation.insertServiceAccounts(con.Id, null);
            
            XC_LCC269_LOACreation.insertServiceAccounts(con.Id, new List<String>{servAccs.get(0).Id, servAccs.get(1).Id});
            
        }
        
    }
}