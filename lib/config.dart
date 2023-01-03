class Config {
  static String serverIp = "192.168.0.237";
  static String getServerIp() {
    if (serverIp.isEmpty) {
      return "http://localhost";
    } else {
      return "http://$serverIp";
    }
  }
}
