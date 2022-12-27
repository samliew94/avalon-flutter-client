class Config {
  static String serverIp = "";
  static String getServerIp() {
    if (serverIp.isEmpty) {
      return "http://localhost";
    } else {
      return "http://$serverIp";
    }
  }
}
