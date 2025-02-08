/**
 * The Class XC_TR_PersonalDocument_U_FillFields.
 *
 * @author Sara Miozza sara.miozza@nttdata.com
 * @date Creation 28/05/2019
 * @date Modification 
 * @description XC_TR_PersonalDocument_U_FillFields populate the fields of XC_PErsonalDocument__c
 */
public without sharing class XC_TR_PersonalDocument_U_FillFields {
	/**
     * @description Populate the Contact Id 
     * @author Federica Tavera federica.tavera@nttdata.com
     * @param personalDocumentList - List<XC_PersonalDocument__c>
     */
    public static void populateContactId (List<XC_PersonalDocument__c> personalDocumentList){
        If(!personalDocumentList.isEmpty()){
            for(XC_PersonalDocument__c persDoc : personalDocumentList){
                If(String.isNotBlank(persDoc.XC_Contact__c)){
                    persDoc.XC_ContactId__c = persDoc.XC_Contact__c;
                }
            }
        }
    }
}