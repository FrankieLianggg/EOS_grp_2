public final class DbConfig {
    private DbConfig() {}

    // Update these values if your environment changes.
    public static final String HOST = "localhost";
    public static final int PORT = 13001;
    public static final String DATABASE = "G9_2";
    public static final String USER = "sa";
    public static final String PASSWORD = "P@123456789";

    // Change this to a valid DbSecurity.UserAuthorizationKey from your database.
    // The seed script inserted 6 group members, so 1 is a safe default if the DB was loaded from scratch.
    public static final int DEFAULT_USER_AUTHORIZATION_KEY = 1;

    public static String jdbcUrl() {
        return "jdbc:sqlserver://" + HOST + ":" + PORT
                + ";databaseName=" + DATABASE
                + ";encrypt=false"
                + ";trustServerCertificate=true"
                + ";loginTimeout=30";
    }
}
