public class WrapperClass {
	public Integer distance;
    public String emailAddress;
    public String firstName;
    public String headLine;
    public String lastName;
    public String pictureURL;
    public PositionClass positions;
    public String publicProfileURL;
    
    
    public class PositionClass{
        public Integer total;
        public ValueClass[] values;
    }
    
    public class ValueClass{
        public CompanyClass company;
        public Integer id;
        public Boolean isCurrent;
        public LocationClass location;
        public String title;
    }
    public class CompanyClass{
        public Integer id;
        public String industry;
        public String name;
        public String size;
        public String ticker;
        public String type;
    }
    public class LocationClass{
        public String latitude;
        public String longitude;
    }
}