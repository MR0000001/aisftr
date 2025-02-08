/**
 * Created by SNEKKANTI00 on 13/04/2021.
 */

public with sharing class RequestMailUpSendMailRecipient {
    public String Email;
    public Integer idMessage;

    public RequestMailUpSendMailRecipient(String email, Integer idMessage) {
        this.Email = email;
        this.idMessage = idMessage;
    }
}