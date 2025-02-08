/**
 * Created by snekkanti002 on 24/08/2022.
 */

public without sharing class ResponseGeoromaStreetDetails {
    public class Geometry {
        public List<Double> coordinates;
        public String type;
    }

    public String type;
    public List<Features> features;
    public List<Double> bbox;

    public class Features {
        public String type;
        public Geometry geometry;
        public Properties properties;
        public String id;
        public List<Double> bbox;
    }

    public class Properties {
        public String TOPONIMO;
        public Integer NUMERO_CIVICO;
        public String LETTERA;
        public String ESPONENTE;
        public String CODICE;
        public Integer ID_CIVICO;
        public Integer ID_AREA_CIRCOLAZIONE;
        public Integer FID;
        public String PROVENIENZA;
        public String STATO;
        public Integer MUNICIPIO;
        public String NUMERO_ROMANO;
    }
}