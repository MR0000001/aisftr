/**
 * Created by snekkanti002 on 24/08/2022.
 */

public without sharing class ResponseGeoromaStreetsList {
    public List<Indirizzi> indirizzi;

    public class Indirizzi {
        public List<Civici> civici;
        public String indirizzo;
    }

    public Integer total;
    public Integer page;
    public Integer size;

    public class Civici {}
}