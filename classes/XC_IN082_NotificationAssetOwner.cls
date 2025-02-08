/**
 * @author Nicola Mariniell - nmariniello@deloitte.it
 * @date Creation 14/10/2021
 * @description XC_IN082_NotificationAssetOwner – public class with invocable method.
 */


public without sharing class XC_IN082_NotificationAssetOwner {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN082_NotificationAssetOwner');
	

	/**
     * @description InputWrapper
     **/  
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;
    }


    /**
     * @description 
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod 
    public static void sendEmailToAssetOwner(List<InputWrapper> inputWrapperList) {
	
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'In XC_IN082_NotificationAssetOwner');

		if(!inputWrapperList.isEmpty()) {
            List<String> stepIds = new List<String>();
			for(InputWrapper inputWr : inputWrapperList){
                stepIds.add(inputWr.stepId);
			}
            if(stepIds.isEmpty()) {
                return;
            }

            XC_Provisioning_Step__c step = new XC_Provisioning_Step__c(Id = stepIds[0]);

            Map<Id, NE__OrderItem__c> mapConfItems = new Map<Id, NE__OrderItem__c>([SELECT Id, (SELECT Id, Name, Owner.Name, Owner.Email, Account.Name FROM Assets__r)
                                                                                    FROM NE__OrderItem__c
                                                                                    WHERE Id IN (SELECT XC_Configuration_Item__c FROM XC_Provisioning_Step__c WHERE Id IN :stepIds)]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapConfItems -> ' + mapConfItems);

            if(mapConfItems.isEmpty()) {
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = 'No Configuration Item found';
                XC_UTIL_Sobject.updateRecord(step);
                return;
            }

            NE__OrderItem__c confItem = mapConfItems.values()[0];
            String ownerEmail = (confItem.Assets__r.isEmpty()) ? null : confItem.Assets__r[0].Owner.Email;
            if(String.isBlank(ownerEmail)) {
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = 'Blank Owner Email';
                XC_UTIL_Sobject.updateRecord(step);
                return;
            }

            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {ownerEmail});
            mail.setSenderDisplayName('Salesforce Support');
            mail.setSubject('Asset Disconnection');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            String body = Label.XC_CL_BodyEmail_NotificationAssetOwner;
            body = body.replace('<OWNERNAME>', confItem.Assets__r[0].Owner.Name);
            body = body.replace('<ASSETNAME>', confItem.Assets__r[0].Name);
            body = body.replace('<ASSETID>', confItem.Assets__r[0].Id);
            body = body.replace('<ACCOUNTNAME>', confItem.Assets__r[0].Account.Name);
            mail.setPlainTextBody(body.replace('<p>', ''));
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            step.XC_Status__c = Label.XC_CL_Completed_Ok;
            XC_UTIL_Sobject.updateRecord(step);
		}
	}
}