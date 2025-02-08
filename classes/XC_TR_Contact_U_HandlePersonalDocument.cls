/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 28/07/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_Contact_U_HandlePersonalDocument – Handle Personal Document record linked to Contact
*/
public  without sharing class XC_TR_Contact_U_HandlePersonalDocument {
    
     /**
     * Create Personal Document.
     *
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @param contacts the contacts
     * @date Creation 28/07/2019
     * @description create Personal Document record linked to Contact
     */
    public static void createPersonalDocument(List<Contact> contacts){
        System.debug('Entro in XC_TR_Contact_U_HandlePersonalDocument.createPersonalDocument');
        List<XC_PersonalDocument__c> pdsToInsert = new  List<XC_PersonalDocument__c>();
        List<String> contactIds = XC_UTIL_Sobject.getIds(contacts);
        Map<id,String> mapContactIdToAccountRT = new Map<id,String>();
		List<Contact> contactlist = new List<Contact>([Select id, XC_ContactDocumentCountry__c, XC_ContactDocumentType__c, XC_ContactDocumentNumber__c,XC_ContactDocReleaseDate__c,
                                                       XC_ContactDocExpirationDate__c, XC_PrimaryContact__c, Account.Id, Account.RecordTypeId FROM Contact WHERE Id IN: contactIds]);
        for(Contact contact : contactlist){
		mapContactIdToAccountRT.put(contact.id , contact.Account.RecordTypeId );
        }
        for(Contact c : contactlist){
            if(c.XC_ContactDocumentCountry__c!=null && c.XC_ContactDocumentType__c!=null && c.XC_ContactDocumentNumber__c!=null){
            XC_PersonalDocument__c pd = new XC_PersonalDocument__c();
            pd.XC_Contact__c = c.id; 
            pd.XC_Country__c = c.XC_ContactDocumentCountry__c;
            pd.XC_DocumentType__c = c.XC_ContactDocumentType__c;
            pd.XC_DocumentNumber__c = c.XC_ContactDocumentNumber__c;
            pd.XC_MainDocument__c = true;
            pd.XC_ReleaseDate__c = c.XC_ContactDocReleaseDate__c;
            pd.XC_ExpirationDate__c = c.XC_ContactDocExpirationDate__c;
           
            System.debug('Aggancio anche all account se Residential. RTId = ' +mapContactIdToAccountRT.get(c.Id));
            if(XC_UTIL_Account.isResidential(mapContactIdToAccountRT.get(c.Id)) && c.XC_PrimaryContact__c){
            	pd.XC_Account__c = c.Account.Id;
            }
            pdsToInsert.add(pd);
            }
           }
          XC_UTIL_Sobject.insertListRecords(pdsToInsert); 
        
    }
    
    

}