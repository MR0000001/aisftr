/**
 * Created by SNEKKANTI00 on 08/03/2021.
 */

public with sharing class RequestMailUpCreateMail {
    public String Subject;
    public String Content;
    public Boolean Embed;
    public Boolean IsConfirmation;
    public String Notes;
    public TrackingInfo TrackingInfo = new TrackingInfo();

    public class TrackingInfo {
        public String CustomParams = '';
        public Boolean Enabled = false;
        public List<String> Protocols = new List<String>{''};
    }

    public RequestMailUpCreateMail(String Subject, String Content, Boolean Embed, Boolean IsConfirmation, String Notes, String Tags) {
        this.Subject = Subject;
        this.Content = Content;
        this.Embed = Embed;

        this.IsConfirmation = IsConfirmation;
        this.Notes = Notes;
    }
}