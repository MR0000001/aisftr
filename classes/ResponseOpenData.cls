/**
 * Created by snekkanti002 on 02/08/2021.
 */

public without sharing class ResponseOpenData {
    public List<Esiti> Esiti = new List<Esiti>();

    public class Esiti {
        public String Esito;
        public String Id;
        public String errorMessage;
        public String errorCode;
    }
}