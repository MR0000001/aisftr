/**
 * @description       : This schedule class is used to send an email template on Accounts that have realated Safety point wallet with status 'Active' or 'Suspended'
 * @author            :  Francisca & Erlinda
 * @group             : 
 * @last modified on  : 05-07-2022
 * @date Modification : dd/mm/yyyy
**/
global class XC_SC069_ScheduleWalletBalanceHistory Implements Schedulable
    {
        global void execute(SchedulableContext sc)
        {
            sendEmailtoAccount();
        }

        public static void sendEmailtoAccount()
        {
            List<Account> listAccounts = new List<Account>();
            //listAccounts = [SELECT Id, Name, OwnerId, XC_SafetyPointsLicenseEmail__c, (SELECT Id, XC_SPW_Status__c, XC_Account__c FROM Safety_Point_Wallets__r WHERE (XC_SPW_Status__c = 'Active' OR XC_SPW_Status__c = 'Suspended') ) FROM Account WHERE XC_SafetyPointsLicenseEmail__c != ''];
			List<XC_SafetyPointWallet__c> listWallet = new List <XC_SafetyPointWallet__c>(); 	
            listWallet = [SELECT Id, XC_SPW_Status__c, XC_Account__c, XC_Account__r.Id, XC_Account__r.Name, XC_Account__r.OwnerId, XC_Account__r.XC_SafetyPointsLicenseEmail__c
                          FROM 	XC_SafetyPointWallet__c 
                		  WHERE (XC_SPW_Status__c = 'Active' OR XC_SPW_Status__c = 'Suspended')
                          AND XC_Account__r.XC_SafetyPointsLicenseEmail__c != ''];
            
              Map<Id, XC_SafetyPointWallet__c> mapAccount = new Map<Id, XC_SafetyPointWallet__c>();
            for(XC_SafetyPointWallet__c wallet : listWallet){
                mapAccount.put(wallet.XC_Account__c, wallet);
                }
                                 
            for(Id accId : mapAccount.KeySet())
            {
               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
               List<String> addresses = new List <String>();
               addresses.add(mapAccount.get(accId).XC_Account__r.XC_SafetyPointsLicenseEmail__c);
               mail.setToAddresses(addresses);
               mail.setSaveAsActivity(false);
               mail.setTargetObjectId(mapAccount.get(accId).XC_Account__r.OwnerId);
               mail.setWhatId(accId);
               mail.setTreatTargetObjectAsRecipient(False);
               mail.setSubject('Safety Points Wallet Balance History : ' + mapAccount.get(accId).XC_Account__r.Name);
               
			  
                
                EmailTemplate emailTemplate =[Select Id, Name, Subject, Description,
                                 HtmlValue,DeveloperName,Body
                                 from EmailTemplate where DeveloperName =
                                 'XC_ITA_Account_WalletBalanceHistory'];
                
                string Subject = emailTemplate.subject;
 				string Body = emailTemplate.body;
                mail.setTemplateId(emailTemplate.Id);
  				mail.setSubject(subject);
  				mail.setPlainTextBody(body);
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
               
                
            }

        }
    }