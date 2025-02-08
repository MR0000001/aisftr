/**
 * Created by snekkanti002 on 14/09/2021.
 */

public without sharing class RequestOpenDataWebService {
    public List<Esiti> Esiti;

    public class Esiti {
        public String Esito;
        public String Id;
        public Boolean isInsertDataSet;
        public String errorMessage;
        public String errorCode;
    }
}