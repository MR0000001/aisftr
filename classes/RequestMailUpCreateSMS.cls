/**
 * Created by SNEKKANTI00 on 09/03/2021.
 */

public with sharing class RequestMailUpCreateSMS {
    public String Subject;
    public Integer idList;
    public String Content;
    public String Notes;
    public Boolean IsUnicode;
    public String Sender;

    public RequestMailUpCreateSMS(String subject, Integer idList, String content, String notes, Boolean IsUnicode, String sender) {
        this.Subject = subject;
        this.idList = idList;
        this.Content = content;
        this.Notes = notes;
        this.IsUnicode = isUnicode;
        this.Sender = sender;
    }
}