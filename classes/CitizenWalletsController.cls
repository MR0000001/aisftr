/**
 * Created by SNEKKANTI00 on 07/06/2021.
 */

public with sharing class CitizenWalletsController {

    public class CitizenWalletWrapper {
        @AuraEnabled public CardInformationWrapper cardInformationWrapper;
        @AuraEnabled public List<WalletWrapper> walletWrappers;
        @AuraEnabled public List<TransactionInformationWrapper> transactionInformationWrappers;
        @AuraEnabled public List<String> partners;
        @AuraEnabled public Date minDate;
        @AuraEnabled public Date maxDate;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public Integer walletsPerPage;
        @AuraEnabled public Integer transactionsPerPage;
    }

    public class CardInformationWrapper {
        @AuraEnabled public String activationDate;
        @AuraEnabled public String expiryDate;
        @AuraEnabled public String serialNumber;
        @AuraEnabled public String issueDate;
        @AuraEnabled public String cardStatus;
        @AuraEnabled public String totalPoints;
        @AuraEnabled public String errorMessage;
    }

    public class WalletWrapper {
        @AuraEnabled public String walletId;
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String type;
        @AuraEnabled public String unit;
        @AuraEnabled public String supportsTransfer;
        @AuraEnabled public String balance;
        @AuraEnabled public String referenceId;
        @AuraEnabled public String errorMessage;
    }

    public class TransactionInformationWrapper {
        @AuraEnabled public String transactionId;
        @AuraEnabled public String value;
        @AuraEnabled public String amount;
        @AuraEnabled public String transactionDateString;
        @AuraEnabled public Date transactionDate;
        @AuraEnabled public String notes;
        @AuraEnabled public String transactionStatus;
        @AuraEnabled public String transactionType;
        @AuraEnabled public String authorizationCode;
        @AuraEnabled public String piggyBankId;
        @AuraEnabled public String piggyBankName;
        @AuraEnabled public String piggyBankDescription;
        @AuraEnabled public String receipt;
        @AuraEnabled public String externalTxId;
        @AuraEnabled public String shop;
        @AuraEnabled public String terminal;
        @AuraEnabled public String correlationReferenceId;
        @AuraEnabled public String referenceId;
        @AuraEnabled public String errorMessage;
    }

    @AuraEnabled
    public static CitizenWalletWrapper getCitizenWallets(String cardCode) {
        System.debug('cardCode ' + cardCode);
        CitizenWalletWrapper citizenWalletWrapper = new CitizenWalletWrapper();

        Map<String, Object> calloutResponse = CitizenWalletCardInfoCallout.citizenWalletCardInfoCallout(cardCode);
        System.debug('calloutResponse ' + calloutResponse);

        try {
            if(!calloutResponse.isEmpty()) {
                ResponseCitizenWalletCardInfo responseCitizenWalletCardInfo = (ResponseCitizenWalletCardInfo) calloutResponse.get('Card');
                ResponseCitizenWalletTransactions responseCitizenWalletTransactions = (ResponseCitizenWalletTransactions) calloutResponse.get('Transactions');

                citizenWalletWrapper = populateCitizenWalletWrapper(responseCitizenWalletCardInfo, responseCitizenWalletTransactions);
                citizenWalletWrapper.transactionsPerPage = getNoOfTransactionsPerPage();
                citizenWalletWrapper.walletsPerPage = getNoOfWalletsPerPage();
            } else {
                citizenWalletWrapper.errorMessage = System.Label.CitizenWallets_SomethingWrong;
            }
        } catch(Exception e) {
            System.debug('Exception at CitizenWalletsController.getCitizenWallets() ' + e.getMessage());
            citizenWalletWrapper.errorMessage = System.Label.CitizenWallets_SomethingWrong;
            ErrorLogEventHandler.standardExceptionLog(e);
        }

        return citizenWalletWrapper;
    }

    public static CitizenWalletWrapper populateCitizenWalletWrapper(ResponseCitizenWalletCardInfo responseCitizenWalletCardInfo, ResponseCitizenWalletTransactions responseCitizenWalletTransactions) {

        CitizenWalletWrapper citizenWalletWrapper = new CitizenWalletWrapper();

        citizenWalletWrapper.cardInformationWrapper = populateCardInformationWrapper(responseCitizenWalletCardInfo);
        if(String.isBlank(citizenWalletWrapper.cardInformationWrapper.errorMessage)) {
            citizenWalletWrapper.walletWrappers = populateWalletWrappers(responseCitizenWalletCardInfo, citizenWalletWrapper.cardInformationWrapper);
            if(responseCitizenWalletTransactions != null) {
                citizenWalletWrapper.transactionInformationWrappers = populateTransactionInformationWrappers(responseCitizenWalletTransactions, citizenWalletWrapper);
            }
        }
        return citizenWalletWrapper;
    }

    public static CardInformationWrapper populateCardInformationWrapper(ResponseCitizenWalletCardInfo responseCitizenWalletCardInfo) {
        CardInformationWrapper cardInformationWrapper = new CardInformationWrapper();

        if(responseCitizenWalletCardInfo.result != null) {
            cardInformationWrapper.activationDate = responseCitizenWalletCardInfo.result.activationDate.dateGmt().format();
            cardInformationWrapper.expiryDate = responseCitizenWalletCardInfo.result.expiryDate.dateGmt().format();
            cardInformationWrapper.cardStatus = responseCitizenWalletCardInfo.result.cardStatus;
            cardInformationWrapper.issueDate = responseCitizenWalletCardInfo.result.issueDate.dateGmt().format();
            cardInformationWrapper.serialNumber = responseCitizenWalletCardInfo.result.serialNumber;
        } else {
            cardInformationWrapper.errorMessage = responseCitizenWalletCardInfo.messages[0].message;
        }
        return cardInformationWrapper;
    }

    public static List<WalletWrapper> populateWalletWrappers(ResponseCitizenWalletCardInfo responseCitizenWalletCardInfo, CardInformationWrapper cardInformationWrapper) {
        List<WalletWrapper> walletWrappers = new List<WalletWrapper>();
        Decimal totalPoints = 0.0;
        if(responseCitizenWalletCardInfo?.result?.wallets == null) {
            WalletWrapper walletWrapper = new WalletWrapper();
            walletWrapper.errorMessage = System.Label.CitizenWallets_NoWallets;

            walletWrappers.add(walletWrapper);
        } else {
            for(ResponseCitizenWalletCardInfo.Wallets wallet : responseCitizenWalletCardInfo?.result?.wallets) {
                WalletWrapper walletWrapper = new WalletWrapper();
                if(wallet != null) {
                    walletWrapper.type = String.valueOf(wallet.type);
                    walletWrapper.balance = String.valueOf(wallet.balance?.value);
                    walletWrapper.description = wallet.description;
                    walletWrapper.name = wallet.name;
                    walletWrapper.walletId = String.valueOf(wallet.walletID);
                    walletWrapper.referenceId = wallet.referenceID;
                    walletWrapper.supportsTransfer = String.valueOf(wallet.supportsTransfer);
                    walletWrapper.unit = String.valueOf(wallet.unit);

                    totalPoints += Decimal.valueOf(walletWrapper.balance);
                }
                walletWrappers.add(walletWrapper);
            }
            cardInformationWrapper.totalPoints = String.valueOf(totalPoints);
        }

        return walletWrappers;
    }

    public static List<TransactionInformationWrapper> populateTransactionInformationWrappers(ResponseCitizenWalletTransactions responseCitizenWalletTransactions, CitizenWalletWrapper citizenWalletWrapper) {
        List<TransactionInformationWrapper> transactionInformationWrappers = new List<TransactionInformationWrapper>();
        System.debug(responseCitizenWalletTransactions);
        System.debug(responseCitizenWalletTransactions?.result);
        if(responseCitizenWalletTransactions?.result == null) {
            TransactionInformationWrapper transactionInformationWrapper = new TransactionInformationWrapper();
            transactionInformationWrapper.errorMessage = responseCitizenWalletTransactions.messages[0].message;

            transactionInformationWrappers.add(transactionInformationWrapper);
        } else if(responseCitizenWalletTransactions?.result?.transactions == null) {
            TransactionInformationWrapper transactionInformationWrapper = new TransactionInformationWrapper();
            transactionInformationWrapper.errorMessage = System.Label.CitizenWallets_NoTransactions;

            transactionInformationWrappers.add(transactionInformationWrapper);
        } else {
            Set<String> uniquePartners = new Set<String>();
            Date minDate = null;
            Date maxDate = null;
            for(ResponseCitizenWalletTransactions.Items item : responseCitizenWalletTransactions?.result?.transactions?.items) {
                TransactionInformationWrapper transactionInformationWrapper = new TransactionInformationWrapper();
                if(item != null) {
                    minDate = (minDate == null || item.transactionDate.date() < minDate) ? item.transactionDate.date() : minDate;
                    maxDate = (maxDate == null || item.transactionDate.date() > maxDate) ? item.transactionDate.date() : maxDate;
                    transactionInformationWrapper.transactionId = String.valueOf(item.transactionID);
                    transactionInformationWrapper.transactionDateString = item.transactionDate.dateGmt().format();
                    transactionInformationWrapper.transactionDate = Date.newInstance(item.transactionDate.year(), item.transactionDate.month(), item.transactionDate.day());
                    transactionInformationWrapper.transactionStatus = String.valueOf(item.transactionStatus);
                    transactionInformationWrapper.transactionType = String.valueOf(item.transactionType);
                    transactionInformationWrapper.value = String.valueOf(item.value);
                    transactionInformationWrapper.amount = String.valueOf(item.amount);
                    transactionInformationWrapper.notes = item.notes;
                    transactionInformationWrapper.authorizationCode = item.authorizationCode;
                    transactionInformationWrapper.piggyBankDescription = item.piggyBankDescription;
                    transactionInformationWrapper.piggyBankId = String.valueOf(item.piggyBankID);
                    transactionInformationWrapper.piggyBankName = item.piggyBankName;
                    transactionInformationWrapper.receipt = item.receipt;
                    transactionInformationWrapper.externalTxId = item.externalTxID;
                    transactionInformationWrapper.shop = item.shop;
                    transactionInformationWrapper.terminal = item.terminal;
                    transactionInformationWrapper.correlationReferenceId = item.correlationReferenceId;
                    transactionInformationWrapper.referenceId = item.referenceId;
                    uniquePartners.add(transactionInformationWrapper.piggyBankName);
                }
                transactionInformationWrappers.add(transactionInformationWrapper);
            }
            citizenWalletWrapper.minDate = minDate;
            citizenWalletWrapper.maxDate = maxDate;
            citizenWalletWrapper.partners = new List<String>(uniquePartners);
        }
        return transactionInformationWrappers;
    }

    public static Integer getNoOfTransactionsPerPage() {
        Citizen_Wallets_Table__c setting = Citizen_Wallets_Table__c.getValues('Citizen Wallets');
        return Integer.valueOf(setting.No_of_Transactions_per_Page__c);
    }

    public static Integer getNoOfWalletsPerPage() {
        Citizen_Wallets_Table__c setting = Citizen_Wallets_Table__c.getValues('Citizen Wallets');
        return Integer.valueOf(setting.No_of_Wallets_per_Page__c);
    }
}