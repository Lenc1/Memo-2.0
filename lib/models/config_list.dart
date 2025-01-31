class ConfigList {
  String configName;
  String configIcon;
  String configRoute;

  ConfigList(this.configRoute,this.configName,this.configIcon);
  static List<ConfigList> configList = [
    ConfigList('config_1',"打开Memo存储路径","lib/assets/floder_icon.png"),
    ConfigList('config_2',"登录设备","lib/assets/equipment.png"),
    ConfigList('config_3',"导入Memo","lib/assets/file_download_icon.png"),
    ConfigList('config_4',"导出Memo","lib/assets/file_upload_icon.png"),
  ];
}