/**
 * Created by SNEKKANTI00 on 07/06/2021.
 */

public with sharing class ResponseCitizenWalletCardInfo {
    public Result result;
    public List<Messages> messages;

    public class Result {
        public Datetime expiryDate;
        public Datetime activationDate;
        public String serialNumber;
        public String webSerialNumber;
        public Datetime issueDate;
        public String cardStatus;
        public List<Wallets> wallets;
        public String correlationReferenceID;
    }

    public class Wallets {
        public Integer walletID;
        public String name;
        public String description;
        public Integer type;
        public Integer unit;
        public Boolean supportsTransfer;
        public Balance balance;
        public String referenceID;
    }

    public class Messages {
        public String message;
        public String errorCode;
        public List<String> tags;
        public List<Reasons> reasons;
    }

    public class Balance {
        public Decimal value;
    }

    public class Tags {
    }

    public class Reasons {
    }
}