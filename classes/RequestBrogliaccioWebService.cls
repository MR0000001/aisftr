/**
 * Created by snekkanti002 on 23/09/2021.
 */

public with sharing class RequestBrogliaccioWebService {
    public List<Allegati> allegati;

    public class Allegati {
        public String Esito;
        public String DescrEsito;
        public String IDImmagine;
        public String AllegatoID;
    }
}