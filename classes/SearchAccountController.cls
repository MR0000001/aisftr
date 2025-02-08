public with sharing class SearchAccountController {

    @TestVisible
    public class accountListWrapper {
        @AuraEnabled public String accountId {get;set;}
        @AuraEnabled public String firstName {get;set;}
        @AuraEnabled public String lastName {get;set;}
        @AuraEnabled public String birthday {get;set;}
        @AuraEnabled public String birthdayDate {get;set;}
        @AuraEnabled public String fiscalCode {get;set;}
        @AuraEnabled public String homePostalCode {get;set;}
        @AuraEnabled public String home {get;set;}
        @AuraEnabled public String homeCity {get;set;}
        @AuraEnabled public String homeState {get;set;}
        @AuraEnabled public String homeCountry {get;set;}
        @AuraEnabled public String homeData {get;set;}
        @AuraEnabled public String address {get;set;}
        @AuraEnabled public String registrationNumber {get;set;}
        @AuraEnabled public String identityCard {get;set;}
        @AuraEnabled public String gender {get;set;}
        @AuraEnabled public String birthdayPlace {get;set;}
        @AuraEnabled public String birthdayZone {get;set;}
        @AuraEnabled public String birthdayNation {get;set;}
        @AuraEnabled public String citizenship {get;set;}
        @AuraEnabled public String flagStatus {get;set;}
        @AuraEnabled public String civilStatus {get;set;}
        @AuraEnabled public String familyCode {get;set;}
        @AuraEnabled public String deathDate {get;set;}
        @AuraEnabled public String stateCodeResidence {get;set;}
        @AuraEnabled public String residenceLot {get;set;}
        @AuraEnabled public String townHallResidence {get;set;}
        @AuraEnabled public String staircaseResidence {get;set;}
        @AuraEnabled public String internalNumber {get;set;}
        @AuraEnabled public String residenceFloor {get;set;}
        @AuraEnabled public String immigrationCity {get;set;}
        @AuraEnabled public String immigrationState {get;set;}
        @AuraEnabled public String immigrationDate {get;set;}
        @AuraEnabled public String immigrationProvince {get;set;}
        @AuraEnabled public String spouseRegistrationNumber {get;set;}
        @AuraEnabled public String familyRelation {get;set;}
        @AuraEnabled public String startingDateRelationShip {get;set;}
        @AuraEnabled public String startingDateDomicile {get;set;}
        @AuraEnabled public String educationalQualification {get;set;}
        @AuraEnabled public Boolean fromSF {get;set;}
        @AuraEnabled public Boolean notFromSF {get;set;}

        public accountListWrapper() {}

        public accountListWrapper(String accountId, String firstName, String lastName, String birthday, String fiscalCode, String address, String home, Boolean fromSF, Boolean notFromSF){
            this.accountId = accountId;
            this.firstName = firstName;
            this.lastName = lastName;
            this.birthday = birthday;
            this.fiscalCode = fiscalCode;
            this.address = address;
            this.home = home;
            this.fromSF = fromSF;
            this.notFromSF = notFromSF;
        }
    }

    @AuraEnabled
    public static List<accountListWrapper> searchAccount(String name, String surname, Date birthday, String fiscalCode, String sex) {
        List<Account> accountList = new List<Account>();
        List<accountListWrapper> accountWrapperList = new List<accountListWrapper>();
        List<String> querySELECT = new List<String>();
        if(name != null && name != ''){
            querySELECT.add(' FirstName = \''+name+'\'');
        }
        if(surname != null && surname != ''){
            querySELECT.add(' LastName = \''+surname+'\'');
        }
        if(birthday != null){
            querySELECT.add(' PersonBirthdate =: birthday');
        }
        if(fiscalCode != null && fiscalCode!= ''){
            querySELECT.add(' Fiscal_Code__pc = \''+fiscalCode+'\'');
        }
        if(sex != null && sex!= '') {
            querySELECT.add(' Gender__pc = \''+sex+'\'');
        }
        //nascondo i draft
        querySELECT.add(' isDraft__c = false');

        accountList = AccountSelector.getAccountWithGenericConditions(new String[]{'Id','FirstName','LastName','PersonBirthdate', 'Fiscal_Code__pc','PersonOtherStreet','PersonOtherCity','PersonOtherState','PersonOtherPostalCode','PersonOtherCountry',
                'PersonMailingStreet','PersonMailingCity','PersonMailingState','PersonMailingPostalCode','PersonMailingCountry'
        },querySELECT, birthday);
        if(!accountList.isEmpty()) {
            System.debug('Calling SF');
            for(Account acc: accountList) {
                String address = (acc.PersonMailingStreet!=null?acc.PersonMailingStreet:'') + ' '+(acc.PersonMailingCity!=null?acc.PersonMailingCity:'')+ ' '
                        +(acc.PersonMailingState!=null?acc.PersonMailingState:'')+ ' '+(acc.PersonMailingPostalCode!=null?acc.PersonMailingPostalCode:'')+ ' '
                        +(acc.PersonMailingCountry!=null?acc.PersonMailingCountry:'');
                String home = (acc.PersonOtherStreet!=null?acc.PersonOtherStreet:'') + ' '+(acc.PersonOtherCity!=null?acc.PersonOtherCity:'')+ ' '
                        +(acc.PersonOtherState!=null?acc.PersonOtherState:'')+ ' '+(acc.PersonOtherPostalCode!=null?acc.PersonOtherPostalCode:'')+ ' '
                        +(acc.PersonOtherCountry!=null?acc.PersonOtherCountry:'');
                String birthdayDate = acc.PersonBirthdate!=null?acc.PersonBirthdate.format():'';
                accountWrapperList.add(new accountListWrapper(string.valueOf(acc.Id),acc.FirstName,acc.LastName,birthdayDate,acc.Fiscal_Code__pc,address,home,true,false));
            }
        } else {
            System.debug('Calling Anagrafica');
            List<ResponseAnagrafica> responseAnagraficas = new List<ResponseAnagrafica>();
            if(name != null && surname != null && birthday != null && sex != null && !name.equalsIgnoreCase('') && !surname.equalsIgnoreCase('') && !sex.equalsIgnoreCase('')) {
                responseAnagraficas = AnagraficaCallout.anagraficaCallout(3, 0, null, sex, surname, name, birthday.day(), birthday.month(), birthday.year());
            } else if(fiscalCode != null && !fiscalCode.equalsIgnoreCase('')) {
                responseAnagraficas = AnagraficaCallout.anagraficaCallout(2, 0, fiscalCode, null, null, null, 0, 0, 0);
            } else {
                return accountWrapperList;
            }
            accountWrapperList = populateAccountWrapperList(responseAnagraficas);
        }
        return accountWrapperList;
    }

    public static List<accountListWrapper> populateAccountWrapperList(List<ResponseAnagrafica> responseAnagraficas) {
        List<accountListWrapper> accountWrapperList = new List<accountListWrapper>();

        for(ResponseAnagrafica respAnagrafica : responseAnagraficas) {
            if(respAnagrafica.persona != null) {
                ResponseAnagrafica.Persona person = new ResponseAnagrafica.Persona();
                person = respAnagrafica.persona;
                accountListWrapper accountWrapper = new accountListWrapper();

                accountWrapper.fromSF = false;
                accountWrapper.notFromSF = true;
                accountWrapper.address = '';

                if(person.datiIndirizzo?.indirizzo?.indirizzoItaliano != null) {
                    ResponseAnagrafica.IndirizzoItaliano indirizzoItaliano = person.datiIndirizzo.indirizzo.indirizzoItaliano;

                    accountWrapper.stateCodeResidence = indirizzoItaliano.codiceVia;
                    accountWrapper.residenceLot = indirizzoItaliano.Lotto;
                    accountWrapper.townHallResidence = indirizzoItaliano.municipio;
                    accountWrapper.staircaseResidence = indirizzoItaliano.scala;
                    accountWrapper.internalNumber = indirizzoItaliano.interno;
                    accountWrapper.residenceFloor = indirizzoItaliano.piano;
                    accountWrapper.homeCity = System.Label.searchAccount_HomeCity;
                    accountWrapper.homeState = System.Label.searchAccount_HomeState;
                    accountWrapper.homeCountry = System.Label.searchAccount_HomeCountry;
                    accountWrapper.homePostalCode = (indirizzoItaliano.CAP == null) ? '' : ' ' + indirizzoItaliano.CAP;

                    accountWrapper.home = (indirizzoItaliano.toponimo == null) ? '' : indirizzoItaliano.toponimo;
                    accountWrapper.home += (indirizzoItaliano.numeroCivico?.numero == null) ? '' : ' ' + indirizzoItaliano.numeroCivico?.numero;
                    accountWrapper.home += (indirizzoItaliano.numeroCivico?.lettera == null) ? '' : indirizzoItaliano.numeroCivico?.lettera;
                    accountWrapper.homeData = accountWrapper.home + accountWrapper.homePostalCode;
                    accountWrapper.home += ' ' + accountWrapper.homeCity;
                    accountWrapper.home += ' ' + accountWrapper.homeState;
                    accountWrapper.home += accountWrapper.homePostalCode;
                    accountWrapper.home += ' ' + accountWrapper.homeCountry;

                    accountWrapper.startingDateDomicile = person.datiIndirizzo.dataInizioValiditaDomicilio?.anno + '-' + person.datiIndirizzo.dataInizioValiditaDomicilio?.mese + '-' + person.datiIndirizzo.dataInizioValiditaDomicilio?.giorno;
                    accountWrapper.startingDateDomicile = (accountWrapper.startingDateDomicile.containsIgnoreCase('null')) ? null : accountWrapper.startingDateDomicile;
                }

                if(person.datiAnagrafeRoma != null) {
                    if(person.datiAnagrafeRoma.datiIndividuo != null) {
                        ResponseAnagrafica.DatiIndividuo datiIndividuo = person.datiAnagrafeRoma.datiIndividuo;

                        accountWrapper.registrationNumber = datiIndividuo.codiceIndividuale;
                        accountWrapper.flagStatus = datiIndividuo.tipoIndividuo?.flagVivoResidente;
                    }

                    if(person.datiAnagrafeRoma.datiFamiglia != null) {
                        ResponseAnagrafica.DatiFamiglia datiFamiglia = person.datiAnagrafeRoma.datiFamiglia;

                        accountWrapper.familyCode = datiFamiglia.codiceFamiglia;

                        List<Schema.PicklistEntry> pickList = Schema.SObjectType.Account.fields.Family_Relation__pc.getPicklistValues();
                        for(Schema.PicklistEntry e : pickList) {
                            if(e.getLabel().equalsIgnoreCase(datiFamiglia.rapportoParentela)) accountWrapper.familyRelation = e.getValue();
                        }

                        accountWrapper.startingDateRelationShip = datiFamiglia.dataInizioAppartenenzaFamiglia?.anno + '-' + datiFamiglia.dataInizioAppartenenzaFamiglia?.mese + '-' + datiFamiglia.dataInizioAppartenenzaFamiglia?.giorno;

                        accountWrapper.startingDateRelationShip = (accountWrapper.startingDateRelationShip.containsIgnoreCase('null')) ? null : accountWrapper.startingDateRelationShip;
                    }
                }

                if(person.situazioneAnagrafe?.iscrizione != null) {
                    ResponseAnagrafica.Iscrizione iscrizione = person.situazioneAnagrafe.iscrizione;

                    accountWrapper.immigrationCity = iscrizione.nomeComune;
                    accountWrapper.immigrationState = iscrizione.nomeStato;
                    accountWrapper.immigrationDate = iscrizione.dataDefinizioneImmigrazione?.anno + '-' + iscrizione.dataDefinizioneImmigrazione?.mese + '-' + iscrizione.dataDefinizioneImmigrazione?.giorno;
                    accountWrapper.immigrationDate = (accountWrapper.immigrationDate.containsIgnoreCase('null')) ? null : accountWrapper.immigrationDate;
                    accountWrapper.immigrationProvince = iscrizione.siglaProvincia;
                }

                if(person.personaCompleta != null) {
                    ResponseAnagrafica.PersonaCompleta personaCompleta = person.personaCompleta;

                    accountWrapper.firstName = personaCompleta.nome;
                    accountWrapper.lastName = personaCompleta.cognome;
                    accountWrapper.gender = personaCompleta.sesso;
                    accountWrapper.fiscalCode = personaCompleta.codiceFiscale;
                    accountWrapper.civilStatus = personaCompleta.statoCivile;
                    /*List<Schema.PicklistEntry> pickList = Schema.SObjectType.Account.fields.Civil_Status__pc.getPicklistValues();

                    for(Schema.PicklistEntry e : pickList) {
                        if(e.getLabel().equalsIgnoreCase(personaCompleta.statoCivile)) accountWrapper.civilStatus = e.getValue();
                    }*/

                    accountWrapper.citizenship = personaCompleta.cittadinanza?.descrizioneCittadinanza;
                    accountWrapper.educationalQualification = personaCompleta.titolodiStudio;

                    if(personaCompleta.luogodiNascita != null) {
                        ResponseAnagrafica.Luogodi luogodiNascita = personaCompleta.luogodiNascita;

                        accountWrapper.birthdayPlace = luogodiNascita.nomeComune;
                        accountWrapper.birthdayZone = luogodiNascita.siglaProvincia;
                        accountWrapper.birthdayNation = luogodiNascita.nomeStato;
                    }

                    if(personaCompleta.datadiNascita != null) {
                        ResponseAnagrafica.Datadi datadiNascita = personaCompleta.datadiNascita;

                        accountWrapper.birthdayDate = datadiNascita.anno + '-' + datadiNascita.mese + '-' + datadiNascita.giorno;
                        accountWrapper.birthdayDate = (accountWrapper.birthdayDate.containsIgnoreCase('null')) ? null : accountWrapper.birthdayDate;
                        accountWrapper.birthday = (accountWrapper.birthdayDate != null) ? datadiNascita.giorno + '/' + datadiNascita.mese + '/' + datadiNascita.anno : null;
                    }
                }

                accountWrapper.identityCard  = person.documenti?.cartaIdentita?.numeroCI;
                accountWrapper.spouseRegistrationNumber = person.matrimonio?.datiConiuge?.coniuge?.codiceIndividuale;
                accountWrapper.deathDate = person.decesso?.datadiDecesso?.anno + '-' + person.decesso?.datadiDecesso?.mese + '-' + person.decesso?.datadiDecesso?.giorno;
                accountWrapper.deathDate = (accountWrapper.deathDate.containsIgnoreCase('null')) ? null : accountWrapper.deathDate;

                accountWrapperList.add(accountWrapper);
            }
            else if(respAnagrafica.elenco != null) {                
                ResponseAnagrafica.Elenco elenco = new ResponseAnagrafica.Elenco();
                List<ResponseAnagrafica.PersonaElenco> personaElenco = new List<ResponseAnagrafica.PersonaElenco>();
                elenco = respAnagrafica.elenco;
                personaElenco = respAnagrafica.elenco.personaElenco;
                for(ResponseAnagrafica.PersonaElenco person : personaElenco) {
                    accountListWrapper accountWrapper = new accountListWrapper();
                    
                    accountWrapper.fromSF = false;
                    accountWrapper.notFromSF = true;
                    accountWrapper.address = '';
                    accountWrapper.registrationNumber = person.codiceIndividuale;
                    accountWrapper.firstName = person.nome;
                    accountWrapper.lastName = person.cognome;
                    accountWrapper.gender = person.sesso;
                    accountWrapper.fiscalCode = person.codiceFiscale;
                    accountWrapper.flagStatus = person.flagVivoResidente;
                    accountWrapper.home = (person.indirizzo == null) ? '' : person.indirizzo;
                    accountWrapper.homeCity = System.Label.searchAccount_HomeCity;
                    accountWrapper.homeState = System.Label.searchAccount_HomeState;
                    accountWrapper.homeCountry = System.Label.searchAccount_HomeCountry;
                    accountWrapper.home += ' ' + accountWrapper.homeCity;
                    accountWrapper.home += ' ' + accountWrapper.homeState;
                    accountWrapper.home += ' ' + accountWrapper.homeCountry;
                    accountWrapper.homeData = accountWrapper.home;
                    if(person.datadiNascita != null) {
                        accountWrapper.birthdayDate = person.datadiNascita.anno + '-' + person.datadiNascita.mese + '-' + person.datadiNascita.giorno;
                        accountWrapper.birthdayDate = (accountWrapper.birthdayDate.containsIgnoreCase('null')) ? null : accountWrapper.birthdayDate;
                        accountWrapper.birthday = (accountWrapper.birthdayDate != null) ? person.datadiNascita.giorno + '/' + person.datadiNascita.mese + '/' + person.datadiNascita.anno : null;
                    }
                    accountWrapperList.add(accountWrapper);
                }
            }
        }
        return accountWrapperList;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getPersonAccountGenderPicklist() {
        Map<String, String> genderMap = new Map<String, String>();
        List<Schema.PicklistEntry> pickList = Schema.SObjectType.Account.fields.Gender__pc.getPicklistValues();
        for(Schema.PicklistEntry e : pickList) genderMap.put(e.getLabel(), e.getValue());

        return genderMap;
    }

    @AuraEnabled
    public static String createAccountDraft(List<String> listValForAccount){
        String resultId = '';
        system.debug('listValForAccount -> '+ listValForAccount);
        if ( listValForAccount.size() == 5) {
            Account newAccountDraft = new Account();

            newAccountDraft.Fiscal_Code__pc = (String.isNotBlank(listValForAccount[0]) ? listValForAccount[0] : null);
            newAccountDraft.FirstName = (String.isNotBlank(listValForAccount[1]) ? listValForAccount[1] : null);
            newAccountDraft.LastName = (String.isNotBlank(listValForAccount[2]) ? listValForAccount[2] : 'Cognome'); // FIX
            newAccountDraft.Gender__pc = (String.isNotBlank(listValForAccount[3]) ? listValForAccount[3] : null);
            newAccountDraft.PersonBirthdate = (String.isNotBlank(listValForAccount[4]) ? Date.valueOf(listValForAccount[4]) : null);

            if ( newAccountDraft.Fiscal_Code__pc == null ) {
                newAccountDraft.Not_Fiscal_Code__pc = true;
            }
            newAccountDraft.isDraft__c = true;

            Boolean retryInsert = true;
            try {
                while (retryInsert) {
                    Database.SaveResult srList = Database.insert(newAccountDraft, false);
                    system.debug('srList -> ' + srList);
                    if (srList.isSuccess()) {
                        resultId = srList.getId();
                        retryInsert = false;
                    } else {
                        String idToDelete = String.valueOf([SELECT Id FROM Account WHERE Fiscal_Code__pc = :newAccountDraft.Fiscal_Code__pc].Id);
                        deleteAccountDraft(idToDelete);
                    }
                }
            } catch (Exception ex) {
                system.debug('Error -> ' + ex);
            }

        }
        return resultId;
    }

    @AuraEnabled
    public static void deleteAccountDraft(String IdToRemove) {
        System.debug('deleteAccountDraft, id -> '+ IdToRemove);
        Account tmpAccount = [SELECT Id FROM Account WHERE Id =: IdToRemove];
        Database.delete(tmpAccount);
    }

    @AuraEnabled
    public static String getRecordTypeForPersonAccount(){
        OrgManagement__c orgManagement = [SELECT RT_PersonAccountStandard__c FROM OrgManagement__c LIMIT 1];
        return String.valueOf(orgManagement.RT_PersonAccountStandard__c);
    }

    @AuraEnabled
    public static Boolean associateAccountIdToCaseById(String caseId, String accountIdToAssociate) {
        system.debug('caseId -> ' + caseId);
        system.debug('accountIdToAssociate -> ' + accountIdToAssociate);
        try {
            Account accountValues = [SELECT Id, PersonContactId FROM Account WHERE Id =: accountIdToAssociate];
            Case caseToUpdate = [SELECT Id, AccountId, ContactId, Case_Business_Account__c FROM Case WHERE Id =: caseId];
            if ( caseToUpdate != null ) {
                caseToUpdate.AccountId = accountIdToAssociate;
                caseToUpdate.ContactId = accountValues.PersonContactId;
                caseToUpdate.Case_Business_Account__c = false;
                caseToUpdate.Persona_Fisica__c = accountValues.Id;
                Database.SaveResult updateResult = Database.update(caseToUpdate, false);
                if (updateResult.isSuccess()) {
                    System.debug('success');
                    return true;
                } else {
                    System.debug(updateResult.getErrors());
                    System.debug('nope');
                }
            }
        } catch (Exception ex){
            //
            System.debug(ex.getMessage());
        }
        return false;
    }

    @AuraEnabled
    public static void updateAccountDraftField(String AccountId) {
        Account acc = [ SELECT isDraft__c FROM Account WHERE Id=: AccountId];
        acc.isDraft__c = false;
        Database.update(acc);
    }
}