var this_year = DateTime.now().year.toString();

class AppConfig {
  //configure this
  static String copyright_text =
      "© MeTech Store $this_year";
  static String app_name =
      "MeTech Store";
  static String search_bar_text =
      "Search in MeTech Store...";
  static String purchase_code =
      "6670b53f-e5c6-49fc-a4aa-d30bcc525f60"; //enter your purchase code for the app from codecanyon
  static String system_key =
      r"$2y$10$41R8AcUjYaEyhRIYxUXMROTH7bryDxXGIenR.4q5lhB8uGKI/UJRC"; //enter your purchase code for the app from codecanyon

  //Default language config
  static String default_language = "en";
  static String mobile_app_code = "en";
  static bool app_language_rtl = false;

  //configure this
  static const bool HTTPS = true;
  static const DOMAIN_PATH = "metech.com.lb";

  //do not configure these below
  static const String API_ENDPATH = "api/v2";
  static const String PROTOCOL = HTTPS ? "https://" : "http://";
  static const String RAW_BASE_URL = "$PROTOCOL$DOMAIN_PATH";
  static const String BASE_URL = "$RAW_BASE_URL/$API_ENDPATH";
}
