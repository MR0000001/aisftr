/**
 * Created by SNEKKANTI00 on 07/06/2021.
 */

public with sharing class ResponseCitizenWalletTransactions {
    public Result result;
    public List<Messages> messages;

    public class Result {
        public Transactions transactions;
        public String expiryDate;
        public String activationDate;
        public String serialNumber;
        public String webSerialNumber;
        public String issueDate;
        public String cardStatus;
        public Status status;
        public List<Wallets> wallets;
        public String correlationReferenceID;
    }

    public class Transactions {
        public Integer pageIndex;
        public Integer pageSize;
        public Integer totalPage;
        public Integer totalCount;
        public Integer totalUnfiltered;
        public List<Items> items;
    }

    public class Wallets {
    }

    public class Messages {
        public String message;
        public List<String> tags;
    }

    public class Status {
        public Integer type;
        public String description;
    }

    public class Items {
        public Integer transactionID;
        public Decimal value;
        public Decimal amount;
        public Datetime transactionDate;
        public String notes;
        public Integer transactionStatus;
        public Integer transactionType;
        public String authorizationCode;
        public Integer piggyBankID;
        public String piggyBankName;
        public String piggyBankDescription;
        public String receipt;
        public String externalTxID;
        public String shop;
        public String terminal;
        public String correlationReferenceId;
        public String referenceId;
    }
}