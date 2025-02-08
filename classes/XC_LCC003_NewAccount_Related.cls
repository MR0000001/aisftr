/**
 * @author Monica Cutillo - monica.cutillo@nttdata.com
 * @date Creation 09/05/2019
 * @description XC_LCC003_NewAccount_Related – Class that manage related Objects for XC_LCC003_NewAccount
 */

public without sharing class XC_LCC003_NewAccount_Related {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC003_NewAccount');

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 26/05/2020
     * @description Insert related object for Account (B2C)
     * @param newAccount - Account
     * @param inputData - AccountInputDataWrapper
     * @param beforeInsertSavepoint - SavePoint
     * @return XC_LCC003_NewAccount_W.InsertResultWrapper
     */
    public static XC_LCC003_NewAccount_W.InsertResultWrapper saveRelatedObjects(Account newAccount, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData, System.Savepoint beforeInsertSavepoint) {
        return saveRelatedObjects(newAccount, inputData, beforeInsertSavepoint, false);
    }

    /**
    * @description Insert the Social Persona association and record
    * @param newAccount the new account
    * @param inputData map with data to save
    * @param beforeInsertSavepoint point to rollback if needs
    * @param isForB2B - Boolean
    * @return the insert result wrapper
    */
    public static XC_LCC003_NewAccount_W.InsertResultWrapper saveRelatedObjects(Account newAccount, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData, System.Savepoint beforeInsertSavepoint, Boolean isForB2B) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# NewAccount - saveConsents ---> newAccount = ' + newAccount);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# NewAccount - inputData = = ' + inputData);
        if (XC_UTIL_Account.isResidential(newAccount.recordTypeId)) {
            XC_UTIL_Sobject.WrapperResult docResult = XC_LCC003_NewAccount_U.insertDocuments(newAccount);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# docResult ---> ' + docResult);
            if (!docResult.success) {
                return XC_LCC003_NewAccount_U.doRollback(docResult, beforeInsertSavepoint);
            }
        }

        XC_UTIL_Sobject.WrapperResult addressResult = XC_LCC003_NewAccount_U.insertAddress(newAccount, inputData, newAccount.recordTypeId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# addressResult ---> ' + addressResult);
        if (!addressResult.success) {
            return XC_LCC003_NewAccount_U.doRollback(addressResult, beforeInsertSavepoint);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# inputData.accountCheckDuplicateRes ' + inputData.accountCheckDuplicateRes);

        if(!isForB2B) {
            System.debug('§§DP-> Not for B2B');
            XC_UTIL_Sobject.WrapperResult cntResult = manageContact(newAccount, inputData, beforeInsertSavepoint);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# NewAccount - manageContact' + cntResult);
            if (!cntResult.success) {
                return XC_LCC003_NewAccount_U.doRollback(cntResult, beforeInsertSavepoint);
            }

            ////dpalamides
            List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> lcc163Wrapper = (List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>) JSON.deserialize(inputData.consentsWrapper, List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>.class);

            XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# NewAccount - lcc163Wrapper = ' + lcc163Wrapper);
            Contact primaryContact = (new Map<Id, Contact>([select Id, name, IndividualId from Contact where AccountId = :newAccount.Id /*and XC_PrimaryContact__c = true*/ limit 1])).values();
            if(lcc163Wrapper != null){

			
				List<XC_LegalEntityConsent__c> existingConsents = [SELECT id,XC_LegalEntity__c FROM XC_LegalEntityConsent__c WHERE XC_Individual__c = :primaryContact.IndividualId];

                Map<String,XC_LegalEntityConsent__c> leExistingConsent = new Map<String,XC_LegalEntityConsent__c>();
                for(XC_LegalEntityConsent__c lec : existingConsents){
                    leExistingConsent.put(lec.XC_LegalEntity__c,lec);
                }

				List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> createConsentsWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();

                System.debug('§§DP->' + lcc163Wrapper);
                Account accountInfo = (Account) XC_UTIL_Sobject.selectAllFields(newAccount.Id)[0];
                Individual individualInfo = new Individual();
                if (primaryContact.IndividualId != null) {
                    individualInfo = (Individual) XC_UTIL_Sobject.selectAllFields(primaryContact.IndividualId)[0];
                }
                for (XC_LCC163_CreateConsents.GetLegalEntitiesResponse currWrapper : lcc163Wrapper) {
                    if (!newAccount.XC_ConfirmationByCustomer__c || leExistingConsent.containsKey(currWrapper.legalEntity)) {
                        continue;
                    }
                    XC_LCC163_CreateConsents.GetLegalEntitiesResponse createConsentsWrapper = (currWrapper != null) ? currWrapper : new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
                    System.debug('§§DP->' + inputData.consentsWrapper);
                    //newLead.Country__c = createConsentsWrapper.consentsData.personalInfo.theLead.Country__c;
                    createConsentsWrapper.consentsData.personalInfo.theContactAccount = accountInfo;
                    createConsentsWrapper.consentsData.personalInfo.confirmationByTheCustomer=newAccount.XC_ConfirmationByCustomer__c;
                    createConsentsWrapper.confirmationByTheCustomer = newAccount.XC_ConfirmationByCustomer__c;
                    createConsentsWrapper.consentsData.personalInfo.theContact = primaryContact;
                    if (primaryContact.IndividualId != null) {
                        createConsentsWrapper.consentsData.personalInfo.theContactIndividual = individualInfo;
                    }
                    System.debug('§§DP->' + createConsentsWrapper);
                    createConsentsWrapperList.add(createConsentsWrapper);
                }
                if(!Test.isRunningTest()) {
                    List<XC_UTIL_Sobject.WrapperResult> leDmlRes = XC_LCC163_CreateConsents.createLegalEntitiesWithResults(JSON.serialize(createConsentsWrapperList));
                    XC_UTIL_Sobject.WrapperResult leDmlResGlo = XC_UTIL_Sobject.getGlobalDMLResults(leDmlRes);
                    if(!leDmlResGlo.success){
                        return XC_LCC003_NewAccount_U.doRollback(leDmlResGlo, beforeInsertSavepoint);
                    }
                }
            }
        } 
        //}
        /*  if (inputData.accountCheckDuplicateRes != null && inputData.accountCheckDuplicateRes.existingContact != null) {
              XC_UTIL_Sobject.WrapperResult resUpdateContact;
              resUpdateContact = updateAccountToPrimary(newAccount, inputData, beforeInsertSavepoint);
              if (!resUpdateContact.success) {
                  return XC_LCC003_NewAccount_U.doRollback(resUpdateContact, beforeInsertSavepoint);
              }

          }else if (inputData.accountCheckDuplicateRes == null || inputData.accountCheckDuplicateRes != null && inputData.accountCheckDuplicateRes.existingContact == null) {
              XC_UTIL_Sobject.WrapperResult resultFromIndividual;
              //resultFromIndividual= XC_TR_Contact_U_CheckDuplicates.checkduplicationContactAndInsertIndividual(newAccount, inputData); //.contactFields
              resultFromIndividual= XC_TR_Contact_U_CheckDuplicates.manageNotExistingContact(newAccount, inputData); //.contactFields
              XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# resultFromIndividual ---> ' + resultFromIndividual);
              if(!resultFromIndividual.success) {
                  return XC_LCC003_NewAccount_U.doRollback(resultFromIndividual.errorMessage, beforeInsertSavepoint);
              }
          }*/
        return saveLEConsents(newAccount, inputData, beforeInsertSavepoint);
    }

    private static XC_UTIL_Sobject.WrapperResult manageContact(Account newAccount, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData, System.Savepoint beforeInsertSavepoint) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# In Manage Contact for New Account');
        XC_UTIL_Sobject.WrapperResult res = new XC_UTIL_Sobject.WrapperResult();
        res.success = true;
        if (inputData.accountCheckDuplicateRes != null && inputData.accountCheckDuplicateRes.existingContact != null) {
            res = updateAccountToPrimary(newAccount, inputData, beforeInsertSavepoint);
        } else if (inputData.accountCheckDuplicateRes == null || inputData.accountCheckDuplicateRes != null && inputData.accountCheckDuplicateRes.existingContact == null) {
            res = XC_TR_Contact_U_CheckDuplicates.manageNotExistingContact(newAccount, inputData, true);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# res for manageContact = ' + res);
        return res;
    }

    /**
    * @description Insert Legal Entity Consents
    * @param newAccount the new account
    * @param inputData map with data to save
    * @param beforeInsertSavepoint point to rollback if needs
    * @return the insert result wrapper
    */
    private static XC_LCC003_NewAccount_W.InsertResultWrapper saveLEConsents(Account newAccount, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData, System.Savepoint beforeInsertSavepoint) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### in saveLEConsents for  ### ' + newAccount);

        if(String.isBlank(inputData.consentsLE)){
            return new XC_LCC003_NewAccount_W.InsertResultWrapper(newAccount.Id);
        }

        Id individualId;
        if (inputData.accountCheckDuplicateRes != null && inputData.accountCheckDuplicateRes.existingContact != null) {
            individualId = inputData.accountCheckDuplicateRes.existingContact.IndividualId;
        } else {
            individualId = retrieveIndividualId(newAccount);
        }

        if (individualId != null && inputData.accountCheckDuplicateRes != null && inputData.accountCheckDuplicateRes.successConsent) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '#-#-#-# saveLEConsents - IndividualId = ' + individualId);
            XC_UTIL_Sobject.WrapperResult leDmlResult = XC_LCC002_NewLead_U.insertLegalEntityConsents(individualId, inputData.consentsLE);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@leDmlResult@@@' + leDmlResult);
            if (!leDmlResult.success) {
                return XC_LCC003_NewAccount_U.doRollback(leDmlResult, beforeInsertSavepoint);
            }

            XC_UTIL_Sobject.WrapperResult indiResult = updateIndividual(individualId, inputData);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@indiResult@@@' + indiResult);
            if (!indiResult.success) {
                return XC_LCC003_NewAccount_U.doRollback(indiResult, beforeInsertSavepoint);
            }
        }
        Boolean b = (newAccount.Id == null && inputData.accountCheckDuplicateRes != null && inputData.accountCheckDuplicateRes.existingContact != null);
        if (b) {
            XC_LCC003_NewAccount_W.InsertResultWrapper res = new XC_LCC003_NewAccount_W.InsertResultWrapper(inputData.accountCheckDuplicateRes.existingContact.AccountId);
            res.errorMessage = Label.XC_CL_UpdateLegalEntity_Acc_Dup;
            return res;
        }
        return new XC_LCC003_NewAccount_W.InsertResultWrapper(newAccount.Id);
    }

    /**
    * @description Insert legal entity consents
    * @param individualId individual Id
    * @param inputData obj
    * @return XC_UTIL_Sobject.WrapperResult
    */
    @testVisible 
    private static XC_UTIL_Sobject.WrapperResult updateIndividual(Id individualId, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ NewAccount > updateIndividual -> IndividualId = ' + individualId);
        Individual indiToUpd = new Individual();
        indiToUpd.Id = individualId; 
        //indiToUpd.XC_GiveDataToThirdParties__c = inputData.thirdPartiesCheckNew; dpalamides
        //indiToUpd.XC_RobinsonCustomer__c = inputData.robinsonCustomer; dpalamides
        //indiToUpd.XC_ThirdPartyConsentVersion__c = inputData.thirdPartiesVersion; dpalamides

        List<XC_UTIL_Sobject.WrapperResult> indiResult = XC_UTIL_DML.updateRecords(new List<Individual>{
                indiToUpd
        });
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ indiResult = ' + indiResult);
        return indiResult[0];
    }

    /**
    * @description Retrieve the IndividualId on Primary Contact
    * @param newAccount the new account
    * @return the IndividualId field value or null
    */
    private static Id retrieveIndividualId(Account newAccount) {
        if(newAccount == null || newAccount.Id == null) {
            return null;
        }
        Map<Id, Contact> rows = new Map<Id, Contact>([SELECT Id, IndividualId FROM Contact WHERE AccountId = :newAccount.Id AND XC_PrimaryContact__c = true]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# NewAccount - rows = ' + rows);
        if(rows == null || rows.isEmpty()) {
            return null;
        }
        Contact contact = rows.values()[0];
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#-#-#-# retrieveIndividualId - Contact ---> ' + contact);
        return contact.IndividualId;
    }
    /**
    * @description populate LegalEntityWrapper List from the serialized LE from component
    * @param serializedLE serialized LE from component
    * @return the populated LegalEntityWrapper List
    */
    public static List<XC_LegalEntityConsent__c> populateLEWrapper(String serializedLE) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ serializedLE = ' + serializedLE);
        List<XC_LegalEntityConsent__c> newLE = new List<XC_LegalEntityConsent__c>();
        if (String.isNotBlank(serializedLE) && !serializedLE.equals('null')) {
            List<Object> consentsLEList = (List<Object>) JSON.deserializeUntyped(serializedLE);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsLEList = ' + consentsLEList);
            XC_LegalEntityConsent__c newConsent;
            for (Object obj : consentsLEList) {
                Map<String, Object> item = (Map<String, Object>) obj;
                newConsent = new XC_LegalEntityConsent__c();
                newConsent.XC_LeCountry__c = String.valueOf(item.get('XC_LeCountry__c'));
                newConsent.XC_LegalEntity__c = (String) item.get('XC_LegalEntity__c');
                newConsent.XC_GiveDataToNew__c = String.valueOf(item.get('XC_GiveDataTonew__c'));
                newConsent.XC_UpdateAboutProducts__c = String.valueOf(item.get('XC_UpdateAboutProducts__c'));
                newConsent.XC_ConsentToDataProcessing__c = String.valueOf(item.get('XC_ConsentToDataProcessing__c'));

                newLE.add(newConsent);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ newLE = ' + newLE);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# NewAccount - newLE = ' + newLE);
        return newLE;
    }

    @testVisible 
    private static XC_UTIL_Sobject.WrapperResult updateAccountToPrimary(Account newAccount, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData, System.Savepoint beforeInsertSavepoint) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@updateAccountToPrimary ' + inputData);
        Contact cnt = inputData.accountCheckDuplicateRes.existingContact;
        Account acc = inputData.accountCheckDuplicateRes.ac != null ? inputData.accountCheckDuplicateRes.ac : newAccount;
        XC_UTIL_Sobject.WrapperResult res = new XC_UTIL_Sobject.WrapperResult();
        res.success = true;
        if (cnt != null && acc.Id != null) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# For Account = ' + acc + ' - for Contact = ' + cnt);
            cnt.AccountId = acc.id;
            cnt.XC_PrimaryContact__c = true;
            res = XC_UTIL_Sobject.updateRecord(cnt);

            List<AccountContactRelation> junctionObjList = XC_TR_Contact_U_CheckDuplicates_D.getAccountContactRelations(cnt.AccountId, cnt.Id);
            if (!junctionObjList.isEmpty()) {
                AccountContactRelation acr = junctionObjList[0];
                acr.Roles = Label.XC_CL_AccountContactRel_Owner;
                res = XC_UTIL_Sobject.updateRecord(acr);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@updateAccountToPrimary return ' + res);
        return res;
    }

    /**
    * @description
    * @author Del Prete Domenico | 22/8/2019
    * @param inputData XC_LCC003_NewAccount_W.AccountInputDataWrapper 
    * @return Boolean
    */
    public static Boolean checkAccountDuplication(XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData) {
        return (inputData.accountCheckDuplicateRes == null || (inputData.accountCheckDuplicateRes != null && !inputData.accountCheckDuplicateRes.isDuplicate) || inputData.accountCheckDuplicateRes != null && !inputData.accountCheckDuplicateRes.existingContact.XC_PrimaryContact__c);
    }
}