/**
 * Created by SNEKKANTI00 on 09/03/2021.
 */

public with sharing class RequestMailUpSendSMS {
    public String Number_x;
    public String Prefix;
    public Integer idMessage;

    public RequestMailUpSendSMS(String phone, String prefix, Integer idMessage) {
        this.Number_x = phone;
        this.prefix = prefix;
        this.idMessage = idMessage;
    }
}