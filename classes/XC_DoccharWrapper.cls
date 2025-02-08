public class XC_DoccharWrapper {
    
    /*{"doccharList":[{"Name": "test","Value": "test","Filter":true,"Compare": true,"Sequence": 18},{"Name": "test","Value": "test","Filter":true,"Compare": false,"Sequence": 18},{"Name": "test","Value": "test","Filter":true,"Compare":false,"Sequence": 18},...]}*/
    
    public List<DoccharList> doccharList;

    public class DoccharList {
        public String Name;
        public String Value;
        public Boolean Filter;
        public Boolean Compare;
        public Integer Sequence;
    }

    
    public static XC_DoccharWrapper parse(String json) {
        return (XC_DoccharWrapper) System.JSON.deserialize(json, XC_DoccharWrapper.class);
       
    }
}