/**
 * Created by snekkanti002 on 24/08/2022.
 */

public without sharing class RequestGeoromaStreetDetails {
    public RequestGeoromaStreetDetails(String streetName, String streetNumber, String epsg) {
        this.query.indirizzo = streetName;
        this.query.civico = streetNumber;
        this.query.epsg = epsg;
    }

    public Query query = new Query();

    public class Query {
        public String indirizzo;
        public String civico;
        public String epsg;
    }
}